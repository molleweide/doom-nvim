-- cli:   https://github.com/soywod/himalaya
-- lib:   https://git.sr.ht/~soywod/himalaya-lib
-- plugin:  https://git.sr.ht/~soywod/himalaya-vim

local email = {}

email.settings = {
  himalaya = {
    folder_picker = "telescope", --'native' | 'fzf' | 'telescope'
    folder_picker_telescope_preview = 1,
    -- complete_contact_cmd = ""

  },
}

-- https://github.com/ibhagwan/smartyank.nvim
email.packages = {
  ["himalaya-vim"] = {
    url = "https://git.sr.ht/~soywod/himalaya-vim",
  },
}

email.configs = {}

email.configs["himalaya-vim"] = function()
  vim.g.himalaya_folder_picker = email.settings.himalaya.folder_picker
  vim.g.himalaya_folder_picker_telescope_preview = email.settings.himalaya.folder_picker_telescope_preview
  -- vim.g.himalaya_complete_contact_cmd = email.settings.himalaya.complete_contact_cmd
end

return email
