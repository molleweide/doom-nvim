local crawl = require("doom.utils.tree").traverse_table

local query_utils = {}

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
    branch = function(s, k, v)

      -- TODO:
      --    handle conditional case [ ... ] @ arst

      if string.sub(k, 1, 1) == "_" then
        return indentation(s) .. string.sub(k, 2, -1) .. ":\n"
      else
        return indentation(s) .. "(" .. k .. "\n"
      end
    end,
    node = function(_, _, v)
      return { pass_up = v }
    end,
    branch_post = function(s, k, v, u)
      local str = "" .. indentation(s)
      local first = string.sub(k, 1, 1)

      if first ~= "_" then
        str = str .. ")"
      end

      if u then
        -- capture
        if u[1] then
          str = str .. " " .. u[1] .. " "
        end

        -- sexpr
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

  local str = ""
  for k, v in ipairs(results) do
    str = str .. v
  end

  -- print("parse:", str)

  return str
end

return query_utils
