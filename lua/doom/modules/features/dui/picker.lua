local pickers = require("telescope.pickers")

local action_state = require("telescope.actions.state")

local dui_picker = {}

-- local function default(check, default_value)
--     if opts[check] == nil then
--         if type(default_value) == "function" then
--             opts[check] = default_value()
--         else
--             opts[check] = default_value
--         end
--     end
-- end

dui_picker.picker = function(opts, current_picker_bufnr)
    opts = opts or require("doom.modules.features.dui.pickers.main")
    local picker_utils = require("doom.modules.features.dui.pickers.utils")

    -- get the picker by name
    if type(opts) == "string" then
        opts = require("doom.modules.features.dui.pickers." .. opts)
    end

    -- if func
    if type(opts) == "function" then
        opts = opts()
    end

    -- if open, refresh to next picker
    local current_picker = action_state.get_current_picker(current_picker_bufnr)
    if current_picker then
        picker_utils:switch_picker(current_picker, opts)
    else
        pickers.new(opts):find()
    end
end

return dui_picker
