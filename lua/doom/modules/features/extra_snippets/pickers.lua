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

-- TODO: luasnip filetype
--
--    1. open filetype picker.
--    2. if select filetype > open below picker with only snippets coming
--          from the corresponding filetype.
--          confige -> set which paths one want to source snippets from.
--                so tha you don't accidentally start editing internal snippets.
--                only user snippets by default.
--
--
--
--    3. if delete snippet -> open nui popup yes/no

-- RENAME: LUASNIP INSERT SNIPPET
M.luasnip_fn = function(opts)
  opts = opts or {}
  local objs = {}

  -- Account for the fact that luasnip may be lazy-loaded
  local has_luasnip, luasnip = pcall(require, "luasnip")
  if has_luasnip then

    -- READ: how does this function work??
    --
    --      this is a good way to toggle between local and all available snips.
    local available = luasnip.available()

    for filename, file in pairs(available) do
      for _, snippet in ipairs(file) do
        table.insert(objs, {
          ft = filename ~= "" and filename or "-",
          context = snippet,
        })
      end
    end
  else
    print("LuaSnips is not available")
    return
  end

  table.sort(objs, function(a, b)
    if a.ft ~= b.ft then
      return a.ft > b.ft
    elseif a.context.name ~= b.context.name then
      return a.context.name > b.context.name
    else
      return a.context.trigger > b.context.trigger
    end
  end)

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

    -- stylua: ignore
    pickers.new(opts, {
        prompt_title = "LUASNIP CUSTOM: " .. opts.picker_to_use,
        finder = finders.new_table({

            results = objs,
            entry_maker = function(entry)
		    search_fn = ext_conf._config.luasnip and ext_conf._config.luasnip.search or default_search_text
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
                vim.cmd('startinsert')
                vim.api.nvim_put({ selection.value.context.trigger }, "", true, true)
                if (luasnip.expandable()) then
                    luasnip.expand()
                else
                    print("Snippet '" .. selection.value.context.name .. "'" .. "was selected, but LuaSnip.expandable() returned false")
                end
                vim.cmd('stopinsert')
            end)
            return true
        end,
    }):find()
end -- end custom function

-- TODO: expose these:
--
--      - Telescope luasnip_insert
--
--      - Telescope luasnip_manage_locals
--                    mappings:
--                      - insert
--                      - delete
--                      - edit
--                      - add new snippet to same file
--
--      - Telescope filetype
--                    mappings
--                      - add new
--                      - open list

return M

-- return telescope.register_extension({ exports = { luasnip = luasnip_fn, filter_null = filter_null, filter_description = filter_description, get_docstring = get_docstring } })
