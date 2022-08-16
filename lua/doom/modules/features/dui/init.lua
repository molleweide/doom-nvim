local make_title = require("doom.modules.features.dui.make_title")
-- local ut = require("doom.modules.features.dui.utils")
local tree = require("doom.utils.tree")

local res_modules = require("doom.modules.features.dui.edge_funcs.modules")
local res_main = require("doom.modules.features.dui.edge_funcs.main")
local res_settings = require("doom.modules.features.dui.edge_funcs.settings")

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
    -- print(DOOM_UI_STATE.history[1].title)
    -- us.prev_hist()
  end)
end

local function picker_get_state(prompt_bufnr)
  local state = require("telescope.actions.state")
  local line = state.get_current_line(prompt_bufnr)
  local fuzzy = state.get_selected_entry(prompt_bufnr)
  return fuzzy, line
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- MAKE DISPLAY
--

-- TODO: make this dynamic / add display configs to each parts result maker.
local function doom_displayer(entry)
  local entry_display = require("telescope.pickers.entry_display")
  local displayer = entry_display.create({
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
  })
  local make_display = function(entry)
    return displayer(entry.value.list_display_props)
  end
  return {
    value = entry,
    display = make_display,
    ordinal = entry.ordinal,
  }
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- MAKE RESULTS
--

local function make_results()
  local results = {}

  if DOOM_UI_STATE.query.type == "main_menu" then
    for _, entry in ipairs(res_main.main_menu_flattened()) do
      table.insert(results, entry)
    end
    -- results = tree.traverse_table({
    --   tree = doom.settings,
    --   -- type = "settings",
    --   leaf = res_settings.mr_settings,
    --   edge = function(_, l, r)
    --     return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
    --   end,
    -- })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "settings" then
    results = tree.traverse_table({
      tree = doom.settings,
      leaf = res_settings.mr_settings,
      edge = function(_, l, r)
        return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
      end,
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "modules" then
    results = tree.traverse_table({
      tree = res_modules.get_modules_extended(),
      edge = "doom_module_single",
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "module" then
    tree.traverse_table({
      tree = DOOM_UI_STATE.selected_module,
      leaf = function(_, k, v)
        -- TODO: REMEMBER TO PASS ALONG THE `RESULTS` TABLE

        if k == "settings" then
          results = tree.traverse_table({
            tree = v,
            leaf = function(_, l, _)
              require("doom.modules.features.dui.edge_funcs." .. k)
            end,
            edge = function(_, l, r)
              -- REFACTOR:
              -- 1. rename edge modules to `doom_components`
              -- 2. move these edge into the entry maker modules
              return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
            end,
          })
        elseif k == "binds" then
          -- results = tree.traverse_table({
          --   tree = v,
          --   leaf = function(_, l, _)
          --     require("doom.modules.features.dui.edge_funcs." .. k)
          --   end,
          --   -- edge = function() end,
          -- })
        elseif k == "configs" or k == "packages" or k == "cmds" or k == "autocmds" then
          results = tree.traverse_table({
            tree = v,
            leaf = function()
              require("doom.modules.features.dui.edge_funcs." .. k)
            end,
            edge = function()
              return true
            end,
          })
        end
      end,
      edge = function()
        return true
      end,
    })

    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "component" then
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "all" then
  end

  return results
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- PICKER
--

-- can I redo this passing an `opts` table as arg and start follow the opts pattern
local function doom_picker()
  local actions_set = require("telescope.actions.set")
  local title = make_title.get_title()
  local results = make_results() --.get_results_for_query()
  local opts = require("telescope.themes").get_ivy()

  -- i(results)

  print("picker -> query:", vim.inspect(DOOM_UI_STATE.query))
  -- print("picker -> title:", title)

  require("telescope.pickers").new(opts, {
    prompt_title = title,
    finder = require("telescope.finders").new_table({
      results = results,
      entry_maker = doom_displayer,
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

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- UI STATE
--

DOOM_UI_STATE = {
  history = {},
  next = function()
    -- if DOOM_UI_STATE ~= nil then return end
    -- local old_query = vim.deepcopy(DOOM_UI_STATE.query)
    -- table.insert(DOOM_UI_STATE.history, 1, store)
    -- local hlen = #DOOM_UI_STATE.history
    -- if hlen > 10 then
    --   table.remove(DOOM_UI_STATE.history, hlen)
    -- end
    doom_picker()
  end,
}

local function reset()
  DOOM_UI_STATE.query = nil
  DOOM_UI_STATE.selected_module = nil
  DOOM_UI_STATE.selected_component = nil
end

doom_ui.cmds = {
  {
    "DoomPickerMain",
    function()
      reset()
      DOOM_UI_STATE.query = {
        type = "main_menu",
      }
      DOOM_UI_STATE.next()
    end,
  },
  {
    "DoomPickerModules",
    function()
      reset()
      DOOM_UI_STATE.query = {
        type = "modules",
      }
      DOOM_UI_STATE.next()
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
      {
        "k",
        [[ :DoomPickerModules<cr> ]],
        name = "Browse modules",
        options = { silent = false },
      },
      {
        "n",
        name = "+test",
        {
          { "l", [[ :DoomPickerMain<cr> ]], name = "main menu", options = { silent = false } },
        },
      },
    },
  },
}

return doom_ui
