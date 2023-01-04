local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

-- CREDITS; based on `https://github.com/benfowler/telescope-luasnip.nvim`

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local ext_conf = require("telescope._extensions")

local M = {}

local settings = {
  prompt_prefix = "LUASNIP (custom): ",
}

local function picker_get_state(prompt_bufnr)
  local state = require("telescope.actions.state")
  local line = state.get_current_line(prompt_bufnr)
  local fuzzy = state.get_selected_entry(prompt_bufnr)
  return fuzzy, line
end

local function close(prompt_bufnr)
  require("telescope.actions").close(prompt_bufnr)
end

local filter_null = function(str, default)
  return str and str or (default and default or "")
end

local filter_description = function(name, description)
  local result = ""
  if description and #description > 1 then
    for _, line in ipairs(description) do
      result = result .. line .. " "
    end
  elseif name and description and description[1] ~= name then
    result = description[1]
  end

  return result
end

local get_docstring = function(luasnip, ft, context)
  local docstring = {}
  if context then
    local snips_for_ft = luasnip.get_snippets(ft)
    if snips_for_ft then
      for _, snippet in pairs(snips_for_ft) do
        if context.name == snippet.name and context.trigger == snippet.trigger then
          local raw_docstring = snippet:get_docstring()
          if type(raw_docstring) == "string" then
            for chunk in string.gmatch(snippet:get_docstring(), "[^\n]+") do
              docstring[#docstring + 1] = chunk
            end
          else
            docstring = raw_docstring
          end
        end
      end
    end
  end
  return docstring
end

local default_search_text = function(entry)
  return filter_null(entry.context.trigger)
    .. " "
    .. filter_null(entry.context.name)
    .. " "
    .. entry.ft
    .. " "
    .. filter_description(entry.context.name, entry.context.description)
end

local function get_available_filetypes()
  return vim.fn.getcompletion("", "filetype")
end

local function sort_snippet_entries(t)
  table.sort(t, function(a, b)
    if a.ft ~= b.ft then
      return a.ft > b.ft
    elseif a.context.name ~= b.context.name then
      return a.context.name > b.context.name
    else
      return a.context.trigger > b.context.trigger
    end
  end)
end

M.luasnip_fn = function(opts)
  opts = opts or {}
  local objs = {}
  local has_luasnip, luasnip = pcall(require, "luasnip")
  if has_luasnip then
    if opts.picker_to_use == "filetype" then
      --
      -- SELECT FILETYPE
      --

      require("telescope.pickers")
        .new(opts, {
          prompt_title = settings.prompt_prefix .. "select filetype to act on",
          finder = require("telescope.finders").new_table({
            results = get_available_filetypes(),
          }),
          sorter = require("telescope.config").values.generic_sorter(opts),
          attach_mappings = function(_, map)
            local filetype_callback_mapping = function(prompt_bufnr)
              local fuzzy, line = picker_get_state(prompt_bufnr)
              close(prompt_bufnr)
              M.luasnip_fn({
                picker_to_use = "personal_snippets",
                luasnip_picker_filetype_selected = fuzzy,
                luasnip_picker_filetype_line = line,
              })
            end

            map("i", "<CR>", filetype_callback_mapping) -- show snippets for fuzzy selection
            map("n", "<CR>", filetype_callback_mapping)
            map("i", "<C-e>", function()
              print("create new snip for selected filetype(s)")
              -- TODO: ....
              --
              --    -- what does [0] return?
              --    use the doom.modules.features.extra_snippets.settings.luasnip_snippets.paths[1]
              --
              --    find filetype dir -> enter ft base file ->
            end)
            map("i", "<C-s>", function(prompt_bufnr)
              local fuzzy, _ = picker_get_state(prompt_bufnr)
              print("open picker for all files hosting selected ft: " .. fuzzy.value)
              -- TODO: ....
              --
              --
              --   just filter unique source files by ft.
              --    return list -> run file picker with preview. + custom prompt title.
            end)
            return true
          end,
        })
        :find()
    elseif opts.picker_to_use == "all_available" then
      --
      -- ALL AVAILABLE
      --

      local available = luasnip.available()
      for filename, file in pairs(available) do
        for _, snippet in ipairs(file) do
          table.insert(objs, {
            ft = filename ~= "" and filename or "-",
            context = snippet,
          })
        end
      end

      sort_snippet_entries(objs)

      local displayer = entry_display.create({
        separator = " ",
        items = {
          { width = 12 },
          { width = 24 },
          { width = 16 },
          { remaining = true },
        },
      })

      local make_display = function(entry)
        return displayer({
          entry.value.ft,
          entry.value.context.name,
          { entry.value.context.trigger, "TelescopeResultsNumber" },
          filter_description(entry.value.context.name, entry.value.context.description),
        })
      end

      pickers
        .new(opts, {
          prompt_title = settings.prompt_prefix .. "all available (loaded) for current filetype(s)",
          finder = finders.new_table({
            results = objs,
            entry_maker = function(entry)
              -- 1
              search_fn = ext_conf._config.luasnip and ext_conf._config.luasnip.search
                or default_search_text
              -- 2
              return {
                value = entry,
                display = make_display,
                ordinal = search_fn(entry),
                preview_command = function(_, bufnr)
                  local snippet = get_docstring(luasnip, entry.ft, entry.context)
                  vim.api.nvim_buf_set_option(bufnr, "filetype", entry.ft)
                  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, snippet)
                end,
              }
            end,
          }),

          previewer = previewers.display_content.new(opts),
          sorter = conf.generic_sorter(opts),
          attach_mappings = function()
            actions.select_default:replace(function(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("startinsert")
              vim.api.nvim_put({ selection.value.context.trigger }, "", true, true)
              if luasnip.expandable() then
                luasnip.expand()
              else
                print(
                  "Snippet '"
                    .. selection.value.context.name
                    .. "'"
                    .. "was selected, but LuaSnip.expandable() returned false"
                )
              end
              vim.cmd("stopinsert")
            end)
            return true
          end,
        })
        :find()
    elseif opts.picker_to_use == "personal_snippets" then
      --
      -- PERSONAL SNIPPETS
      --

      local prev_fuzzy = opts.luasnip_picker_filetype_selected
      local prev_line = opts.luasnip_picker_filetype_line

      local personal_snippets_by_ft = require("luasnip_snippets").get_snippets_flat({
        paths = { "doom/snippets", "user/snippets" },
        use_default_path = true,
        use_personal = true,
        use_internal = true,
        ft_use_only = { prev_fuzzy and prev_fuzzy.value },
      })

      local prompt_title
      if prev_fuzzy then
        prompt_title = settings.prompt_prefix .. "personal snippets for:" .. prev_fuzzy[1]
      else
        prompt_title = settings.prompt_prefix .. "personal snippets for: all"
      end

      local displayer = entry_display.create({
        separator = " ",
        items = {
          { width = 8 },
          { width = 24 },
          { width = 40 },
          { width = 16 },
          { remaining = true },
        },
      })

      -- TODO: dynamic number of items here
      --
      --
      -- filetype | name | mod_path | trig:? |
      --

      -- NOTE: i should be able to reuse the same previewer,
      --    ->>> i believe that the available func just exposes a subset
      --          of all params so it should be possible to improve the
      --          previewer and use it for both cases.

      local make_display = function(entry)
        return displayer({
          entry.value.snip.filetype,
          { entry.value.snip.name, "TelescopeResultsNumber" },
          entry.value.snip.origin_file_mod_path,
          { "context", "TelescopeResultsNumber" },
          "description",
        })
      end

      pickers
        .new(opts, {
          prompt_title = prompt_title,
          finder = finders.new_table({
            results = personal_snippets_by_ft,
            entry_maker = function(entry)
              -- search_fn = ext_conf._config.luasnip and ext_conf._config.luasnip.search
              --   or default_search_text
              return {
                value = entry,
                display = make_display,
                ordinal = entry.filetype,
                -- preview_command = function(_, bufnr)
                --   local snippet = get_docstring(luasnip, entry.ft, entry.context)
                --   vim.api.nvim_buf_set_option(bufnr, "filetype", entry.ft)
                --   vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, snippet)
                -- end,
              }
            end,
          }),
          attach_mappings = function(_, map)
            local filetype_callback_mapping = function(prompt_bufnr)
              local fuzzy, line = picker_get_state(prompt_bufnr)

              P(fuzzy.value, { depth = 1 })
              close(prompt_bufnr)
            end

            -- TODO: it would be nice if I could run the snippets from here as
            -- well. ls.execute or ls.pares/run???
            map("i", "<CR>", filetype_callback_mapping)
            map("n", "<CR>", filetype_callback_mapping)
            -- map("i", "<C-b>", go_back_to_filetype_selection) -- this one could be pretty nice
            map("i", "<C-e>", function()
              print("add new snippet to same file as fuzzy snippet")
              -- TODO: ....
              --
              --  get source file
              --    find return table
              --      if prepend_new_snippets
              --        insert first/last
              --          execute snippet_creator_snippet
            end)
            map("i", "<C-a>", function()
              print("add snippet to same file right after fuzzy sel")
            end)

            map("i", "<C-s>", function(prompt_bufnr)
              -- local fuzzy, _ = picker_get_state(prompt_bufnr)
              print("edit selected snippet")
              -- TODO: ....
              --
              -- get source file
              --    open source file
              --      find location of snippet
              --        put cursor to snip location
            end)
            return true
          end,
        })
        :find()
    end
  else
    print("LuaSnips is not available")
    return
  end
end -- end custom function

return M

-- return telescope.register_extension({ exports = { luasnip = luasnip_fn, filter_null = filter_null, filter_description = filter_description, get_docstring = get_docstring } })
