local lsp = {}

-- TODO: Formatter fallback if no LSP is found/connected.
-- fallback to gg=G

-- TODO: telescope -> LSPs
-- Take the LspInfo command and make a telescope version of it.

-- TODO: Rename module to `lsp_config`

-- TODO: Create a handler that ignores global variables from your doom config

-- TODO: create function/picker to manage active lsp servers.

-- https://github.com/onsails/lspkind.nvim

lsp.settings = {
  icons = {
    error = "",
    warn = "",
    hint = "",
    info = "",
  },
  severity_sort = true,
  virtual_text = true,
}

-- https://github.com/hinell/lsp-timeout.nvim
-- https://git.sr.ht/~whynothugo/lsp_lines.nvim

lsp.packages = {
  ["nvim-lspconfig"] = {
    "neovim/nvim-lspconfig",
    version = "*",
  },
}

lsp.configs = {}
lsp.configs["nvim-lspconfig"] = function()
  -- Lsp Symbols
  local signs = {
    Error = doom.features.lsp.settings.icons.error,
    Warn = doom.features.lsp.settings.icons.warn,
    Info = doom.features.lsp.settings.icons.info,
    Hint = doom.features.lsp.settings.icons.hint,
  }
  local hl = "DiagnosticSign"

  for severity, icon in pairs(signs) do
    local highlight = hl .. severity
    vim.fn.sign_define(highlight, {
      text = icon,
      texthl = highlight,
      numhl = highlight,
    })
  end

  -- TODO: add custom diagnostic handler here
  --  move custom handlers into their own file.

  vim.diagnostic.config({
    virtual_text = doom.features.lsp.settings.virtual_text,
    severity_sort = doom.features.lsp.settings.severity_sort,
    float = {
      show_header = false,
      border = "rounded",
    },
  })

  --
  -- HANDLERS
  --

  -- Border for lsp_popups
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = doom.settings.border_style,
  })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = doom.settings.border_style,
  })

  -- jump to the first definition automatically if the multiple defs are on the same line
  -- otherwise show a telescope selector
  -- from https://github.com/seblj/dotfiles/blob/014fd736413945c888d7258b298a37c93d5e97da/nvim/lua/config/lspconfig/handlers.lua
  vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
    if not result or vim.tbl_isempty(result) then
      vim.notify("[lsp]: Could not find definition", vim.log.levels.INFO)
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)

    if vim.tbl_islist(result) then
      local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
      local lnum, filename = results[1].lnum, results[1].filename
      for _, val in pairs(results) do
        if val.lnum ~= lnum or val.filename ~= filename then
          return require("telescope.builtin").lsp_definitions()
        end
      end
      vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
    else
      vim.lsp.util.jump_to_location(result, client.offset_encoding, false)
    end
  end

  -- symbols for autocomplete
  local kinds = {}
  for typ, icon in pairs(doom.features.lsp_cmp.settings.completion.kinds) do
    table.insert(kinds, " " .. icon .. " (" .. typ .. ") ")
  end
  vim.lsp.protocol.CompletionItemKind = kinds

  -- suppress error messages from lang servers
  vim.notify = function(msg, log_level, _)
    if msg:match("exit code") then
      return
    end
    if log_level == vim.log.levels.ERROR then
      vim.api.nvim_err_writeln(msg)
    else
      vim.api.nvim_echo({ { msg } }, true, {})
    end
  end
end

local function diagnostics_testing()
  print("--- DIAGNOSTIC TESTING ---")

  print("diagnostics i current buf=", vim.inspect(vim.diagnostic.count(0)))

  print("namespaces = ", vim.inspect(vim.diagnostic.get_namespaces()))

  print("Current diagnostics = ", vim.inspect(vim.diagnostic.get(0)))

  print("next = ", vim.inspect(vim.diagnostic.get_next()))

  -- TODO: Add a new virtual char to all diagnostics.

  print("--- DIAGNOSTIC TESTING END ---")
end

lsp.autocmds = {
  -- {
  --   "LspRequest",
  --   callback = function(args)
  --     local bufnr = args.buf
  --     local client_id = args.data.client_id
  --     local request_id = args.data.request_id
  --     local request = args.data.request
  --     local log = require("doom.utils.logging")
  --     log.info("REQUESt =", vim.inspect(request))
  --     -- if request.type == 'pending' then
  --     --   -- do something with pending requests
  --     --   track_pending(client_id, bufnr, request_id, request)
  --     -- elseif request.type == 'cancel' then
  --     --   -- do something with pending cancel requests
  --     --   track_canceling(client_id, bufnr, request_id, request)
  --     -- elseif request.type == 'complete' then
  --     --   -- do something with finished requests. this pending
  --     --   -- request entry is about to be removed since it is complete
  --     --   track_finish(client_id, bufnr, request_id, request)
  --     -- end
  --   end,
  -- },
}

lsp.binds = function()
  return {
    { "K", vim.lsp.buf.hover, name = "Show hover doc" },
    {
      "[d",
      function()
        vim.diagnostic.jump({ count = -1 })
      end,
      name = "Jump to prev diagnostic",
    },
    {
      "]d",
      function()
        vim.diagnostic.jump({ count = 1 })
      end,
      name = "Jump to next diagnostic",
    },
    {
      "g",
      {
        { "D", vim.lsp.buf.declaration,    "Jump to declaration" },
        { "d", vim.lsp.buf.definition,     name = "Jump to definition" },
        { "r", vim.lsp.buf.references,     name = "Jump to references" },
        { "I", vim.lsp.buf.implementation, name = "Jump to implementation" },
        { "a", vim.lsp.buf.code_action,    name = "Do code action" },
      },
    },
    {
      "<C-",
      {
        {
          "p>",
          function()
            vim.diagnostic.jump({ count = -1 })
          end,
          name = "Jump to prev diagnostic",
        },
        {
          "n>",
          function()
            vim.diagnostic.jump({ count = 1 })
          end,
          name = "Jump to next diagnostic",
        },
        {
          "k>",
          vim.lsp.buf.signature_help,
          name = "Show signature help",
        },
      },
    },
    {
      "<leader>",
      name = "+prefix",
      {
        {
          "c",
          name = "+code",
          {
            { "r", vim.lsp.buf.rename,          name = "Rename" },
            { "a", vim.lsp.buf.code_action,     name = "Do action" },
            { "t", vim.lsp.buf.type_definition, name = "Jump to type" },
            { "D", vim.lsp.buf.declaration,     "Jump to declaration" },
            {
              "k",
              name = "+diagnostics",
              {
                {
                  "t",
                  function()
                    diagnostics_testing()
                  end,
                  name = "diagnostics testing",
                },
              },
            },
            { "d", vim.lsp.buf.definition,     name = "Jump to definition" },
            { "R", vim.lsp.buf.references,     name = "Jump to references" },
            { "i", vim.lsp.buf.implementation, name = "Jump to implementation" },
            {
              "l",
              name = "+lsp",
              {
                { "i", "<cmd>LspInfo<CR>",    name = "Inform" },
                { "r", "<cmd>LspRestart<CR>", name = "Restart" },
                {
                  "R",
                  function()
                    vim.cmd([[
                                            :lua vim.lsp.stop_client(vim.lsp.get_clients())
                                            :edit
                                        ]])
                  end,
                  name = "Force reload",
                },
                { "s", "<cmd>LspStart<CR>", name = "Start" },
                { "d", "<cmd>LspStop<CR>",  name = "Disconnect" },
                {
                  "D",
                  "<cmd>lua vim.lsp.stop_client(vim.lsp.get_clients())<cr>",
                  name = "Stop all",
                },
                { "m", "<cmd>Mason<CR>",    name = "Mason" },
                { "M", "<cmd>MasonLog<CR>", name = "MasonLog" },
              },
            },
            {
              "d",
              name = "+diagnostics",
              {
                -- { "[", vim.diagnostic.goto_prev, name = "Jump to prev" },
                -- { "]", vim.diagnostic.goto_next, name = "Jump to next" },
                -- { "p", vim.diagnostic.goto_prev, name = "Jump to prev" },
                -- { "n", vim.diagnostic.goto_next, name = "Jump to next" },
                {
                  "L",
                  function()
                    vim.diagnostic.open_float(0, {
                      focusable = false,
                      border = doom.settings.border_style,
                    })
                  end,
                  name = "Line",
                },
                -- { "l", vim.diagnostic.setloclist, name = "Loclist" },
              },
            },
          },
        },
      },
    },
  }
end

return lsp
