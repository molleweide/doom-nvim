local crawl = require("doom.utils.tree").traverse_table

local query_utils = {}

--
-- MOVE THESE TO REGEX UTILS > COMPOSABLE LIB
--

local function match(string, check_str)
  return string.match(string, check_str)
end

local function starts_w(str, check)
  return match(str, "^" .. check)
end

local function ends_w(str, check)
  return match(str, check .. "$")
end

--
-- PARSER HELPERS
--

local function b_pre(s, k, v) end
local function b_post(s, k, v, u) end

--
-- CONVERT: ( TS LUA -> TS QUERY )
--

-- NOTE: IF I WANT A SINGLE FIELD TO END UP ON A SINGLE LINE.
--        then I need to make the accumulator accessible. so that
--        we can crop backwards if we need to.
--

query_utils.parse = function(query)
  local function indentation(stack, sep, mult)
    local a = ""
    local b = ""
    sep = sep or " "
    mult = mult or 2
    for _ = 1, #stack do
      a = a .. sep
    end
    for _ = 1, mult do
      b = b .. a
    end
    return b
  end

  local results = crawl({
    tree = query,
    branch = function(s, k, v) -- pre
      local str = "" .. indentation(s)
      local und = "_"
      local any = "__any"
      local any_len = string.len(any)
      if not starts_w(k, und) then
        -- (xxx)
        if ends_w(k, und) then
          str = str .. "(" .. string.sub(k, 1, -2) .. "\n"
        else
          str = str .. "(" .. k .. "\n"
        end
      else
        -- xxx:
        if ends_w(k, und) then
          str = str .. string.sub(k, 2, -2) .. ":\n"
        end
        if ends_w(k, any) then
          str = str .. string.sub(k, 2, string.len(k) - any_len) .. ": [\n"
        end
        -- if ends_w(k, "__any") then
        --
      end
      return str
    end,
    node = function(_, _, v)
      return { pass_up = v }
    end,
    branch_post = function(s, k, v, u) -- post
      -- return branch_post(s,k,v,u)
      -- local post = ends_w(k, "__any") and "]" or ")"

      local str = "" .. indentation(s)
      -- local first = string.sub(k, 1, 1)

      -- end encloser
      if not starts_w(k, "_") then
        str = str .. ")"
      else
      end

      if u then
        -- add capture
        if u[1] then
          str = str .. " " .. u[1] .. " "
        end

        -- add sexpr
        if u[2] then
          str = str .. string.format([[(#%s? %s "%s")]], u[2], u[3], u[4])
        end
      end

      str = str .. "\n"
      return str
    end,
    filter = function(_, l, r)
      -- k = {} is a branch
      return not (l.is_str and r.is_tbl)
    end,
    log = {
      use = true,
      mult = 4,
      name_string = "query parser",
      cat = 2,
      inspect = true,
      new_line = true,
      frame = true,
      separate = true,
    },
  })

  -- TODO: THIS COULD BE ADDED TO THE `TREE` -> CONCAT OUTPUT
  local str = ""
  for k, v in ipairs(results) do
    str = str .. v
  end

  -- print("parse:", str)

  return str
end

return query_utils
