local make_title =  require("doom.modules.features.dui.make_title")
local make_results =  require("doom.modules.features.dui.make_results")

local doom_ui = {}

-- TODO:
--
--    -> CHECK OUT `LEGENDARY` SOURCE AND SEE HOW THE DISPLAYER IS CONFIGURED.
--
--    - sorters
--    - displayers
--    - native fuzzy
--    - properly use the options object
--    - ovrerride actions properly.
--    - refactor the `table-tree-flattener`
--        -> use same for settings trees, and flat package/cmd lists
--    -
--

local function i(x)
  print(vim.inspect(x))
end

local function goback(prompt_bufnr, map)
	  return map("i", "<C-z>", function(prompt_bufnr)
	    require("telescope.actions").close(prompt_bufnr)
	    -- print(doom_ui_state.history[1].title)
	    -- us.prev_hist()
	  end)
end

local function picker_get_state(prompt_bufnr)
  local state = require("telescope.actions.state")
  local line = state.get_current_line(prompt_bufnr)
  local fuzzy = state.get_selected_entry(prompt_bufnr)
  return fuzzy, line
end

-- TODO: make this dynamic / add display configs to each parts result maker.
function doom_displayer(entry)
  local entry_display = require("telescope.pickers.entry_display")
  local displayer = entry_display.create {
    separator = "▏",
    items = {
      { width = 10 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { remaining = true },
    },
  }
  local make_display = function(entry)
    return displayer(entry.value.list_display_props)
  end
	return {
	  value = entry,
	  display = make_display,
	  ordinal = entry.ordinal,
	}
end

-- can I redo this passing an `opts` table as arg and start follow the opts pattern
local function doom_picker(type, components)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions_set = require("telescope.actions.set")
  local state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local previewers = require("telescope.previewers")
  local title = make_title.get_title()
  local results = make_results.get_results_for_query()
  local opts = require("telescope.themes").get_ivy()
  -- i(results)
  -- print("picker -> query:", vim.inspect(doom_ui_state.query))
  -- print("picker -> title:", title)
  require("telescope.pickers").new(opts, {
    prompt_title = title,
    finder = require("telescope.finders").new_table({
      results = results,
      entry_maker = doom_displayer
    }),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)

      actions_set.select:replace(function()
	      local fuzzy, line = picker_get_state(prompt_bufnr)
	      require("telescope.actions").close(prompt_bufnr)
        fuzzy.value.mappings["<CR>"](fuzzy, line)
	    end)

	    map("i", "<C-a>", function()
	      local fuzzy, line = picker_get_state(prompt_bufnr)
	      require("telescope.actions").close(prompt_bufnr)
	      if fuzzy.value.mappings["<C-a>"] ~= nil then
	        fuzzy.value.mappings["<C-a>"](fuzzy, line)
	      end
	    end)

	    goback(prompt_bufnr, map)

      return true
    end,
    initial_mode = "insert",

  }):find()

end

-- TODO: read up on telescopes internal history maker.
doom_ui_state = {
    history = {},
    next = function()
      -- if doom_ui_state ~= nil then return end
    -- local old_query = vim.deepcopy(doom_ui_state.query)
    -- table.insert(doom_ui_state.history, 1, store)
    -- local hlen = #doom_ui_state.history
    -- if hlen > 10 then
    --   table.remove(doom_ui_state.history, hlen)
    -- end
	  doom_picker()
  end
  }

local function reset()
  doom_ui_state.query = nil
  doom_ui_state.selected_module = nil
  doom_ui_state.selected_component = nil
end

doom_ui.cmds = {
	{
	  "DoomPickerMain",
	  function()
      reset()
      doom_ui_state.query = {
        type = "main_menu",
      }
      doom_ui_state.next()
	  end
	},
	{
	  "DoomPickerModules",
	  function()
	    reset()
      doom_ui_state.query = {
        type = "modules",
      }
      doom_ui_state.next()
	  end,
	},
}

doom_ui.binds = {
  -- { "[n", ":DoomPickerMain<cr>", name = "doom main menu command"},
  {
    "<leader>",
    name = "+prefix",
    {
      -- TODO: this should be all mods + settings, so that everything can be reached.
      { "k", [[ :DoomPickerModules<cr> ]], name = "Browse modules", options = { silent = false }, },
      {
        "n",
        name = "+test",
        {
          { "l", [[ :DoomPickerMain<cr> ]], name = "main menu", options = { silent = false }, },
        },
      },
    },
  },
}

return doom_ui
