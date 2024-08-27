-- TODO: Add doom compatability for `Jump to definition` for each entry so that
-- we can easilly jump to the exact location of the definition of a binding.
--
-- TODO: Rename this module to something more descriptive.
--
-- TODO: filter binds that dont have correct attributes in their definition,
-- so that you as a user can easilly go through existing bindigs and document
-- them properly.

local nest = {}

nest.description = [[
Responsible for loading user-defined mappings and setting up additional
mappings UIs.
]]

nest.settings = {}

nest.reload_binds = function()
  -- require("nvim-mapper").setup(doom.core.nest.settings)

  -- TODO: Not happy with how messy the integrations are, refactor!
  --
  -- TODO: Everything below should be exposed in a command so that we
  -- can reload or redo keybindings later, eg. in the reload module,
  -- currently, new bindings are not automatically added...
  --  >>> same with WHICHKEY!!!

  -- reset the global bindings array
  _G._doom.bindings_unique = {}
  _G._doom.bindings_array = {}

  local keymaps_service = require("doom.services.keymaps")

  local get_mapper_integration = function()
    local mapper_integration = { name = "mapper" }

    local unique_id_table = {}

    --- Tries to create a unique keymap id given a lhs, rhs and name
    --- lhs/rhs used as key
    --- @param lhs string
    --- @param rhs string
    --- @return string|nil
    local determine_uid = function(lhs, name, mode)
      -- Format name to snake case no punctuation
      local formatted_name = name:lower()
      formatted_name = formatted_name:gsub("%p", "")
      formatted_name = formatted_name:gsub("%s", "_")
      if mode ~= "" then
        formatted_name = formatted_name .. "_" .. mode
      end

      local n = formatted_name
      local i = 0
      -- If this command has already been added, return early
      if unique_id_table[n] == lhs then
        return nil
      end
      -- Find a free spot in the unique_id_table
      while unique_id_table[n] ~= nil and i < 50 do
        i = i + 1
        n = formatted_name .. "_" .. i
      end

      -- Add to table
      unique_id_table[n] = lhs

      return n
    end

    -- Categories are generated from the name of the parent keymap group
    local category_table = {}

    --- Adds categories to a table to be searched using get_category_for_command
    --- @param lhs string Left hand side string to trigger a keymap
    --- @param name string Name of keymap group
    local add_category = function(lhs, name)
      category_table[lhs] = name
    end
    --- Tries to determin the category of a keymap by finding the name of the parent group
    --- @param lhs string LHS string to trigger a keymap
    --- @return string|nil
    local get_category_for_command = function(lhs)
      local key = lhs:sub(1, -2)
      return category_table[key]
    end

    local Mapper = require("doom.modules.core.nest.nvim-mapper")

    --- @class NestMapperNode : NestIntegrationNode
    --- @field category string|nil
    --- @field uid string|nil

    --- @description Handles the each node in the nest tree.
    --- @param node NestMapperNode
    --- @param node_settings NestSettings
    mapper_integration.handler = function(node, node_settings, global_opts)
      if node.name == nil then
        return
      end

      if type(node.rhs) == "table" then
        -- If a name is provided, save the category
        local category = node.category or node.name
        add_category(node.lhs, category)
        return
      end

      local category = node.category or get_category_for_command(node.lhs) or "unknown"

      -- Fallback to name if description not provided
      local description = node.description or node.name

      -- Ensure all required values have been found
      if category == nil or description == nil then
        return
      end

      for mode in string.gmatch(node_settings.mode, ".") do
        local sanitizedMode = mode == "_" and "" or mode

        local id = node.uid or determine_uid(node.lhs, node.name, sanitizedMode)

        if id ~= nil then
          local rhs = type(node.rhs) == "function" and "<function>" or node.rhs
          if node_settings.buffer then
            Mapper.map_buf_virtual(
              sanitizedMode,
              node.lhs,
              rhs,
              node_settings.options,
              category,
              id,
              description,
              global_opts.module_origin
            )
          else
            Mapper.map_virtual(
              sanitizedMode,
              node.lhs,
              rhs,
              node_settings.options,
              category,
              id,
              description,
              global_opts.module_origin
            )
          end
        end
      end
    end
    return mapper_integration
  end

  local mapper_integration = get_mapper_integration()

  --
  -- Traverse modules and process mappings.
  --

  local profiler = require("doom.services.profiler")
  local count = 0
  require("doom.utils.modules").traverse_loaded(doom.modules, function(node, stack)
    if node.type then
      local module = node

      local t_path = vim.tbl_map(function(stack_node)
        return type(stack_node.key) == "string" and stack_node.key
      end, stack)

      local mod_path = table.concat(t_path, ".")

      if module.binds then
        count = count + 1
        vim.defer_fn(function()
          -- table.insert(all_keymaps, type(module.binds) == "function" and module.binds() or module.binds)
          local profiler_msg = ("keymaps(async)|module: %s"):format(mod_path)
          profiler.start(profiler_msg)

          keymaps_service.applyKeymaps(
            type(module.binds) == "function" and module.binds() or module.binds,
            _,
            { mapper_integration },
            { module_origin = mod_path }
          )

          profiler.stop(profiler_msg)
        end, count)
      end
    end
  end)
end

nest.cmds = {
  { "ReloadBindings", function() end },
}

nest.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "D",
        name = "+doom",
        {
          {
            "B",
            function()
              local has_telescope, telescope = pcall(require, "telescope")
              print("BROWSE BINDINGS")
              if not has_telescope then
                error("This action requires the telescope module.")
              end
              require("doom.modules.core.nest.mapper.main").mapper()
            end,
            name = "Browse bindings",
          },
        },
      },
    },
  },
}

return nest
