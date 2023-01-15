local log = require("doom.utils.logging")
local system = require("doom.core.system")
local autocmds_service = require("doom.services.autocommands")

local pr = {}

-- TODO: how can I use autocommands service to remove all of them here?

pr.settings = {
  startup = true, -- should this be moved into the `doom.settings`
  -- TODO: use this to watch all relevant dirs
  watch_plugin_dirs = {
    "lua",
    "after",
    "plugins",
    "syntax",
  },
  watch_ignore_dirs = {},
}

local function is_local_path(s)
  local match = s:match("^~") or s:match("^/")
  return match
end

local function do_reload(mname, dep)
  if _doom.watch_plugin_changes_enabled then
    if doom.package_reloaders[mname] then
      local dep_str = dep and "(dependency of `" .. dep .. "`)" or ""
      log.info("[PKG_WATCH]: Custom reload: " .. mname, dep_str)
      doom.package_reloaders[mname].on_reload()
    else
      log.info("[PKG_WATCH]: Default reload: " .. mname, dep_str)
      require("plenary.reload").reload_module(mname)
    end
  end
end

local function spawn_autocmds(name, repo_path, dep)
  local repo_lua_path = string.format("%s%slua", repo_path, system.sep)
  local scan_dir_opts = { search_pattern = ".", depth = 1, only_dirs = true }
  log.debug(string.format([[[PKG_WATCH]: Spawn watcher: %s%s]], name, dep and dep or ""))
  autocmds_service.set(
    "BufWritePost",
    string.format("%s%s%s", repo_path, system.sep, "**/*.lua"), -- pattern
    function()
      local t_lua_module_paths =
        require("plenary.scandir").scan_dir(vim.fn.expand(repo_lua_path), scan_dir_opts)
      local t_lua_module_names = vim.tbl_map(function(s)
        return s:match("/([_%w]-)$") -- capture only dirname
      end, t_lua_module_paths)
      for _, mname in ipairs(t_lua_module_names) do
        do_reload(mname)
      end
    end
  )
end

local function find_local_package_paths()
  local local_package_specs = {}

  -- require("doom.utils.tree").traverse_table({
  --   tree = doom.modules,
  --   filter = "doom_module_single",
  --   leaf = function(_, _, module)
  --     if module.packages then
  --       for name, spec in pairs(module.packages) do
  --         if is_local_path(spec[1]) then
  --           local_package_specs[name] = { spec[1] }
  --         end
  --         if spec.requires ~= nil then
  --           if type(spec.requires) == "table" then
  --             for _, rspec in pairs(spec.requires) do
  --               if type(rspec) == "table" then
  --                 if is_local_path(rspec[1]) then
  --                   local_package_specs[rspec[1]:match("/([_%w%.%-]-)$")] =
  --                     { rspec[1], dependency_of = name }
  --                 end
  --               elseif is_local_path(rspec) then
  --                 local_package_specs[rspec:match("/([_%w%.%-]-)$")] = { rspec, dependency = name }
  --               end
  --             end
  --           else
  --             -- Single string name dependency; requires = "xxx",
  --             if is_local_path(spec.requires) then
  --               local_package_specs[spec.requires:match("/([_%w%.%-]-)$")] =
  --                 { spec.requires, dependency = name }
  --             end
  --           end
  --         end
  --       end
  --     end
  --   end,
  -- })

  require("doom.utils.modules").traverse_loaded(doom.modules, function(node, stack)
    if node.type then
      local module = node
      if module.packages then
        for name, spec in pairs(module.packages) do
          if is_local_path(spec[1]) then
            local_package_specs[name] = { spec[1] }
          end
          if spec.requires ~= nil then
            if type(spec.requires) == "table" then
              for _, rspec in pairs(spec.requires) do
                if type(rspec) == "table" then
                  if is_local_path(rspec[1]) then
                    local_package_specs[rspec[1]:match("/([_%w%.%-]-)$")] =
                      { rspec[1], dependency_of = name }
                  end
                elseif is_local_path(rspec) then
                  local_package_specs[rspec:match("/([_%w%.%-]-)$")] = { rspec, dependency = name }
                end
              end
            else
              -- Single string name dependency; requires = "xxx",
              if is_local_path(spec.requires) then
                local_package_specs[spec.requires:match("/([_%w%.%-]-)$")] =
                  { spec.requires, dependency = name }
              end
            end
          end
        end
      end
    end
  end, { debug = doom.settings.logging == "trace" or doom.settings.logging == "debug" })

  return local_package_specs
end

local function setup_package_watchers()
  log.debug("[PKG_WATCH]: Setting up local package watchers..")
  local lp = find_local_package_paths()
  for name, path in pairs(lp) do
    spawn_autocmds(name, path[1], path[2])
  end
end

local function remove_package_watchers()
  log.debug("remove_package_watchers")
  -- TODO: ...
end

-- RUN RELOADER ON STARTUP
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
      _doom.watch_plugin_changes_enabled = false
      remove_package_watchers()
    end,
  },
}

-- pr.autocmds = {
--   {
--     "User",
--     "*", -- Patterns can be ignored for this autocmd
--     function()
--       -- print("watch_plugin_changes_enabled", _doom.watch_plugin_changes_enabled)
--       if doom.settings.reload_local_plugins then
--         if
--           _doom.watch_plugin_changes_enabled == nil or _doom.watch_plugin_changes_enabled == false
--         then
--           -- print("doom watch if nil/false")
--           _doom.watch_plugin_changes_enabled = true
--           setup_package_watchers()
--         end
--       end
--     end,
--   },
-- }

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
                remove_package_watchers()
              else
                _doom.watch_plugin_changes_enabled = true
                setup_package_watchers()
              end
              local bool2str = require("doom.utils").bool2str
              print(
                string.format(
                  "reload_local_plugins=%s",
                  bool2str(_doom.watch_plugin_changes_enabled)
                )
              )
            end,
            name = "Toggle reload plugins on change",
          },
        },
      },
    },
  },
}

return pr
