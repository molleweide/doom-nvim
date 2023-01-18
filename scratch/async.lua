local co = coroutine
local resume = co.resume

-- local thread = co.create(function ()
--   local x, y, z = co.yield(something)
--   return 12
-- end)
--
-- local cont, ret = co.resume(thread, x, y, z)

local pong = function(thread)
  local nxt = nil
  nxt = function(cont, ...)
    -- print("cont:", cont, ...)
    if not cont then
      print("a")
      return ...
    else
      print("b")
      return nxt(co.resume(thread, ...))
    end
  end
  print("c")
  return nxt(co.resume(thread))
end

local function create_thread()
  return co.create(function()
    local x = co.yield(1)
    print("x:", x)
    local y, z = co.yield(2, 3)
    print("y, z:", y, z)
  end)
end

-- TEST A ----------
local thread = create_thread()

-- pong(thread)

-- OUTPUT:
-- c
-- b
-- x: 1
-- b
-- y, z: 2 3
-- b
-- a

-- TEST B ----------
local thread = create_thread()

-- resume(thread)
-- resume(thread)
-- resume(thread)
-- resume(thread)

-- OUTPUT:
-- x: nil
-- y, z: nil nil

--
-- THUNK
--

-- local read_fs = function (file)
--   local thunk = function (callback)
--     fs.read(file, callback)
--   end
--   return thunk
-- end
--
-- local wrap = function (func)
--   local factory = function (...)
--     local params = {...}
--     local thunk = function (step)
--       table.insert(params, step)
--       return func(unpack(params))
--     end
--     return thunk
--   end
--   return factory
-- end
--
-- local thunk = wrap(fs.read)

local pong = function (func, callback)
  assert(type(func) == "function", "type error :: expected func")
  local thread = co.create(func)
  local step = nil
  step = function (...)
    local stat, ret = co.resume(thread, ...)
    print(ret())
    assert(stat, ret)
    if co.status(thread) == "dead" then
      (callback or function () end)(ret)
    else
      assert(type(ret) == "function", "type error :: expected func")
      ret(step)
    end
  end
  step()
end

local echo = function (...)
  local args = {...}
  local thunk = function (step)
    step(unpack(args))
  end
  return thunk
end

local test_func = function ()
  local x, y, z = co.yield(echo(1, 2, 3))
  print(x, y, z)
  local k, f, c = co.yield(echo(4, 5, 6))
  print(k, f, c)
end

pong(test_func)


--
-- LIBUV EXAMPLE
--

-- -- NOTE: yield is like a break point. when I put a yield in a coroutine, when
-- -- resuming the coroutine it will stop at the first yield
--
-- -- local uv = vim.loop
-- --
-- -- local async
-- --
-- -- async = uv.new_async(function()
-- --   uv.sleep(1000)
-- --   print "yoo, hello"
-- --   async:close()
-- -- end)
-- --
-- -- print "first"
-- -- async:send()
-- --
-- --

--
-- COROUTINES TUTORIAL
--


-- local co = coroutine.create(function()
--   print("hi")
-- end)
--
-- print(co) --> thread: 0x8071d98
--
-- print(coroutine.status(co))
-- coroutine.resume(co)
--
-- print("LOOPING")
--
-- local co = coroutine.create(function()
--   for i = 1, 10 do
--     print("co A", i)
--     coroutine.yield()
--     -- print("co B", i + 10)
--     -- coroutine.yield()
--   end
--   return "XXX"
-- end)
-- coroutine.resume(co) --> co   1
-- print("--")
-- print(coroutine.status(co)) --> suspended
-- coroutine.resume(co) --> co   2
-- print("--")
-- coroutine.resume(co) --> co   3
-- print("--")
-- coroutine.resume(co) --> co   4
-- coroutine.resume(co) --> co   5
-- coroutine.resume(co) --> co   6
-- coroutine.resume(co) --> co   7
-- coroutine.resume(co) --> co   8
-- coroutine.resume(co) --> co   9
-- coroutine.resume(co) --> co   10
-- print("last resume")
-- local ok, ret = coroutine.resume(co) --> co   1
-- print("ret", ret)
-- print(coroutine.status(co)) --> suspended
--
-- print("RESUME YIELD PAIRS")
-- -- A useful facility in Lua is that a pair resume-yield can exchange data between them. The first resume, which has no corresponding yield waiting for it, passes its extra arguments as arguments to the coroutine main function:
--
-- co = coroutine.create(function(a, b, c)
--   print("co", a, b, c)
-- end)
-- coroutine.resume(co, 1, 2, 3) --> co  1  2  3
--
-- -- A call to resume returns, after the true that signals no errors, any
-- -- arguments passed to the corresponding yield:
-- co = coroutine.create(function(a, b)
--   coroutine.yield(a + b, a - b)
-- end)
--
-- local res, a, b = coroutine.resume(co, 20, 10)
-- print(res) --> true  30  10
-- print(a, b)
-- local ares = assert(res)
-- print(a, b)
--
-- print("SYMMETRICALLY")
--
-- -- Symmetrically, yield returns any extra arguments passed to the corresponding resume:
-- co = coroutine.create(function()
--   print("co", coroutine.yield())
-- end)
-- coroutine.resume(co)
-- coroutine.resume(co, 4, 5) --> co  4  5
--
-- -- Finally, when a coroutine ends, any values returned by its main function go to the corresponding resume:
-- co = coroutine.create(function()
--   return 6, 7
-- end)
-- print(coroutine.resume(co)) --> true  6  7
--
-- -- We seldom use all these facilities in the same coroutine, but all of them
-- -- have their uses.
--
-- -- For those that already know something about coroutines, it is important to
-- -- clarify some concepts before we go on. Lua offers what I call asymmetric
-- -- coroutines. That means that it has a function to suspend the execution of a
-- -- coroutine and a different function to resume a suspended coroutine. Some
-- -- other languages offer symmetric coroutines, where there is only one function
-- -- to transfer control from any coroutine to another.
--
-- -- Some people call asymmetric coroutine semi-coroutines (because they are not
-- -- symmetrical, they are not really co). However, other people use the same
-- -- term semi-coroutine to denote a restricted implementation of coroutines,
-- -- where a coroutine can only suspend its execution when it is not inside any
-- -- auxiliary function, that is, when it has no pending calls in its control
-- -- stack. In other words, only the main body of such semi-coroutines can yield.
-- -- A generator in Python is an example of this meaning of semi-coroutines.
--
-- -- Unlike the difference between symmetric and asymmetric coroutines, the
-- -- difference between coroutines and generators (as presented in Python) is a
-- -- deep one; generators are simply not powerful enough to implement several
-- -- interesting constructions that we can write with true coroutines. Lua offers
-- -- true, asymmetric coroutines. Those that prefer symmetric coroutines can
-- -- implement them on top of the asymmetric facilities of Lua. It is an easy
-- -- task. (Basically, each transfer does a yield followed by a resume.)
