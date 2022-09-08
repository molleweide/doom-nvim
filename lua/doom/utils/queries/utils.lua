local crawl = require("doom.utils.tree").traverse_table

local query_utils = {}

--
-- CONVERT: ( LUA TABLE -> TS QUERY )
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
      if string.sub(k, 1, 1) == "_" then
        return indentation(s) .. k .. ":\n"
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
        for _, p in ipairs(u) do
          if type(p) == "string" then
            str = str .. " " .. p .. " "
          else
            str = str .. "("
            for _, q in ipairs(p) do
              str = str .. q .. " "
            end
            str = str .. ")"
          end
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

  return str
end

return query_utils
