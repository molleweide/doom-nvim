local M = {}

local function i(x)
  print(vim.inspect(x))
end

--
-- SETTINGS (USER/MODULE)
--

-- M.settings_flattened = function(t_settings, flattened, stack)
--   local flattened = flattened or {}
--   local stack = stack or {}
--
--   for k, v in pairs(t_settings) do
--
--     if ut.is_sub_setting(k,v) then
--       -- recurse down
--       -- if type(k) == "number" then print("!!!!!!!!!!!!") end
--
--       -- print("SUB -> ", type(k), k, v)
--       -- print([[ recurse: (%s:%s), (%s:%s)]], type(k), k, type(v), v)
--
--       table.insert(stack, k)
--       flattened = M.settings_flattened(v, flattened, stack)
--
--     else
--
--       -- collect table_path back to setting in original table
--       local pc
--       if #stack > 0 then
--         pc = vim.deepcopy(stack)
--         table.insert(pc, k)
--       else
--         pc = { k }
--       end
--
--       -- REFACTOR: concat table_path
--       -- format each setting
--       local pc_display = table.concat(pc, ".")
--       local v_display
--       if type(v) == "table" then
--         local str = ""
--         for _, x in pairs(v) do
--           if type(x) == "table" then
--             str = str .. ", " .. "subt"
--           else
--             str = str .. ", " .. x
--           end
--         end
--         v_display = str -- table.concat(v, ", ")
--       else
--         v_display = tostring(v)
--       end
--
--       local entry = {
--         type = "module_setting",
--         data = {
--           table_path = pc,
--           table_value = v,
--         },
--         list_display_props = {
--           {"SETTING"},
--           {pc_display},
--           {v_display}
--         },
--         ordinal = pc_display,
--         mappings = {
--           ["<CR>"] = function(fuzzy,line, cb)
--             i(fuzzy)
--             -- DOOM_UI_STATE.query = {
--             --   type = "settings",
--             -- }
--             -- DOOM_UI_STATE.next()
--   		    end
--         }
--       }
--       table.insert(flattened, entry)
--
--     end
--   end
--
--   table.remove(stack, #stack)
--
--   return flattened
-- end

M.mr_settings = function(stack, k, v)
  -- collect table_path back to setting in original table
  local pc
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, k)
  else
    pc = { k }
  end
  -- REFACTOR: concat table_path
  -- format each setting
  local pc_display = table.concat(pc, ".")
  local v_display
  if type(v) == "table" then
    local str = ""
    for _, x in pairs(v) do
      if type(x) == "table" then
        str = str .. ", " .. "subt"
      else
        str = str .. ", " .. x
      end
    end
    v_display = str -- table.concat(v, ", ")
  else
    v_display = tostring(v)
  end
  return {
    type = "module_setting",
    data = {
      table_path = pc,
      table_value = v,
    },
    list_display_props = {
      { "SETTING" },
      { pc_display },
      { v_display },
    },
    ordinal = pc_display,
    mappings = {
      ["<CR>"] = function(fuzzy, line, cb)
        i(fuzzy)
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
end

return M
