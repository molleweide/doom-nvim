local root_sync_mods = {}

local function root_sync_modules()
  -- for each modules
  --
  --
  --    -- modules.utils.extend()
  --
  --      inspect -> what information can be used here to analyze the `modules.lua` file
  --
  --    check if module exists in `modules.lua`
  --
  --      check both field strings AND comments
  --
  --
  --
  --    encourage descriptive module names `git_mod_that_does_x`
  --
  --    if comment == `-- NOTE: `
  --
end

root_sync_mods.cmds = {
  {
    "DoomRootSyncModules",
    function()
      root_sync_mods.root_sync_modules()
    end,
  },
}
