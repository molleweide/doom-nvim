local whichkey = {}

-- TODO: remove the ugly border.

whichkey.settings = {
  leader = " ",
      ---@type false | "classic" | "modern" | "helix"
  preset = "classic",
      -- Delay before showing the popup. Can be a number or a function that returns a number.
      ---@type number | fun(ctx: { keys: string, mode: string, plugin?: string }):number
      delay = function(ctx)
        return ctx.plugin and 0 or 200
      end,
      -- ---@param mapping wk.Mapping
      -- filter = function(mapping)
      --   -- example to exclude mappings without a description
      --   -- return mapping.desc and mapping.desc ~= ""
      --   return true
      -- end,
      -- show a warning when issues were detected with your mappings
      notify = true,
      -- Start hidden and wait for a key to be pressed before showing the popup
      -- Only used by enabled xo mapping modes.
      ---@param ctx { mode: string, operator: string }
      defer = function(ctx)
        return ctx.mode == "V" or ctx.mode == "<C-V>"
      end,
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true, -- adds help for operators like d, y, ...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
  },
  -- This opt is deprecated it seems..
  -- operators = {
  --   d = "Delete",
  --   c = "Change",
  --   y = "Yank (copy)",
  --   ["g~"] = "Toggle case",
  --   ["gu"] = "Lowercase",
  --   ["gU"] = "Uppercase",
  --   [">"] = "Indent right",
  --   ["<lt>"] = "Indent left",
  --   ["zf"] = "Create fold",
  --   ["!"] = "Filter though external program",
  -- },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
    ellipsis = "…",
    -- set to false to disable all mapping icons,
    -- both those explicitely added in a mapping
    -- and those from rules
    mappings = true,
    --- See `lua/which-key/icons.lua` for more details
    --- Set to `false` to disable keymap icons from rules
    ---@type wk.IconRule[]|false
    rules = {},
    -- use the highlights from mini.icons
    -- When `false`, it will use `WhichKeyIcon` instead
    colors = true,
    -- used by key format
    keys = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>", -- binding to scroll up inside the popup
      Up = " ",
      Down = " ",
      Left = " ",
      Right = " ",
      C = "󰘴 ",
      M = "󰘵 ",
      D = "󰘳 ",
      S = "󰘶 ",
      CR = "󰌑 ",
      Esc = "󱊷 ",
      ScrollWheelDown = "󱕐 ",
      ScrollWheelUp = "󱕑 ",
      NL = "󰌑 ",
      BS = "󰁮",
      Space = "󱁐 ",
      Tab = "󰌒 ",
      F1 = "󱊫",
      F2 = "󱊬",
      F3 = "󱊭",
      F4 = "󱊮",
      F5 = "󱊯",
      F6 = "󱊰",
      F7 = "󱊱",
      F8 = "󱊲",
      F9 = "󱊳",
      F10 = "󱊴",
      F11 = "󱊵",
      F12 = "󱊶",
    },
  },
  key_labels = {
    ["<space>"] = "SPC",
    ["<cr>"] = "RET",
    ["<tab>"] = "TAB",
  },
  ---@type wk.Win.opts
      win = {
        -- don't allow the popup to overlap with the cursor
        no_overlap = true,
        -- width = 1,
        -- height = { min = 4, max = 25 },
        -- col = 0,
        -- row = math.huge,
        -- border = "none",
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
        title = true,
        title_pos = "center",
        zindex = 1000,
        -- Additional vim.wo and vim.bo options
        bo = {},
        wo = {
          -- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        },
      },
  layout = {
    height = { min = 20, max = 30 },
    spacing = 3,
    -- align = "left",
  },
  ignore_missing = true,
  hidden = {
    "<silent>",
    "<Cmd>",
    "<cmd>",
    "<Plug>",
    "call",
    "lua",
    "^:",
    "^ ",
  },
      show_help = true, -- show a help message in the command line for using WhichKey
      show_keys = true, -- show the currently pressed key and its label as a message in the command line
  -- Which-key automatically sets up triggers for your mappings.
      -- But you can disable this and setup the triggers manually.
      -- Check the docs for more info.
      ---@type wk.Spec
      triggers = {
        { "<auto>", mode = "nxsot" },
      },
      ---@type (string|wk.Sorter)[]
      --- Mappings are sorted using configured sorters and natural sort of the keys
      --- Available sorters:
      --- * local: buffer-local mappings first
      --- * order: order of the items (Used by plugins like marks / registers)
      --- * group: groups last
      --- * alphanum: alpha-numerical first
      --- * mod: special modifier keys last
      --- * manual: the order the mappings were added
      --- * case: lower-case first
  sort = { "local", "order", "group", "alphanum", "mod" },
      debug = false, -- enable wk.log in the current directory
}

whichkey.packages = {
  ["which-key.nvim"] = {
    "folke/which-key.nvim",
    -- commit = "e4fa445065a2bb0bbc3cca85346b67817f28e83e",
    event ="VeryLazy",
    -- keys = { "<leader>" },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}

-- TODO: Not happy with how messy the integrations are.  Refactor!
whichkey.configs = {}
whichkey.configs["which-key.nvim"] = function()
  vim.g.mapleader = doom.features.whichkey.settings.leader

  local wk = require("which-key")

  wk.setup(doom.features.whichkey.settings)

  local get_whichkey_integration = function()
    --- @type NestIntegration
    local module = {}
    module.name = "whichkey"

    local keymaps = {}

    local keymaps_v3 = {}

    --- Handles each node of the nest keymap config (except the top level)
    --- @param node NestIntegrationNode
    --- @param node_settings NestSettings
    module.handler = function(node, node_settings)
      -- Only handle <leader> keys, which key needs a 'Name' field
      if node.lhs:find("<leader>") == nil or node.name == nil then
        return
      end

      for _, v in ipairs(vim.split(node_settings.mode or "n", "")) do
        if keymaps[v] == nil then
          keymaps[v] = {}
        end

        -- If this is a keymap group
        if type(node.rhs) == "table" then
          keymaps[v][node.lhs] = { name = node.name }
          -- v3
          table.insert(keymaps_v3, {node.lhs, group = node.name})


          -- If this is an actual keymap
        elseif type(node.rhs) == "string" then
          keymaps[v][node.lhs] = { node.name }
          -- v3
          table.insert(keymaps_v3, {node.lhs, node.rhs, mode = v, desc = node.name})

        end

        -- build v3 keymap


      end


    end

    module.on_complete = function()
      -- print("v3")

      local count_mapping = "<leader>f"
      local count =0

      for _, v in ipairs(keymaps_v3) do
        if v[1] == count_mapping then
          count = count+1
        end
        -- P(v)
      end

      print("Count =", count)


      -- V1 mappings
      -- for k, v in pairs(keymaps) do
      --   -- print(k,vim.inspect(v))
      --   require("which-key").register(v, { mode = k })
      -- end
      -- V3 mappings
      -- P(keymaps_v3)
      require("which-key").add(keymaps_v3)
    end

    return module
  end

  local keymaps_service = require("doom.services.keymaps")
  local whichkey_integration = get_whichkey_integration()
  require("doom.utils.modules").traverse_loaded(
    doom.modules,
    function(node, stack)
      if node.type then
        local module = node
        if module.binds then
          keymaps_service.applyKeymaps(
            type(module.binds) == "function" and module.binds() or module.binds,
            nil,
            { whichkey_integration }
          )
        end
      end
    end
    )

end

return whichkey
