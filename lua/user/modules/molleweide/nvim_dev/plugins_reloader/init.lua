local log = require("doom.utils.logging")
local system = require("doom.core.system")

-- compare to source git@github.com:notomo/lreload.nvim.git

local autocmds_service = require("doom.services.autocommands")

-- TODO: the autocmd also needs to check for lsp errors in each
--        respective plugin to make sure that we don't reload
--        until the errors have been resolved

-- _G._doom_plugins_reloader_started = _G._doom_plugins_reloader_started ~= nil and _G._doom_plugins_reloader_started or {}

local pr = {}

pr.settings = {
  startup = true, -- should this be moved into the `doom.settings`
  watch_plugin_dirs = {
    "lua",
    "after",
    "plugins",
    "syntax",
  },
  watch_ignore_dirs = {},
}
local function is_local_path(s)
  return s:match("^~") or s:match("^/")
end

pr.settings = {}

local function spawn_autocmds(name, repo_path)
  local repo_lua_path = string.format("%s%slua", repo_path, system.sep)
  local scan_dir_opts = { search_pattern = ".", depth = 1, only_dirs = true }
  log.info(string.format([[Spawn watcher for: %s]], repo_path:match("/([_%w%.%-]-)$")))
  autocmds_service.set({
    "BufWritePost",
    string.format("%s%s%s", repo_path, system.sep, "**/*.lua"), -- pattern
    function()
      -- if doom.settings.reload_local_plugins then
      local t_lua_module_paths =
        require("plenary.scandir").scan_dir(vim.fn.expand(repo_lua_path), scan_dir_opts)
      local t_lua_module_names = vim.tbl_map(function(s)
        return s:match("/([_%w]-)$") -- capture only dirname
      end, t_lua_module_paths)
      -- for _, mname in ipairs(t_lua_module_names) do
      log.info("Reloaded package: " .. mname)
      require("plenary.reload").reload_module(mname)
      -- end
      -- end
    end,
  })
end

local function find_local_package_paths()
  local local_package_specs = {}
  for _, module in pairs(doom.modules) do
    if module.packages then
      for name, spec in pairs(module.packages) do
        if is_local_path(spec[1]) then
          local_package_specs[name] = spec[1]
        end
        -- For each dependency spec
        if spec.requires ~= nil then
          for _, rspec in pairs(spec.requires) do
            local rspec_repo_path = rspec
            if type(rspec) == "table" then
              rspec_repo_path = rspec[1]
            end
            if is_local_path(rspec_repo_path) then
              local rname = rspec[1]:match("/([_%w%.%-]-)$")
              local_package_specs[rname] = rspec_repo_path
            end
          end
        end
      end
    end
  end
  return local_package_specs
end

-- TODO: needs `tree`
local function setup_package_watchers()
  print("setup_package_watchers")
  log.info("Setting up local package watchers..")

  local lp = find_local_package_paths()

  P(lp)

  for name, path in pairs(lp) do
    spawn_autocmds(name, path)
  end
end

local function remove_package_watchers()
  print("remove_package_watchers")
  -- TODO: how can I use autocommands service to remove all of them here?
end

-- if doom.settings.reload_local_plugins then
--   -- print("watch_plugin_changes_enabled", _doom.watch_plugin_changes_enabled)
--   -- if _doom.watch_plugin_changes_enabled == nil then --or _doom.watch_plugin_changes_enabled == false then
--   --   print("doom watch if nil/false")
--   --   _doom.watch_plugin_changes_enabled = true
--   -- end
--   setup_package_watchers()
-- end

pr.cmds = {
  {
    "DoomWatchLocalPackagesEnable",
    function()
      print("cmd: Doom Watch Pkg Enable")
      if
        _doom.watch_plugin_changes_enabled == nil or _doom.watch_plugin_changes_enabled == false
      then
        setup_package_watchers()
        _doom.watch_plugin_changes_enabled = true
      end
    end,
  },
  {
    "DoomWatchLocalPackagesDisable",
    function()
      -- TODO: delete watch autocmds
      print("cmd: Doom Watch Pkg Disable")
      _doom.watch_plugin_changes_enabled = false
      remove_package_watchers()
    end,
  },
}

-- autocmds_service.set = function(event, pattern, action, opts)
pr.autocmds = {
  {
    "User",
    "*", -- Patterns can be ignored for this autocmd
    function()
      -- print("watch_plugin_changes_enabled", _doom.watch_plugin_changes_enabled)
      if
        _doom.watch_plugin_changes_enabled == nil or _doom.watch_plugin_changes_enabled == false
      then
        -- print("doom watch if nil/false")
        _doom.watch_plugin_changes_enabled = true
        setup_package_watchers()
      end
      -- DoomWatchLocalPackages

      -- print("autocommand: plugins autoreloader")
    end,
  },
}

-- TODO: toggle binds
--
--
-- should I use _doom to store state?
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
              if _doom.watch_plugin_changes_enabled then
                _doom.watch_plugin_changes_enabled = false
                print("bind: remove_package_watchers")
                remove_package_watchers()
              else
                _doom.watch_plugin_changes_enabled = true
                print("bind: setup_package_watchers")
                setup_package_watchers()
              end
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
