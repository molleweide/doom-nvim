-- My idea herer is to keep things related to doom specifications and
-- definitions in this file.
return {
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
}
