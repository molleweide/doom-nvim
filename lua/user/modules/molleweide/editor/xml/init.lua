-- NOTE: HTML / XML
--  ** surround
--     https://github.com/tpope/vim-surround
--     https://freshman.tech/vim-javascript/
--  ** objects guides
--     https://blog.carbonfive.com/vim-text-objects-the-definitive-guide/
-- NOTE:
--  ** navigate tags
--     https://duckduckgo.com/?q=vim+navigate+tags+html+xml&ia=web
--     https://vi.stackexchange.com/questions/780/how-to-jump-between-matching-html-xml-tags
--     https://unix.stackexchange.com/questions/38187/vim-jump-from-one-xml-tag-to-the-closing-one
--     https://stackoverflow.com/questions/130734/how-can-one-close-html-tags-in-vim-quickly
--     https://vim.fandom.com/wiki/Vim_as_XML_Editor
--     https://vim.fandom.com/wiki/Delete_a_pair_of_XML/HTML_tags
--     https://stackoverflow.com/questions/16340037/change-html-tag-in-vim-but-keeping-the-attributes-surround
--     https://coderwall.com/p/w_ej6w/change-inner-html-of-a-tag-in-vim
--     https://davidvielmetter.com/tricks/html-tag-matching-in-vim/
--     https://vim.fandom.com/wiki/Changing_all_HTML_tags_to_lowercase
--  NOTE:
--  ** editing / plugins
--   https://stackoverflow.com/questions/6097363/vim-surround-create-new-tag-but-dont-indent-new-line
--   https://dev.to/iggredible/how-to-use-tags-in-vim-to-jump-to-definitions-quickly-2g28
--   https://lornajane.net/posts/2014/vim-and-html-tags-with-the-surround-plugin
-- ** jsx
--   https://getaround.tech/setting-up-vim-for-react/

-- note: emmet articles
--     https://alldrops.info/posts/vim-drops/2018-08-21_become-a-html-ninja-with-emmet-for-vim/

-- note: useful text objects: at, and it, which allow you to  handle tags fater

-- NOTE: EMMET JSX
--  https://nick-tomlin.com/posts/jsx-with-emmet-vim
--  https://www.reddit.com/r/neovim/comments/v2ha0n/anybody_use_emmet_for_reacttypescript_development/
--  https://www.reddit.com/r/neovim/search/?q=react%20jsx%20emmet&restrict_sr=1&sr_nsfw=&include_over_18=1

local xml = {}

xml.settings = {
  emmet = {
    leader = "???"
  },
}

-- EMMET LSP??? https://www.reddit.com/r/neovim/comments/w2hkev/emmetvim_vs_emmet_ls/
--
-- NEOVIM / EMMET SEARCH ON REDDIT: https://www.reddit.com/r/neovim/search/?q=emmet&restrict_sr=1&sr_nsfw=&include_over_18=1
--
-- EMMET LEADER:
--    https://github.com/mattn/emmet-vim#redefine-trigger-key

-- FIX: does it hijack Ligthspead <S-s>?!

-- EMMET DOCS: https://docs.emmet.io/abbreviations/

-- SEARCH: VIM REACT TYPESCRIPT SETUP

xml.packages = {
  -- https://github.com/nvim-emmet/nvim-emmet
  -- https://github.com/aca/emmet-ls
  -- https://github.com/othree/html5.vim
  -- https://github.com/tpope/vim-ragtag
  -- https://github.com/jcha0713/classy.nvim // add/remove classes helper
  -- https://github.com/dzfrias/nvim-classy
  -- https://github.com/whatyouhide/vim-textobj-xmlattr
  -- https://github.com/harrisoncramer/jump-tag
  ["emmet-vim"] = {
    "mattn/emmet-vim",
  },
  -- ["change-inside-surroundings"] = {
  --   "briandoll/change-inside-surroundings",
  -- },
  -- TODO: !?
  --      https://github.com/mlaursen/vim-react-snippets

  -- https://github.com/napmn/react-extract.nvim
}

-- xml.configs["emmet-vim"] = function()
--   -- TODO: look at firenvim and do the same..
--   -- change emmet leader
-- end

-- If you don't want to enable emmet in all modes, you can use set these options in vimrc:
--
-- let g:user_emmet_mode='n'    "only enable normal mode functions.
-- let g:user_emmet_mode='inv'  "enable all functions, which is equal to
-- let g:user_emmet_mode='a'    "enable all function in all mode.
-- Enable just for html/css
-- let g:user_emmet_install_global = 0
-- autocmd FileType html,css EmmetInstall
-- Redefine trigger key
-- To remap the default <C-Y> leader:
--
-- let g:user_emmet_leader_key='<C-Z>'
-- Note that the trailing , still needs to be entered, so the new keymap would be <C-Z>,.
--
-- Adding custom snippets
-- If you have installed the web-api for emmet-vim you can also add your own snippets using a custom snippets.json file.
--
-- Once you have installed the web-api add this line to your .vimrc:
--
-- let g:user_emmet_settings = webapi#json#decode(join(readfile(expand('~/.snippets_custom.json')), "\n"))
-- You can change the path to your snippets_custom.json according to your preferences.
--
-- Here you can find instructions about creating your customized snippets.json file.
--
-- Snippet to add meta tag for responsiveness
-- Update this in your .vimrc file.
--
-- let g:user_emmet_settings = {
-- \  'variables': {'lang': 'ja'},
-- \  'html': {
-- \    'default_attributes': {
-- \      'option': {'value': v:null},
-- \      'textarea': {'id': v:null, 'name': v:null, 'cols': 10, 'rows': 10},
-- \    },
-- \    'snippets': {
-- \      'html:5': "<!DOCTYPE html>\n"
-- \              ."<html lang=\"${lang}\">\n"
-- \              ."<head>\n"
-- \              ."\t<meta charset=\"${charset}\">\n"
-- \              ."\t<title></title>\n"
-- \              ."\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
-- \              ."</head>\n"
-- \              ."<body>\n\t${child}|\n</body>\n"
-- \              ."</html>",
-- \    },
-- \  },
-- \}

-- xml.binds = {
--   {}
-- }

return xml
