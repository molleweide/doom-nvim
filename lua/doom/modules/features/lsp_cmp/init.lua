local nvim_cmp = {}

-- TODO: Separate nvim-cmp from Luasnip/snippet engines.

-- TODO: Move each cmp source into its own file so that one can enable/disable
-- them in modules.lua
-- 1. Move each source into its own file
-- 2. Add a `cmp_source_name` key to each module that can be
--    filtered by traversing enabled modules.

--- Internal state of CMP module
-- Flag to enable/disable completions for <leader>tc keybind.
nvim_cmp.__completions_enabled = true

nvim_cmp.settings = {
  luasnip = {
    config = {
      history = true,
      store_meta_data = true,
      updateevents = "TextChanged,TextChangedI",
    },
    snippets_load_dirs = {
      "./lua/doom/snips/luasnippets",
      "./lua/user/snips/luasnippets",
    },
  },
  completion = {
    -- TODO: "kinds" should be moved into lsp_config since it is symbols that
    -- strictly pertain to LSP.
    kinds = {
      Text = " ",
      Method = " ",
      Function = " ",
      Constructor = " ",
      Field = "ﴲ ",
      Variable = " ",
      Class = " ",
      Interface = "ﰮ ",
      Module = " ",
      Property = "ﰠ ",
      Unit = " ",
      Value = " ",
      Enum = "練",
      Keyword = " ",
      Snippet = " ",
      Color = " ",
      File = " ",
      Reference = " ",
      Folder = " ",
      EnumMember = " ",
      Constant = "ﲀ ",
      Struct = "ﳤ ",
      Event = " ",
      Operator = " ",
      TypeParameter = " ",
    },
    experimental = {
      ghost_text = true,
    },
    completeopt = "menu,menuone,preview,noinsert",
    window = {
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    sources = {
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    },
  },
  sorting = {
    "offset",
    "exact",
    "score",
    "kind",
    "sort_text",
    "length",
    "order",
  },
}

nvim_cmp.packages = {
  ["nvim-cmp"] = {
    "hrsh7th/nvim-cmp",
    commit = "11a95792a5be0f5a40bab5fc5b670e5b1399a939",
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        -- commit = "53e812a6f51c9d567c98215733100f0169bcc20a",
        dev = false,
      },
    },
  },
  ["cmp-nvim-lua"] = {
    "hrsh7th/cmp-nvim-lua",
    commit = "f3491638d123cfd2c8048aefaf66d246ff250ca6",
    -- after = "nvim-cmp",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  ["cmp-nvim-lsp"] = {
    "hrsh7th/cmp-nvim-lsp",
    -- after = "nvim-cmp",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  ["cmp-path"] = {
    "hrsh7th/cmp-path",
    -- after = "nvim-cmp",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  ["cmp-buffer"] = {
    "hrsh7th/cmp-buffer",
    commit = "3022dbc9166796b644a841a02de8dd1cc1d311fa",
    -- after = "nvim-cmp",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  ["cmp_luasnip"] = {
    "saadparwaiz1/cmp_luasnip",
    commit = "18095520391186d634a0045dacaa346291096566",
    -- after = "nvim-cmp",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
}

nvim_cmp.configs = {}
nvim_cmp.configs["nvim-cmp"] = function()
  local utils = require("doom.utils")

  local cmp_ok, cmp = pcall(require, "cmp")

  -- FIX: Make cmp work even if no snippet engine exists.

  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not cmp_ok or not luasnip_ok then
    return
  end

  -- FIX: I have already moved this to luasnip module!!
  luasnip.config.set_config(doom.features.lsp_cmp.settings.luasnip.config)
  require("luasnip.loaders.from_lua").load({
    paths = doom.modules.features.lsp_cmp.settings.luasnip.snippets_load_dirs,
  })
  --------

  local replace_termcodes = utils.replace_termcodes

  --- Helper function to check what <Tab> behaviour to use
  --- @return boolean
  local function check_backspace()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
  end

  -- Initalize the cmp toggle if it doesn't exist.
  if _doom.cmp_enable == nil then
    _doom.cmp_enable = true
  end

  -- Fetch the comparators from cmp
  local comparators = require("cmp.config.compare")
  doom.features.lsp_cmp.settings.sorting = vim.tbl_map(function(comparator)
    return comparators[comparator]
  end, doom.features.lsp_cmp.settings.sorting)

  cmp.setup(vim.tbl_deep_extend("force", doom.features.lsp_cmp.settings.completion, {
    completeopt = nil,
    completion = {
      completeopt = doom.features.lsp_cmp.settings.completion.completeopt,
    },
    formatting = {
      format = function(entry, item)
        item.kind = string.format(
          "%s %s",
          doom.features.lsp_cmp.settings.completion.kinds[item.kind],
          item.kind
        )
        item.dup = vim.tbl_contains({ "path", "buffer" }, entry.source.name)
        return item
      end,
    },
    mapping = {
      [doom.settings.mappings.cmp.select_prev_item] = cmp.mapping.select_prev_item(),
      [doom.settings.mappings.cmp.select_next_item] = cmp.mapping.select_next_item(),
      [doom.settings.mappings.cmp.scroll_docs_bkw] = cmp.mapping.scroll_docs(-4),
      [doom.settings.mappings.cmp.scroll_docs_fwd] = cmp.mapping.scroll_docs(4),
      [doom.settings.mappings.cmp.complete] = cmp.mapping.complete(),
      [doom.settings.mappings.cmp.close] = cmp.mapping.close(),
      -- ["<ESC>"] = cmp.mapping.close(),
      [doom.settings.mappings.cmp.confirm] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
      [doom.settings.mappings.cmp.tab] = cmp.mapping(function(fallback)
        if cmp.visible() and doom.settings.cmp_cycle_entries_with_tab then
          cmp.select_next_item()
          -- TODO: if luasnip_ok
        elseif luasnip.expand_or_jumpable() then
          print("expand_or_jumpable")
          vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-expand-or-jump"), "")
        elseif check_backspace() then
          print("feedkeys")
          vim.fn.feedkeys(replace_termcodes("<Tab>"), "n")
        else
          print("fallback")
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      [doom.settings.mappings.cmp.stab] = cmp.mapping(function(fallback)
        if cmp.visible() and doom.settings.cmp_cycle_entries_with_tab then
          cmp.select_prev_item()
          -- TODO: if luasnip_ok
        elseif luasnip.jumpable(-1) then
          print("feedkeys")
          vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-jump-prev"), "")
        else
          print("fallback")
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    },
  }, {
    mapping = type(doom.features.lsp_cmp.settings.completion.mapping) == "function"
        and doom.features.lsp_cmp.settings.completion.mapping(cmp)
        or doom.features.lsp_cmp.settings.completion.mapping,
    enabled = function()
      return _doom.cmp_enable and vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
    end,
  }))
end

nvim_cmp.binds = function()
  return {
    {
      "<leader>",
      name = "+prefix",
      {
        {
          "t",
          name = "+tweak",
          {
            {
              "c",
              function()
                nvim_cmp.__completions_enabled = not nvim_cmp.__completions_enabled
                local bool2str = require("doom.utils").bool2str
                print(string.format("completion=%s", bool2str(nvim_cmp.__completions_enabled)))
              end,
              name = "Toggle completion",
            },
          },
        },
      },
    },
  }
end

return nvim_cmp
