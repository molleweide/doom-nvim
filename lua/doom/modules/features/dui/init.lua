-- -- utils
local utils = require("doom.utils")
local log = require("doom.utils.logging")
local crawl = require("doom.utils.tree").traverse_table
local fs = require("doom.utils.fs")

local ts = vim.treesitter

local txt = ts.get_node_text

local dui_utils = require("doom.modules.features.dui.utils")

-- -- dui
local components = require("doom.modules.features.dui.results")
-- local ax = require("doom.modules.features.dui.actions")

local doom_ui = {}

-- TODO

-- is default mode -> insert working properly now?
--
-- TODO:
--
--    - requires module `nui`
--
--
--    - NOTE: A LOT OF GOOD STUFF EXISTS IN `REFACTORING.NVIM`
--            consider migrating to using refactoring for all ts operations and
--            extend the plugin with our helpers.
--            Or maintain own codebase?
--
--    - center picker entries text
--    - list packages across all modules
--    - default telescope UI options.
--    - add `OPEN MODULES`
--
--    - config > add optional file preview to L/R
--        >>> look at how `litee` is configured to learn a smart config pattern.
--
--    - >>> MONITOR RUNNING AUTOCOMMANDS
--
--    - on module select -> browse module dir subfiles -> to make it easier to search and manage large modules.
--
--    - ADD SNIPPETS!!
--
--    - HISTORY -> configure `opts.history` to see if this can be used to navigate menus?
--      why? a good usecase of why history would be useful is for example if you inspect
--      a module and then want to return back to the modules list. ATM you have
--      to close dui and reopen it which is not good.
--
--    - implement nice distinguishing between entry lists and entry templates pattern,
--        so that creating or crawling and collecting nodes becomes more convenient.
--
--
--    - autocmds w/`once` prop seem to NOT SHOW in picker
--
--    - FIX: make sure `user` modules are listed.
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
--
--

-- UI: use a preview window + mappings legend window, so that each item
--        mappings per entry are shown properly.
--
--  each entry has different mappings so you need to have a nice
--  legend window.
--
--  I dunno how to achieve this layout
--   _______________________________
--  [_prompt_______________________]
--
--  ^---------------^ ^------------^
--  |pkg            | | preview    |
--  |pkg            | |            |
--  |...            | |            |
--  |bind###########| ^------------^  ( selected )
--  |bind           | ^------------^
--  |bind           | | mappings   |
--  |setting        | | legend     |
--  |...            | |            |
--  |...            | |            |
--  ^---------------^ ^------------^
--
--  toggle binds legend window.

doom_ui.settings = {
  inspect_entries_on_keypress = true,
  topts = {
    default = {
      initial_mode = "insert",
    },
    main_menu = {},
  },
  displayer_default = {
    separator = "▏",
    items = {
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { width = 20 },
      { remaining = true },
    },
  },
  picker_insert_mode_mappings = {
    "<C-;>",
    "<C-a>",
    "<C-d>",
    "<C-e>",
    "<C-f>",
    "<C-h>",
    "<C-i>",     -- does something.... duno what.
    "<C-l>",
    "<C-m>",     -- enter linked
    "<C-r>",     -- tries to access registers or something and this breaks telescope?!
    "<C-s>",
    "<C-v>",
    "<C-x>",
    "<C-y>",
    "<C-z>",     -- closes prompt??
    "<CR>",
    -- ,./
  },
}

doom_ui.packages = {
  ["nui.nvim"] = { "MunifTanjim/nui.nvim" },
}

-- local function goback(prompt_bufnr, map)
--   return map("i", "<C-z>", function(prompt_bufnr)
--     require("telescope.actions").close(prompt_bufnr)
--     -- print(DOOM_UI_STATE.history[1].title)
--     -- us.prev_hist()
--   end)
-- end

local function picker_get_state(prompt_bufnr)
  local state = require("telescope.actions.state")
  local line = state.get_current_line(prompt_bufnr)
  local fuzzy = state.get_selected_entry(prompt_bufnr)
  return fuzzy, line
end

local function picker_select_cr(prompt_bufnr)
  local fuzzy, line = picker_get_state(prompt_bufnr)
  require("telescope.actions").close(prompt_bufnr)
  fuzzy.value.mappings["<CR>"](fuzzy, line)
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- COMPILE ENTRIES
--

-- move entries to here????

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- MAKE RESULTS
--

-- returns telescope picker results table based on the ui query type
local function make_results()
  local results = {}

  if DOOM_UI_STATE.query.type == "MAIN_MENU" then
    results = crawl({
      tree = require("doom.modules.features.dui.results").main_menu().entries,
      filter = "list",
    })
  elseif DOOM_UI_STATE.query.type == "SHOW_DOOM_SETTINGS" then
    results = crawl({
      tree = doom.settings,
      leaf = (require("doom.modules.features.dui.results").settings)().entry_template,
      filter = "settings",
    })
  elseif DOOM_UI_STATE.query.type == "LIST_ALL_MODULES" then
    results = crawl({
      tree = require("doom.modules.features.dui.mod_utils").extend(),
      leaf = (require("doom.modules.features.dui.results").modules)().entry_template,
      filter = "doom_module_single",
    })

    -- todo: rename "SINGLE_MODULE"
  elseif DOOM_UI_STATE.query.type == "SHOW_SINGLE_MODULE" then
    crawl({
      tree = DOOM_UI_STATE.selected_module,
      filter = "list",
      leaf = function(_, k, v)
        -- TODO: use
        -- vim.tbl_contains(DOOM_UI_STATE.query.components or spec.module, k) then
        -- end
        if k == "settings" then
          results = crawl({
            tree = v,
            filter = "settings",
            leaf = require("doom.modules.features.dui.results")[k]().entry_template,
            acc = results,
          })
        elseif k == "binds" then
          results = crawl({
            tree = v,
            -- TODO: simplify this by just adding the string name for the subtable
            branch_next = function(v)
              return v.rhs
            end,
            leaf = (require("doom.modules.features.dui.results")[k])().entry_template,
            acc = results,
            filter = function(_, l, r)
              return type(r.val.rhs) ~= "table"
            end,
          })
        elseif k == "configs" or k == "packages" or k == "cmds" or k == "autocmds" then
          results = crawl({
            tree = v,
            filter = "list",
            leaf = (require("doom.modules.features.dui.results")[k])().entry_template,
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
    crawl({
      tree = require("doom.modules.utils").extend({
        -- TODO: get `user` to work here for origins
        origins = { "doom", "user" },
        sections = { "features" },
        names = { "git", "lsp", "dap" },
        enabled = true,
      }),
      filter = "doom_module_single",
      leaf = function(_, k, v)
        -- TODO: vim.tbl_contains(DOOM_UI_STATE.query.components or spec.components)
        -- I can assign results here inside of `node` or I could return entry if package.
        -- REMEMBER: ATTACH MODULE PARAMS TO COMPONENT
        if k == "packages" then
          results = crawl({
            tree = v,
            filter = "list",
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
  local results = make_results()                 --.get_results_for_query()
  local opts = DOOM_UI_STATE.query.topts or {}   -- require("telescope.themes").get_ivy()

  -- i(results)
  -- print("picker -> query:", vim.inspect(DOOM_UI_STATE.query))
  -- print("picker -> title:", title)

  require("telescope.pickers")
      .new(opts, {
        -------------------------------------------------------
        --
        -- todo: move this to a split function again.
        --
        -- this is not a good way of keeping it.
        prompt_title = (function()
          local title
          if DOOM_UI_STATE.query.type == "MAIN_MENU" then
            title = ":: MAIN MENU ::"
          elseif DOOM_UI_STATE.query.type == "SHOW_DOOM_SETTINGS" then
            title = ":: USER SETTINGS ::"
          elseif DOOM_UI_STATE.query.type == "LIST_ALL_MODULES" then
            title = ":: MODULES LIST ::"
          elseif DOOM_UI_STATE.query.type == "SHOW_SINGLE_MODULE" then
            local postfix = ""
            local morig = DOOM_UI_STATE.selected_module.origin
            local mfeat = DOOM_UI_STATE.selected_module.section
            local mname = DOOM_UI_STATE.selected_module.name
            local menab = DOOM_UI_STATE.selected_module.enabled
            local on = menab and "enabled" or "disabled"
            postfix = postfix
                .. "["
                .. morig
                .. ":"
                .. mfeat
                .. "] -> "
                .. mname
                .. " ("
                .. on
                .. ")"
            title = "MODULE_FULL: " .. postfix         -- make into const
          elseif DOOM_UI_STATE.query.type == "component" then
          elseif DOOM_UI_STATE.query.type == "all" then
          end
          return title
        end)(),
        -------------------------------------------------------
        finder = require("telescope.finders").new_table({
          results = results,
          entry_maker = function(entry)
            local entry_display = require("telescope.pickers.entry_display")
            -- print(vim.inspect(entry))
            local displayer = entry_display.create(
              components[entry.component_type]().displayer(entry)
              or doom_ui.settings.displayer_default
            )
            local make_display = function(display_entry)
              -- I can custom transform each entry here if I like. Eg. I could do the `char surrounding` here instead if inside each component config. What would be smart to do here?
              return displayer(display_entry.value.items)
            end
            return {
              value = entry,
              display = make_display,
              ordinal = entry.ordinal,
            }
          end,
        }),
        -------------------------------------------------------
        sorter = require("telescope.config").values.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          -- select entry w/<CR>
          actions_set.select:replace(function()
            local fuzzy, line = picker_get_state(prompt_bufnr)
            require("telescope.actions").close(prompt_bufnr)
            fuzzy.value.mappings["<CR>"](fuzzy, line)
          end)
          -- create `insert` mode mappings to each entries repective custom mappings
          for _, map_str in ipairs(doom_ui.settings.picker_insert_mode_mappings) do
            map("i", map_str, function()
              local fuzzy, line = picker_get_state(prompt_bufnr)
              require("telescope.actions").close(prompt_bufnr)
              if fuzzy.value.mappings[map_str] ~= nil then
                print("dui mappings")
                fuzzy.value.mappings[map_str](fuzzy, line)
              end
            end)
          end
          -- goback(prompt_bufnr, map)
          return true
        end,
        initial_mode = "insert",
      })
      :find()
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- ADD NEW DOOM MODULE
--

local function __modules_browser_wrap()
  local Path = require("pathlib")
  -- FIX: Move this back to the `dui` module.
  -- Follow all of the basics from the neovim plugin conventions
  --
  -- TODO: I need to visually make dirs vs mod become much clearer
  --
  -- TODO: include user modules
  -- TODO: If <CR> on `current` for dir AND no custom name string
  -- has bee provided, then prompt user for a new module name.
  -- parse / and create subdirs if required in `current`
  --
  -- TODO: binding to toggle modules visibility, ie. only show subdirs so
  -- that it becomes easier to navigate maybe.
  --
  -- TODO: migrate this to telescope?
  -- >> This is required if I want to be able to obtain the prompt string.
  --
  -- TODO: if is_module -> :e the file in vsplit to the right
  --
  -- TODO: toggle enabled_only modules

  -- TEST: Is subdirs already supported?

  ---Initialize new module from a target path and a user input name string.
  ---@param path_to any
  local function create_new_module_from_name(path_to)
    -- Recurse down to the target module leaf in ./modules.lua tree.
    -- The target segment is availble on args.mod_path_table.
    local function crud_handle_root_tree(args)
      print("-- crud in --", vim.inspect(args), args.node:type(), #args.mod_path_table)

      if #args.mod_path_table > 1 then
        local branch_string = args.mod_path_table[1]
        local branch
        for entry in args.node:iter_children() do
          if
              entry:type() == "field"
              and entry:named_child_count() == 2
              and txt(entry:named_child(0), args.buf) == branch_string
          then
            print("branch found =", txt(entry:named_child(0), args.buf))
            branch = entry:named_child(1)             -- the child table contr
            args.node = entry:named_child(1)
            table.remove(args.mod_path_table, 1)
          end
        end
        if not branch then
        end
        crud_handle_root_tree(args)
      elseif #args.mod_path_table == 1 then
        -- check for module leaf
        local leaf_str = args.mod_path_table[1]
        local leaf
        for c in args.node:iter_children() do
          if c:named() and c:named_child_count() == 1 then
            if
                (
                  c:type() == "comment"
                  and txt(c:named_child(), args.buf):match('-- "(%w-)",')
                  == leaf_str
                )
                or (
                  c:type() == "field"
                  and txt(c:named_child():named_child(), args.buf) == leaf_str
                )
            then
              leaf = c
            else
            end
          end
        end
        if not leaf then
          -- leaf does not exist -> add enabl/dis?
        else
          print(":: leaf found ::", txt(leaf, args.buf))
        end
        table.remove(args.mod_path_table, 1)
      else
        return
        -- error
      end
    end

    vim.ui.input(
      { prompt = string.format("Enter new name for module @ [%s]: ", path_to) },
      function(new_module_name)
        local new_init_file = path_to / new_module_name / "init.lua"
        local t_path_new_segment =
            vim.split(new_init_file:tostring():match("modules/(.-)/init.lua$"), "/")

        -- add module to root table
        --
        -- TODO: TS parse the root file so that we can add new modules to it.
        local rootfile = "modules.lua"
        local rootbuf = dui_utils.get_buf_handle(utils.find_config(rootfile))

        local parser = vim.treesitter.get_parser(rootbuf, "lua", {})
        local tree = parser:parse()[1]
        local root = tree:root()

        -- get the modules table constructor under the return statement
        local return_query = vim.treesitter.query.parse("lua", "(return_statement) @return")
        local return_node
        for id, capture_node, _ in return_query:iter_captures(root, rootbuf) do
          return_node = capture_node:named_child():named_child()
        end

        crud_handle_root_tree({
          -- action = "add",
          root = root,
          node = return_node,
          buf = rootbuf,
          mod_path_table = t_path_new_segment,
        })

        -- only load the new module

        -- Handle new path
        if false then
          -- make new path
          local ok = new_init_file:touch(Path.permission("rw-r--r--"), true)

          if ok then
            -- add module template string
            local pu = require("doom.modules.features.dui.templates")
            fs.write_file(
              new_init_file:tostring(),
              pu.gen_temp_from_mod_name(new_module_name),
              "w+"
            )

            -- optionally edit file
            vim.cmd(string.format("edit %s", new_init_file))
          end
        end
      end
    )
  end

  ---Recursive modules browser implemented with vim.ui.select()
  ---@param path_in string|nil: The dir that you wish to start from or doom modules base dir.
  local function modules_browser(path_in)
    local current_dir = Path(path_in or require("doom.core.system").doom_modules_path())
    local possible_choices = {
      current_dir,
    }
    for path in current_dir:iterdir({ depth = 1 }) do
      if path:is_dir() then
        table.insert(possible_choices, path)
      end
    end
    vim.ui.select(possible_choices, {
      prompt = string.format("[MODULES BROWSER](../%s/..)", current_dir:basename()),
      format_item = function(item)
        if item == current_dir then
          return string.format("current = %s", current_dir:basename())
        elseif type(item) == "table" then
          local is_module = false
          for path in item:iterdir({ depth = 1 }) do
            if path:match("init.lua$") then
              is_module = true
            end
          end
          return string.format("%s -> %s", is_module and "mod" or "dir", item:basename())
        end
      end,
    }, function(choice)
      -- TODO: Can I add keybind to toggle enabled here?
      -- Or do I need to migrate to a real picker?

      if not choice then
        return         -- eg. <esc>
      end
      if choice == current_dir then
        create_new_module_from_name(choice)
      else
        local is_module = false
        for path in choice:iterdir({ depth = 1 }) do
          if path:match("init.lua$") then
            is_module = true
          end
        end
        if is_module then
          vim.cmd(string.format("edit %s", choice / "init.lua"))
        else
          modules_browser(choice)
        end
      end
    end)
  end

  -- main
  modules_browser()
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
    "DoomModulesBrowser",
    function()
      __modules_browser_wrap()
    end,
  },
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
          winblend = 25,
          layout_config = {
            width = 0.4,
            center = {
              width = 0.4,
            },
          },
          selection_caret = "",
          initial_mode = "insert",
          -- border = false,
          -- todo: disable multible selection?
        },
      }       -- .exec_next() would be nice so that the uppercase keyword only is shown in one place.
      DOOM_UI_STATE.next()
    end,
  },
  {
    "DoomPickerModules",
    function()
      reset()
      -- NOTE: SINCE THIS QUERY IS USED IN MULTIPLE PLACES. QUERIES SHOULD BE MOVED INTO ITS OWN FILE.
      DOOM_UI_STATE.query = {
        type = "LIST_ALL_MODULES",         -- could be renamed to `LIST_MODULES_STATUS` since we are listing information about modules NOT modules from within modules, which would be `COMPONENTS`
        topts = {
          layout_config = {
            width = 0.8,
            center = {
              width = 0.8,
            },
          },
          -- selection_caret = "",
          initial_mode = "insert",
        },
      }
      DOOM_UI_STATE.next()
    end,
  },
  {
    "DoomModuleCreateNew",
    function()
      -- open nui for new name input...
      ax.m_create()
    end,
  },

  {
    "DoomModuleAddSetting",
    function()
      -- a. if inside of module.init or settings.lua
      --    open telescope settings picker for curr file.
      --      line -> specify table path and insert last value
      -- b. if outside of doom -> open doom menu
    end,
  },

  {
    "DoomModuleAddPackages",
    function()
      -- a. if inside of module.init
      --    open telescope packages for current module.
      --      process line str -> insert package
      --
      -- b. if outside of doom -> open doom modules browser
    end,
  },

  {
    "DoomModuleAddBind",
    function()
      -- INVESTIGATE DEFAULT CASES.
      -- 1. if current buf == module/init.lua file do action else open module browser.
      -- 2. `leader d a (c|a|b|p)`
    end,
  },

  {
    "DoomModuleCreateBindAtCursor",
    function()
      --  a. outside leader
      --        insert new bind after.
      --  b. inside leader
      --        find first parent branch or bind_field
      --          insert new bind after
    end,
  },

  { "DoomModuleCreateBindFromLine", function() end },

  -- more commands???
}

doom_ui.binds = {
  -- { "[n", ":DoomPickerMain<cr>", name = "doom main menu command"},
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "k",
        [[ :DoomPickerModules<cr> ]],
        name = "Browse modules",
        options = { silent = false },
      },
      {
        "z",
        name = "+test",
        {
          {
            "m",
            [[ :DoomPickerMain<cr> ]],
            name = "main menu",
            options = { silent = false },
          },
        },
      },
    },
    {
      "D",
      name = "+doom",
      {
        -- FIX: Why isnt this bind being loaded? Is nest loader doing some kind
        -- of overwrites?
        {
          "D",
          function()
            __modules_browser_wrap()
          end,
          name = "mod browse",
        },
      },
    },
  },
}

return doom_ui
