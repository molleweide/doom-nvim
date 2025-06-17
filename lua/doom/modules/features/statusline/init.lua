-- https://github.com/Zeioth/heirline-components.nvim
--
-- NOTE: Examples on how to use heirline-components
--  https://github.com/NormalNvim/NormalNvim/blob/69e334c1f10554ba03b07193b4d4aad5c71c021a/lua/plugins/2-ui.lua#L320
--
-- NOTE: heirline-components is super powerful and configures most things. It
-- really is a good resource for learning.
--
--
-- FIX: Autocmds fail to reload

-- TODO: think about loading order of plugins. Maybe we need a system that allows
-- for setting loading order of modules? load_before = ..., load_index = <integer>
--
-- TODO: If eg. neorg journal file, then show parents up until journal dir.

local hex2rgb = function(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6)),
    }
end

--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
local rgbToHsv = function(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end

    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, v
end

local statusline = {}

statusline.settings = {}

statusline.state = {}
statusline.state.installing_mason_packages = {}

--- Pushes a mason package to be shown in the statusline
---@param name string Name of the package
statusline.state.start_mason_package = function(name)
    statusline.state.finish_mason_package(name)
    table.insert(statusline.state.installing_mason_packages, name)
end

--- Removes a mason package from being shown in the statusline
---@param name string Name of the package
statusline.state.finish_mason_package = function(name)
    local packages = statusline.state.installing_mason_packages
    statusline.state.installing_mason_packages = vim.tbl_filter(function(val)
        return val ~= name
    end, packages)
end

statusline._safe_get_highlight = function(...)
    for _, hlname in ipairs({ ... }) do
        if vim.fn.hlexists(hlname) == 1 then
            local id = vim.fn.synIDtrans(vim.api.nvim_get_hl_id_by_name(hlname))
            local foreground = vim.fn.synIDattr(id, "fg")
            local background = vim.fn.synIDattr(id, "bg")
            if vim.fn.synIDattr(id, "reverse") == "1" then
                foreground, background = background, foreground
            end
            if foreground and foreground:find("^#") then
                return { foreground = foreground, background = background }
            end
        end
    end
    return { foreground = "#000000", background = "#000000" }
end

statusline._generate_colorscheme = function()
    local colors = vim.tbl_map(function(hl)
        return {
            hex = hl,
            rgb = hex2rgb(hl),
        }
    end, {
        statusline._safe_get_highlight("luaTSField", "TSField", "TSVariable", "Field", "Variable").foreground,
        statusline._safe_get_highlight(
            "luaTSConditional",
            "TSConditional",
            "TSConstant",
            "Conditional",
            "Constant"
        ).foreground,
        statusline._safe_get_highlight("luaTSFunction", "TSFunction", "Function").foreground,
        statusline._safe_get_highlight("luaTSKeywordFunction", "TSKeywordFunction", "Function").foreground,
        statusline._safe_get_highlight("luaTSString", "TSString", "String").foreground,
        statusline._safe_get_highlight("luaTSNumber", "TSNumber", "Number").foreground,
    })

    local rate_color = function(hsv)
        local averageDist = 0
        local furthestDist = 0
        local numberOfNearbyNodes = 0
        for _, color in ipairs(colors) do
            local dist = math.abs(hsv[1] - color.hsv[1])
            if dist ~= 0 then
                furthestDist = math.max(dist, furthestDist)
                averageDist = averageDist + dist
                if dist < 0.1 then
                    numberOfNearbyNodes = numberOfNearbyNodes + 1
                end
            end
        end
        averageDist = averageDist / #colors

        -- Prioritise colours that are far away from others
        local averageDistanceRating = averageDist * 2
        -- Prioritise colours that are the center of clusters
        local proximityRating = numberOfNearbyNodes * 0.2
        -- Prioritise nodes with roughly 0.8 brightness
        local allowedBrightnessRating = (1 - math.abs(0.8 - hsv[3]))
        -- Prioritise nodes with high saturation
        local saturationRating = hsv[2] * 0.3

        local rating = (averageDistanceRating + proximityRating + saturationRating)
            * allowedBrightnessRating
        return rating
    end

    for _, color in ipairs(colors) do
        local h, s, v = rgbToHsv(unpack(color.rgb))
        color.hsv = { h, s, v }
    end
    for _, color in ipairs(colors) do
        color.rating = rate_color(color.hsv)
    end

    table.sort(colors, function(a, b)
        return a.rating > b.rating
    end)

    return unpack(vim.tbl_map(function(color)
        return color.hex
    end, colors))
end

statusline.packages = {
    ["heirline.nvim"] = { "rebelot/heirline.nvim" },
    ["heirline-components.nvim"] = { "Zeioth/heirline-components.nvim" },
}

statusline.configs = {}
statusline.configs["heirline.nvim"] = function()
    local heirline = require("heirline")
    local lib = require("heirline-components.all")
    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")

    local special, special2, special3 = doom.modules.features.statusline._generate_colorscheme()

    local safe_get_highlight = doom.modules.features.statusline._safe_get_highlight

    local colors = {

        -- cookbook
        bright_bg = utils.get_highlight("Folded").bg,
        bright_fg = utils.get_highlight("Folded").fg,
        red = utils.get_highlight("DiagnosticError").fg,
        dark_red = utils.get_highlight("DiffDelete").bg,
        green = utils.get_highlight("String").fg,
        blue = utils.get_highlight("Function").fg,
        gray = utils.get_highlight("NonText").fg,
        orange = utils.get_highlight("Constant").fg,
        purple = utils.get_highlight("Statement").fg,
        cyan = utils.get_highlight("Special").fg,
        diag_warn = utils.get_highlight("DiagnosticWarn").fg,
        diag_error = utils.get_highlight("DiagnosticError").fg,
        diag_hint = utils.get_highlight("DiagnosticHint").fg,
        diag_info = utils.get_highlight("DiagnosticInfo").fg,
        git_del = utils.get_highlight("diffDeleted").fg,
        git_add = utils.get_highlight("diffAdded").fg,
        git_change = utils.get_highlight("diffChanged").fg,

        -- doom
        normal = safe_get_highlight("Normal").foreground,
        insert = safe_get_highlight("Insert", "String", "MoreMsg").foreground,
        replace = safe_get_highlight("Replace", "Number", "Type").foreground,
        visual = safe_get_highlight("Visual", "Special", "Boolean", "Constant").foreground,
        command = safe_get_highlight("Command", "Identifier", "Normal").foreground,

        background = safe_get_highlight("StatusLine").background,
        base = safe_get_highlight("StatusLine").foreground,
        dim = safe_get_highlight("StatusLineNC", "Comment").foreground,
        special = special,
        special2 = special2,
        special3 = special3,

        diag = {
            warn = safe_get_highlight("DiagnosticWarn").foreground,
            error = safe_get_highlight("DiagnosticError").foreground,
            hint = safe_get_highlight("DiagnosticHint").foreground,
            info = safe_get_highlight("DiagnosticInfo").foreground,
        },
        git = {
            del = safe_get_highlight("diffRemoved", "DiffRemoved", "DiffDelete").foreground,
            add = safe_get_highlight("diffAdded", "DiffAdded", "DiffAdd").foreground,
            change = safe_get_highlight("diffChanged", "DiffChange", "DiffChange").foreground,
        },
    }

    heirline.load_colors(vim.tbl_deep_extend("force", lib.hl.get_colors(), colors))

    --
    -- utility elements
    --
    local Align = { provider = "%=" }
    local Space = { provider = " " }

    --
    -- DOOM CUSTOM COMPONENTS
    --

    -- Aesthetic block at each right/left edge.
    local Notch = {
        {
            provider = function()
                return "█"
            end,
            hl = { fg = colors.special2 },
        },
    }

    local ViMode = {
        -- get vim current mode, this information will be required by the provider
        -- and the highlight functions, so we compute it only once per component
        -- evaluation and store it as a component attribute
        init = function(self)
            self.mode = vim.fn.mode(1) -- :h mode()
        end,
        -- Now we define some dictionaries to map the output of mode() to the
        -- corresponding string and color. We can put these into `static` to compute
        -- them at initialisation time.
        static = {
            mode_colors = {
                n = colors.normal,
                i = colors.insert,
                v = colors.visual,
                V = colors.visual,
                ["\22"] = colors.visual,
                c = colors.command,
                s = colors.purple,
                S = colors.purple,
                ["\19"] = colors.purple,
                R = colors.replace,
                r = colors.replace,
                ["!"] = colors.red,
                t = colors.red,
            },
        },
        provider = function()
            return "   "
        end,
        -- Same goes for the highlight. Now the foreground will change according to the current mode.
        hl = function(self)
            local mode = self.mode:sub(1, 1) -- get only the first mode character
            return { fg = self.mode_colors[mode], bold = true }
        end,
    }

    --[[
  --  FILE BLOCK
  --]]
    local FileBlock = {
        init = function(self)
            self.filename = vim.fn.expand("%:t")
            self.filepath = vim.fn.expand("%:p")
        end,
    }

    local FileSize = {
        provider = function(self)
            -- Return early if no file size
            local fsize = vim.fn.getfsize(self.filepath)
            if fsize <= 0 then
                return ""
            end

            local suffix = { "b", "k", "M", "G", "T", "P", "E" }
            local i = 1
            while fsize > 1024 do
                fsize = fsize / 1024
                i = i + 1
            end
            return string.format(" %.1f%s ", fsize, suffix[i])
        end,
        hl = { fg = colors.dim },
    }

    local FileIcon = {
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ":e")
            self.icon, self.icon_color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
            return self.icon and (self.icon .. " ")
        end,
        hl = function(self)
            return { fg = self.icon_color }
        end,
    }

    -- local FileNameBlock = {
    --     -- let's first set up some attributes needed by this component and its children
    --     init = function(self)
    --         self.filename = vim.api.nvim_buf_get_name(0)
    --     end,
    -- }

    local FileName = {
        provider = function(self)
            -- first, trim the pattern relative to the current directory. For other
            -- options, see :h filename-modifers
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then
                return "[No Name] "
            end
            -- now, if the filename would occupy more than 1/4th of the available
            -- space, we trim the file path to its initials
            -- See Flexible Components section below for dynamic truncation
            filename = vim.fn.pathshorten(filename)
            return filename .. " "
        end,
        hl = { fg = colors.special },
    }

    local FileFlags = {
        {
            provider = function()
                if vim.bo.modified then
                    return " "
                end
            end,
            hl = { fg = colors.green },
        },
        {
            provider = function()
                if not vim.bo.modifiable or vim.bo.readonly then
                    return " "
                end
            end,
            hl = { fg = colors.orange },
        },
    }

    local FileNameModifer = {
        hl = function()
            if vim.bo.modified then
                -- use `force` because we need to override the child's hl foreground
                return { fg = colors.cyan, bold = true, force = true }
            end
        end,
    }

    -- let's add the children to our FileBlock component
    FileBlock = utils.insert(
        FileBlock,
        FileSize,
        FileIcon,
        utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
        unpack(FileFlags)                        -- A small optimisation, since their parent does nothing
    )

    -- Mason LSP indicator, shows when a package is being installed
    -- Integrates with the use_mason_package utility function in langs/utils.lua
    local MasonStatusElement = {
        condition = function()
            return #doom.features.statusline.state.installing_mason_packages > 0
        end,
        provider = function()
            local installing_mason_packages =
                doom.features.statusline.state.installing_mason_packages
            return (("Installing %s... "):format(table.concat(installing_mason_packages, ", ")))
        end,
        on_click = {
            callback = function()
                vim.cmd("Mason")
            end,
            name = "mason",
        },
        hl = { fg = colors.special },
    }

    local FileTypeElement = {
        provider = function()
            return string.format(" %s ", vim.bo.filetype)
        end,
        hl = { fg = colors.dim },
    }

    local LSPElement = {
        condition = conditions.lsp_attached,
        provider = function()
            local servers = vim.lsp.buf_get_clients(0)
            return (" %s "):format(#servers)
        end,

        on_click = {
            callback = function()
                vim.cmd("LspInfo")
            end,
            name = "lspconfig",
        },
        hl = { fg = colors.dim },
    }

    local FileEncoding = {
        hl = { fg = colors.dim },
        provider = function()
            local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
            return enc:upper() .. " "
        end,
    }

    -- Special handling of the built-in terminal bufname. See conditional
    -- statuslines in cookbook to see an example of dedicated statusline for
    -- terminals!
    local TerminalName = {
        -- we could add a condition to check that buftype == 'terminal'
        -- or we could do that later (see #conditional-statuslines below)
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return " " .. tname
        end,
        hl = { fg = "blue", bold = true },
    }

    --
    --  GIT BLOCK
    --

    local GitBlock = {
        condition = function()
            local has_gitsigns_module = doom.modules.version_control.git ~= nil
            local is_git_repo = conditions.is_git_repo()
            local has_status_dict = vim.b.gitsigns_status_dict ~= nil
            return has_gitsigns_module and is_git_repo and has_status_dict
        end,
        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
        end,

        {
            {
                hl = { fg = colors.special2 },
                provider = function()
                    return "  "
                end,
            },
            {
                hl = { fg = colors.special2 },
                provider = function(self)
                    return self.status_dict.head .. " "
                end,
            },
        },

        {
            {
                hl = { fg = colors.git.add },
                provider = function(self)
                    local count = self.status_dict.added or 0
                    return count > 0 and ("  " .. count)
                end,
            },
            -- Changed component
            {
                hl = { fg = colors.git.change },
                provider = function(self)
                    local count = self.status_dict.changed or 0
                    return count > 0 and ("  " .. count)
                end,
            },
            -- Deleted component
            {
                hl = { fg = colors.git.del },
                provider = function(self)
                    local count = self.status_dict.removed or 0
                    return count > 0 and ("  " .. count .. " ")
                end,
            },
        },
    }

    local Ruler = {
        {
            hl = { fg = colors.dim },
            provider = " %P ",
        },
        {
            provider = "%3l:%-2c ",
        },
    }

    -----------------------------------------------------------------------------
    --
    -- FINAL STATUSLINE
    --

    local StatusLine = {
        hl = { bg = "bg" },
        { Notch },
        { ViMode },
        { GitBlock },
        { FileBlock },
        { FileEncoding },
        lib.component.file_info(),
        -- lib.component.fill(),
        lib.component.treesitter({ str = { str = "TS On" } }),
        -- lib.component.fill(),
        lib.component.git_diff(), -- added:green changed:blue removed:red
        lib.component.fill(),
        lib.component.diagnostics(),
        -- lib.component.fill(),
        lib.component.cmd_info(), -- eg. shows which register a macro is being recorded to.
        lib.component.fill(),
        lib.component.lsp(),
        { provider = " %= " },
        { MasonStatusElement },
        -- { FileTypeElement },
        { LSPElement },
        lib.component.compiler_state(), -- https://github.com/Zeioth/compiler.nvim

        lib.component.virtual_env(),
        { Ruler }, -- lib.component.nav(), -- nav is the same as ruler..
        lib.component.mode({
            hl = { fg = colors.dark_red },
            mode_text = {},
            surround = { separator = "right" },
        }),
        { Notch },
    }

    -----------------------------------------------------------------------------
    --
    -- HEIRLINE: WINBAR
    --

    -- NOTE: Doesnt do much at the moment. Only shows null for regular files,
    -- and name of terminal buffers.

    local WinBars = {
        init = function(self)
            self.bufnr = vim.api.nvim_get_current_buf()
        end,
        fallthrough = false,
        -- -- Winbar for terminal, neotree, and aerial.
        -- {
        --     condition = function()
        --         return not lib.condition.is_active()
        --     end,
        --     {
        --         lib.component.neotree(),
        --         lib.component.compiler_play(),
        --         lib.component.fill(),
        --         lib.component.compiler_build_type(),
        --         lib.component.compiler_redo(),
        --         lib.component.aerial(),
        --     },
        -- },
        -- -- Regular winbar

        {
            -- FileName,
            lib.component.file_info({ filetype = false, filename = {}, file_modified = false }), -- icon+filename+extension
            lib.component.diagnostics(),
            lib.component.breadcrumbs(), --
            -- lib.component.neotree(),
            -- lib.component.compiler_play(),
            -- lib.component.fill(),
            -- lib.component.fill(),
            -- lib.component.compiler_redo(),
            -- lib.component.aerial(),
        },

        -- -- fallthrough = false,
        -- { -- A special winbar for terminals
        --     condition = function()
        --         return conditions.buffer_matches({ buftype = { "terminal" } })
        --     end,
        --     utils.surround({ "", "" }, "dark_red", {
        --         FileTypeElement,
        --         Space,
        --         TerminalName,
        --     }),
        -- },



        -- -- An inactive winbar for regular files
        -- {
        --     condition = function()
        --         return not conditions.is_active()
        --     end,
        --     utils.surround(
        --         { "", "" },
        --         colors.bright_bg,
        --         { hl = { fg = "gray", force = true }, FileName }
        --     ),
        -- },

        -- -- A winbar for regular files
        -- utils.surround({ "", "" }, colors.bright_bg, FileName),
    }

    -- NormalNvim config

    local normal_nvim_opts = function()
        return {
            opts = {
                disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
                    local is_disabled = not require("heirline-components.buffer").is_valid(
                            args.buf
                        )
                        or lib.condition.buffer_matches({
                            buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                            filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
                        }, args.buf)
                    return is_disabled
                end,
            },
            tabline = { -- UI upper bar
                lib.component.tabline_conditional_padding(),
                lib.component.tabline_buffers(),
                lib.component.fill({ hl = { bg = "tabline_bg" } }),
                lib.component.tabline_tabpages(),
            },
            winbar = { -- UI breadcrumbs bar
                init = function(self)
                    self.bufnr = vim.api.nvim_get_current_buf()
                end,
                fallthrough = false,
                -- Winbar for terminal, neotree, and aerial.
                {
                    condition = function()
                        return not lib.condition.is_active()
                    end,
                    {
                        lib.component.neotree(),
                        lib.component.compiler_play(),
                        lib.component.fill(),
                        lib.component.compiler_build_type(),
                        lib.component.compiler_redo(),
                        lib.component.aerial(),
                    },
                },
                -- Regular winbar
                {
                    lib.component.neotree(),
                    lib.component.compiler_play(),
                    lib.component.fill(),
                    lib.component.breadcrumbs(),
                    lib.component.fill(),
                    lib.component.compiler_redo(),
                    lib.component.aerial(),
                },
            },
            statuscolumn = { -- UI left column
                init = function(self)
                    self.bufnr = vim.api.nvim_get_current_buf()
                end,
                lib.component.foldcolumn(),
                lib.component.numbercolumn(),
                lib.component.signcolumn(),
            } or nil,
            statusline = { -- UI statusbar
                hl = { fg = "fg", bg = "bg" },
                lib.component.mode(),
                lib.component.git_branch(),
                lib.component.file_info(),
                lib.component.git_diff(),
                lib.component.diagnostics(),
                lib.component.fill(),
                lib.component.cmd_info(),
                lib.component.fill(),
                lib.component.lsp(),
                lib.component.compiler_state(),
                lib.component.virtual_env(),
                lib.component.nav(),
                lib.component.mode({ surround = { separator = "right" } }),
            },
        }
    end
    if false then
        normal_nvim_opts()
    end

    -----------------------------------------------------------------------------
    --
    -- HEIRLINE: TABLINE
    --

    local TabLine = { -- UI upper bar
        lib.component.tabline_conditional_padding(),
        lib.component.tabline_buffers(),
        lib.component.fill({ hl = { bg = colors.tabline_bg } }),
        lib.component.tabline_tabpages(),
    }

    -----------------------------------------------------------------------------
    --
    -- FINAL CALL TO HEIRLINE
    --

    lib.init.subscribe_to_events()

    -- PS("heirline lib colors: <%s>", vim.inspect(lib.hl.get_colors()))

    -- TODO: heirline can be refreshed at anytime, so we should use a post reload
    -- hook to reset, instead of doing it via lazy, since it wont trigger on
    -- subsequent relods.

    heirline.setup({
        statusline = StatusLine,
        winbar = WinBars,
        tabline = TabLine,
        opts = {
            -- if the callback returns true, the winbar will be disabled for that window
            -- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
            disable_winbar_cb = function(args)
                local is_disabled = not require("heirline-components.buffer").is_valid(args.buf)
                    or lib.condition.buffer_matches({
                        buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                        filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
                    }, args.buf)
                return is_disabled
            end,
        },
    })

    vim.o.showtabline = 2
end


statusline.try_refresh = function(arg)
    xpcall(doom.modules.features.statusline.configs["heirline.nvim"], debug.traceback)
end

statusline.on_loaded_single = statusline.try_refresh

-- TODO: vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
-- Convert this into lua

statusline.autocmds = {
    {
        "ColorScheme",
        "*",
        function()
            vim.defer_fn(function()
                statusline.try_refresh()
            end, 1)
        end,
    },
    -- Sometimes the colorscheme doesn't load on the first try
    {
        "VimEnter",
        "*",
        function()
            vim.defer_fn(function()
                statusline.try_refresh()
            end, 50)
        end,
        once = true,
    },
}

-- TODO: Add tweak mapping to toggle the tabline.
statusline.binds = {}

return statusline
