return {
  -- move all of these into `core/modules`
  origins = {
    "user",
    "doom",
  },
  categories = {
    "core",
    "features",
    "langs",
    "themes",
  },
  components = {
    "settings",
    "packages",
    "configs",
    "binds",
    "cmds",
    "autocmds",
  },
  search_paths = function(path_str)
    return {
      ("user.modules.%s"):format(path_str),
      ("doom.modules.%s"):format(path_str),
    }
  end,
  modules_max_depth = "*/*/"
}
