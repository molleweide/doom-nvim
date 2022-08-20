-- local pickers = require("telescope.pickers")
-- local finders = require("telescope.finders")
-- local conf = require("telescope.config").values -- allows us to use the values from the users config
-- local entry_display = require("telescope.pickers.entry_display")
-- local actions_set = require("telescope.actions.set")
-- local state = require("telescope.actions.state")
-- local previewers = require("telescope.previewers")

local tree = require("doom.utils.tree")
local components = require("doom.modules.features.dui.results")
local doom_ui = {}

-- is default mode -> insert working properly now?
--
-- TODO:
--
--    - 1. impl `component` table pattern
--    - 2. capitalize query types so that I know what I am dealing with.
--    - 3. list packages across all modules
--    - history -> configure `opts.history` to see if this can be used to navigate menus?
--
--    MAPPINGS: write a cb that facilitates per entry mappings.
--    i. create an issue and ask about this feature, if this is already impl.
--    ii. show my use case and see what response I'll get.
--
--    - 1. CRUD
--    - 2. visually select the node inside of corresponding module file
--    - 3. custom legend depending on what entry is under cursor
--
--    -> CHECK OUT `LEGENDARY` SOURCE AND SEE HOW THE DISPLAYER IS CONFIGURED.
--
--  NOTE: SCREEN RECORD GIF AND POST MY PROGRESS UNDER DOOM-NVIM
--
--
-- QUESTIONS:
--
-- @max397
--
--
--    show multiple types of data -> dynamic mappings per entry.
--
--    Do you have any suggestions on how to attach
--    custom mappings on a `per results entry` basis in a slim and nice way?
--    Eg if you list all module components. how do I pass each results mapping
--    to each entry mapping?
--    So that eg. <C-a> would execute a different mapping for each component entry.

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
-- -> add a callback to each doom component
local function doom_displayer(entry)
  local entry_display = require("telescope.pickers.entry_display")

  local default = {
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

  -- entry_display.create(components[x] or default {...})
  -- print(entry.component_type)
  -- entry_display.create((components[entry.component_type]()).displayer(entry) or default)
  local comp_disp = components[entry.component_type]()
  local displayer = entry_display.create(comp_disp.displayer(entry) or default)

  local make_display = function(display_entry)
    -- I can custom transform each entry here if I like.
    -- Eg. I could do the `char surrounding` here instead if inside each
    -- component config. What would be smart to do here?
    return displayer(display_entry.value.items)
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
-- MAKE TITLE
--

-- how can this be put into the main picker???
local function make_title()
  local title

  if DOOM_UI_STATE.query.type == "MAIN_MENU" then
    title = ":: MAIN MENU ::"
  elseif DOOM_UI_STATE.query.type == "SHOW_DOOM_SETTINGS" then
    title = ":: USER SETTINGS ::"
  elseif DOOM_UI_STATE.query.type == "LIST_ALL_MODULES" then
    title = ":: MODULES LIST ::"

    -- TODO: MODULES LIST (ORIGINS/CATEGORIES)
  elseif DOOM_UI_STATE.query.type == "SHOW_SINGLE_MODULE" then
    local postfix = ""
    local morig = DOOM_UI_STATE.selected_module.origin
    local mfeat = DOOM_UI_STATE.selected_module.section
    local mname = DOOM_UI_STATE.selected_module.name
    local menab = DOOM_UI_STATE.selected_module.enabled
    local on = menab and "enabled" or "disabled"
    postfix = postfix .. "[" .. morig .. ":" .. mfeat .. "] -> " .. mname .. " (" .. on .. ")"
    title = "MODULE_FULL: " .. postfix -- make into const
  elseif DOOM_UI_STATE.query.type == "component" then
    -- TODO: MODULES LIST (/CATEGORIES)
  elseif DOOM_UI_STATE.query.type == "all" then
    -- TODO: MODULES LIST (/CATEGORIES)
  end

  return title
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- MAKE RESULTS
--

-- returns telescope picker results table based on the ui query type
local function make_results()
  local results = {}

  -- TODO: "MAIN_MENU"
  if DOOM_UI_STATE.query.type == "MAIN_MENU" then
    results = tree.traverse_table({
      tree = require("doom.modules.features.dui.results").main_menu().entries,
      edge = "list",
    })

    -- TODO: "DOOM_SETTINGS"
  elseif DOOM_UI_STATE.query.type == "SHOW_DOOM_SETTINGS" then
    results = tree.traverse_table({
      tree = doom.settings,
      leaf = require("doom.modules.features.dui.results").settings,
      edge = "settings",
    })
    -- TODO: RENAME "LIST_ALL_MODULES"
  elseif DOOM_UI_STATE.query.type == "LIST_ALL_MODULES" then
    results = tree.traverse_table({
      tree = require("doom.modules.utils").extend(),
      leaf = require("doom.modules.features.dui.results").modules,
      edge = "doom_module_single",
    })

    -- todo: rename "SINGLE_MODULE"
  elseif DOOM_UI_STATE.query.type == "SHOW_SINGLE_MODULE" then
    tree.traverse_table({
      tree = DOOM_UI_STATE.selected_module,
      edge = "list",
      leaf = function(_, k, v)
        -- TODO: use
        -- vim.tbl_contains(DOOM_UI_STATE.query.components or spec.module, k) then
        -- end
        if k == "settings" then
          results = tree.traverse_table({
            tree = v,
            edge = "settings",
            leaf = require("doom.modules.features.dui.results")[k],
            acc = results,
          })
        elseif k == "binds" then
          results = tree.traverse_table({
            tree = v,
            -- TODO: simplify this by just adding the string name for the subtable
            branch_next = function(v)
              return v.rhs
            end,
            leaf = require("doom.modules.features.dui.results")[k],
            acc = results,
            edge = function(_, l, r)
              return type(r.val.rhs) ~= "table"
            end,
          })
        elseif k == "configs" or k == "packages" or k == "cmds" or k == "autocmds" then
          results = tree.traverse_table({
            tree = v,
            edge = "list",
            leaf = require("doom.modules.features.dui.results")[k],
            acc = results,
          })
        end
      end,
    })

    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "MULTIPLE_MODULES" then
    -- 1. select components set
    -- 2. how do I attach the corresponding `module` into each component entry?
    tree.traverse_table({
      tree = require("doom.modules.utils").extend({
        origins = { "doom" },
        sections = { "features" },
        names = { "git", "lsp", "dap" },
        enabled = true,
      }),
      edge = "doom_module_single",
      leaf = function(_, k, v)
        -- TODO: vim.tbl_contains(DOOM_UI_STATE.query.components or spec.components)
        -- I can assign results here inside of `leaf` or I could return entry if package.
        -- REMEMBER: ATTACH MODULE PARAMS TO COMPONENT
        if k == "packages" then
          results = tree.traverse_table({
            tree = v,
            edge = "list",
            leaf = require("doom.modules.features.dui.results")[k],
            acc = results,
          })
        end
      end,
    })

    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
    -- feels like this should be a special case of the above "MULT/SINGLE"
  elseif DOOM_UI_STATE.query.type == "all" then
    -- todo: list everything!
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
  local title = make_title()
  local results = make_results() --.get_results_for_query()
  local opts = DOOM_UI_STATE.query.topts or {} -- require("telescope.themes").get_ivy()

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

      -- TODO: custom entry mappings AND function that maps entries to keys here.
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

-- QUERY DEFINITION
--
--  {
--    type, -- determines what types of data should be collected for listing in the picker.
--    topts, -- telescope config overrides
--    filters,
--  }

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
  -- TODO: traverse the ui state and nullify all entries.
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
        type = "MAIN_MENU",
        topts = {
          -- TODO: READ DOCS AND CHANGE AS MANY PARAMS HER AS POSSIBLE TO SEE HOW I CAN CUSTOMIZE A PICKER ON THE FLY.
          -- how can one center the text as to make a centered menu on screen.
          -- NOTE: IS IT POSSIBLE TO SET THE MATCH_CHAR_COLOR???
          -- theme = require("telescope.themes").get_cursor(),
          layout_stategy = "center",
          winblend = 0,
          layout_config = { width = 0.4, center = {
            width = 0.4,
          } },
          selection_caret = "",
          -- todo: disable multible selection?
        },
      } -- .exec_next() would be nice so that the uppercase keyword only is shown in one place.
      DOOM_UI_STATE.next()
    end,
  },
  {
    "DoomPickerModules",
    function()
      reset()
      DOOM_UI_STATE.query = {
        type = "LIST_ALL_MODULES", -- could be renamed to `LIST_MODULES_STATUS` since we are listing information about modules NOT modules from within modules, which would be `COMPONENTS`
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
