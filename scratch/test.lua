-- PLAYING AROUND WITH RELOADING PLUGINS AND PACKAGES

-- if packer_plugins["vim-fugitive"] and packer_plugins["vim-fugitive"].loaded then
--   print("Vim fugitive is loaded")
--   -- other custom logic
-- end

P(_G.packer_plugins)

R("cmp")

-- print(vim.inspect(package.loaded, { depth = 1 }))

-- ///////////////////////////////////////////////////////

reload_module = function(module_name, starts_with_only)
  -- Default to starts with only
  if starts_with_only == nil then
    starts_with_only = true
  end

  -- TODO: Might need to handle cpath / compiled lua packages? Not sure.
  local matcher
  if not starts_with_only then
    matcher = function(pack)
      return string.find(pack, module_name, 1, true)
    end
  else
    matcher = function(pack)
      return string.find(pack, "^" .. module_name)
    end
  end

  -- Handle impatient.nvim automatically.
  local luacache = (_G.__luacache or {}).cache

  for pack, _ in pairs(package.loaded) do
    if matcher(pack) then
      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
    end
  end
end

-- ///////////////////////////////////////////////////////

function reload(configurations)
  _G.packer_plugins = _G.packer_plugins or {}
  for k, v in pairs(_G.packer_plugins) do
    if k ~= "packer.nvim" then
      _G.packer_plugins[v] = nil
    end
  end
  plugin_loader.load(configurations)

  plugin_loader.ensure_plugins()
end
