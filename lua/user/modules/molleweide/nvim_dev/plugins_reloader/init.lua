local utils = require("doom.utils")
local use_floating_win_packer = doom.settings.use_floating_win_packer
local log = require("doom.utils.logging")
local system = require("doom.core.system")

-- compare to source git@github.com:notomo/lreload.nvim.git

-- TODO: use `tree` to traverse modules

local pr = {}

pr.settings = {
  watch_plugin_dirs = {
    "lua",
    "after",
    "plugins",
    "syntax",
  },
  -- watch_ignore_dirs = {}, -- ???
}
local function is_local_path(s)
  return s:match("^~") or s:match("^/")
end

pr.settings = {}

-- local function package_is_local(name, spec)
--   local repo_path = spec[1]
--   if is_local_path(repo_path) then
--     apply_reload_autocmd_to_local_fork(name, repo_path)
--   end
--   if spec.requires ~= nil then
--     for _, rspec in pairs(spec.requires) do
--       local rspec_repo_path = rspec
--       if type(rspec) == "table" then
--         rspec_repo_path = rspec[1]
--       end
--       if is_local_path(rspec_repo_path) then
--         apply_reload_autocmd_to_local_fork(rspec[1]:match("/([_%w%.%-]-)$"), rspec[1])
--       end
--     end
--   end
-- end

local function spawn_autocmds(name, repo_path)
  local repo_lua_path = string.format("%s%slua", repo_path, system.sep)
  local autocmd_pattern = string.format("%s%s%s", repo_path, system.sep, "**/*.lua")
  local scan_dir = require("plenary.scandir").scan_dir
  local reload_module = require("plenary.reload").reload_module
  local scan_dir_opts = { search_pattern = ".", depth = 1, only_dirs = true }
  utils.make_augroup(name .. "_autoreloader", {
    {
      "BufWritePost",
      autocmd_pattern,
      function()
        -- this should be a bool for run on start. not like it is right now.
        if doom.settings.reload_local_plugins then
          local t_lua_module_paths = scan_dir(vim.fn.expand(repo_lua_path), scan_dir_opts)
          local t_lua_module_names = vim.tbl_map(function(s)
            return s:match("/([_%w]-)$") -- capture only dirname
          end, t_lua_module_paths)
          for _, mname in ipairs(t_lua_module_names) do
            print("reload module name:", mname)
            print("reload module name:", mname)
            print("reload module name:", mname)
            reload_module(mname)
          end
        end
      end,
    },
  })
  log.info(
    string.format([[Create local reloader autocmd for: %s]], repo_path:match("/([_%w%.%-]-)$"))
  )
end

-- Check which packages need autocmd for reloading
local function check_packages()
  local local_package_specs = {}

  -- TODO: break the below into two
  --  1. add specs to sum table
  --  2. add autocmds to specs

  -- TODO: log.info("Reloaded package: " .. pname)
  --    -- if dependency > show `pname (dependency for pmain)`

  for _, module in pairs(doom.modules) do
    if module.packages then
      for name, spec in pairs(module.packages) do
        local repo_path = spec[1]
        if is_local_path(repo_path) then
          spawn_autocmds(name, repo_path)
        end

        -- Handle package dependencies
        -- NOTE: will there be duplicates if multiple plugins require the same package?
        if spec.requires ~= nil then
          for _, rspec in pairs(spec.requires) do
            local rspec_repo_path = rspec
            if type(rspec) == "table" then
              rspec_repo_path = rspec[1]
            end
            if is_local_path(rspec_repo_path) then
              -- what is this?
              spawn_autocmds(rspec[1]:match("/([_%w%.%-]-)$"), rspec[1])
            end
          end
        end
      end
    end
  end
end

if doom.settings.reload_local_plugins then
  check_packages()
end

pr.cmds = {
  {
    "DoomStartLocalPluginAutoReloaders",
    function()
      check_packages()
      -- local function check_for_local_forks(name, spec)
      --   local function apply_reload_autocmd_to_local_fork(name, repo_path)
      --     local repo_lua_path = string.format("%s%slua", repo_path, system.sep)
      --     local autocmd_pattern = string.format("%s%s%s", repo_path, system.sep, "**/*.lua")
      --     local scan_dir = require("plenary.scandir").scan_dir
      --     local reload_module = require("plenary.reload").reload_module
      --     local scan_dir_opts = { search_pattern = ".", depth = 1, only_dirs = true }
      --     utils.make_augroup(name .. "_autoreloader", {
      --       {
      --         "BufWritePost",
      --         autocmd_pattern,
      --         function()
      --           -- this should be a bool for run on start. not like it is right now.
      --           if doom.settings.reload_local_plugins then
      --             local t_lua_module_paths = scan_dir(vim.fn.expand(repo_lua_path), scan_dir_opts)
      --             local t_lua_module_names = vim.tbl_map(function(s)
      --               return s:match("/([_%w]-)$") -- capture only dirname
      --             end, t_lua_module_paths)
      --             for _, mname in ipairs(t_lua_module_names) do
      --               print("reload module name:", mname)
      --               reload_module(mname)
      --             end
      --           end
      --         end,
      --       },
      --     })
      --     log.info(
      --       string.format(
      --         [[Create local reloader autocmd for: %s]],
      --         repo_path:match("/([_%w%.%-]-)$")
      --       )
      --     )
      --   end
      --
      --   local repo_path = spec[1]
      --
      --   local function is_local_path(s)
      --     return s:match("^~") or s:match("^/")
      --   end
      --
      --   if is_local_path(repo_path) then
      --     apply_reload_autocmd_to_local_fork(name, repo_path)
      --   end
      --
      --   -- will there be duplicates if multiple plugins require the same package?
      --   if spec.requires ~= nil then
      --     for _, rspec in pairs(spec.requires) do
      --       local rspec_repo_path = rspec
      --       if type(rspec) == "table" then
      --         rspec_repo_path = rspec[1]
      --       end
      --       if is_local_path(rspec_repo_path) then
      --         apply_reload_autocmd_to_local_fork(rspec[1]:match("/([_%w%.%-]-)$"), rspec[1])
      --       end
      --     end
      --   end
      -- end
      --
      -- for _, module in pairs(doom.modules) do
      --   if module.packages then
      --     for dependency_name, packer_spec in pairs(module.packages) do
      --       check_for_local_forks(dependency_name, packer_spec)
      --     end
      --   end
      -- end
    end,
  },
}

-- pr.autocmds = {
--   { "DoomStarted", "", }
-- }

-- TODO: toggle binds
pr.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "t",
        name = "+tweak",
        {
          {
            "pr",
            function()
              -- lsp.__completions_enabled = not lsp.__completions_enabled
              -- local bool2str = require("doom.utils").bool2str
              -- print(string.format("completion=%s", bool2str(lsp.__completions_enabled)))
            end,
            name = "Toggle reload plugins on change",
          },
        },
      },
    },
  },
}

return pr
