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

-- TELESCOPE HELPERS

local function create_prompt_title(opts)
  local res_str = settings.prompt_prefix
  if opts.selected_filetypes then
    res_str = res_str .. "for filetypes: (" .. table.concat(opts.selected_filetypes, ",") .. ")"
  else
    res_str = res_str .. "all available (loaded) for current filetype(s)"
  end
  return res_str
end

local function picker_get_state()
  local state = require("telescope.actions.state")
  local line = state.get_current_line()
  local fuzzy = state.get_selected_entry()
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
  local fts = vim.fn.getcompletion("", "filetype")
  table.insert(fts, "all")
  return fts
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

local function get_chosen_filetypes(prompt_bufnr)
  local chosen_filetypes = {}
  local selection = action_state.get_selected_entry()
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selection = picker:get_multi_selection()
  if #multi_selection > 1 then
    for _, v in pairs(multi_selection) do
      table.insert(chosen_filetypes, v[1])
    end
  else
    table.insert(chosen_filetypes, selection[1])
  end
  return chosen_filetypes
end

local function filetype_default_select(prompt_bufnr)
  local chosen_filetypes = get_chosen_filetypes(prompt_bufnr)
  close(prompt_bufnr)
  M.snippets_picker({
    selected_filetypes = chosen_filetypes,
  })
end

local function create_new_snip_for_filetype(prompt_bufnr, filetype)
  close(prompt_bufnr)
  if filetype == "" then
    print("Can't create snip for filetype == empty string")
    return
  end
  print("create new snip for filetype: " .. filetype)
  --    1. get default location to create new
  --    2. check for existing filetype dir / file
  --    3 create file
  --    4. insert boiler plate
  --    5. trigger helper snippet
end

-- show list of all available filetypes to nvim
M.filetype_picker = function(opts)
  opts = opts or {}
  local has_luasnip, _ = pcall(require, "luasnip")
  if has_luasnip then
    require("telescope.pickers")
      .new(opts, {
        prompt_title = settings.prompt_prefix .. "select filetype to act on",
        finder = require("telescope.finders").new_table({
          results = get_available_filetypes(),
        }),
        sorter = require("telescope.config").values.generic_sorter(opts),
        attach_mappings = function(_, map)
          map("i", "<CR>", filetype_default_select) -- show snippets for fuzzy selection
          map("n", "<CR>", filetype_default_select)
          map("i", "<C-e>", function(prompt_bufnr)
            local selection = action_state.get_selected_entry(prompt_bufnr)
            create_new_snip_for_filetype(prompt_bufnr, selection[1])
          end)
          map("i", "<C-l>", function(prompt_bufnr)
            local _, line = picker_get_state(prompt_bufnr)
            create_new_snip_for_filetype(prompt_bufnr, line)
          end)
          map("i", "<C-s>", function(prompt_bufnr)
            local fuzzy, _ = picker_get_state(prompt_bufnr)
            print("open picker for all files hosting selected ft: " .. fuzzy.value)
            -- ALT A
            --    1. reuse luasnips builtin for listing files by filetype
            --
            -- ALT B
            --    1. for all snippets
            --    2. get unique sources for filetype
            --    3. pipe into `file_picker`
          end)
          return true
        end,
      })
      :find()
  end
end

local function get_available_or_specific_fts(t_fts)
  local objs = {}
  local _, luasnip = pcall(require, "luasnip")

  local available = {}
  if t_fts then
    local all_available = luasnip.get_snippets()
    for _, ft in pairs(t_fts) do
      if all_available[ft] then
        available[ft] = all_available[ft]
      end
    end
  else
    available = luasnip.available()
  end

  -- P(available, { depth = 2 })

  for ft, t_snips in pairs(available) do
    for _, snippet in ipairs(t_snips) do
      table.insert(objs, {
        ft = ft ~= "" and ft or "-",
        context = snippet,
      })
    end
  end

  return objs
end

-- list snippets, either based on supplied filetypes,
-- or available for current buf.
M.snippets_picker = function(opts)
  opts = opts or {}
  local objs = {}
  local has_luasnip, luasnip = pcall(require, "luasnip")
  if has_luasnip then
    local prompt_title = create_prompt_title(opts)
    objs = get_available_or_specific_fts(opts.selected_filetypes)
    sort_snippet_entries(objs)

    local displayer = entry_display.create({
      separator = "| ",
      items = {
        { width = 4 },
        { width = 12 },
        { width = 24 },
        { width = 16 },
        { remaining = true },
      },
    })

    local make_display = function(entry)
      return displayer({
        entry.value.context.id,
        entry.value.ft,
        entry.value.context.name,
        { entry.value.context.trigger, "TelescopeResultsNumber" },
        filter_description(entry.value.context.name, entry.value.context.description),
      })
    end

    pickers
      .new(opts, {
        prompt_title = prompt_title,
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
        attach_mappings = function(_, map)
          -- SELECT DEFAULT
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
          -- EDIT SNIPPET
          map("i", "<C-e>", function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            local snip_source = require("luasnip.session.snippet_collection").get_source_by_snip_id(
              selection.value.context.id
            )
            if snip_source then
              require("luasnip.loaders").edit_snippet_files({
                target_snippet = selection.value.context,
              })
            else
              print("Snippet '" .. selection.value.context.name .. "'" .. " doesn't have a source.")
            end
          end)
          -- map("i", "<C-e>", function()
          --   print("add new snippet to same file as fuzzy snippet")
          --   -- TODO: ....
          --   --
          --   --  get source file
          --   --    find return table
          --   --      if prepend_new_snippets
          --   --        insert first/last
          --   --          execute snippet_creator_snippet
          -- end)
          -- map("i", "<C-a>", function()
          --   print("add snippet to same file right after fuzzy sel")
          -- end)

          return true
        end,
      })
      :find()
  end
end

return M

-- return telescope.register_extension({ exports = { luasnip = luasnip_fn, filter_null = filter_null, filter_description = filter_description, get_docstring = get_docstring } })
