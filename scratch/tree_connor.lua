--
-- TRAVERSER
--

local log = require("doom.utils.logging")
local tree_traverser = {
  build = function(builder_opts)
    local traverser = builder_opts.traverser
    local debug_node = builder_opts.debug_node
    local stack = {}
    local result = {}

    -- Traverse out, pops from stack, adds to result
    local traverse_out = function()
      table.remove(stack, #stack)
    end

    -- Error does not add to result or anything
    local err = function(message)
      table.remove(stack, #stack)
      local path = vim.tbl_map(function(stack_node)
        return "[" .. vim.inspect(stack_node.key) .. "]"
      end, stack)
      print(("%s\n Occursed at key `%s`."):format(message, table.concat(path, "")))
      table.remove(result, #result)
    end

    local traverse_in
    traverse_in = function(key, node)
      table.insert(stack, { key = key, node = node })
      table.insert(result, { node = node, stack = vim.deepcopy(stack) })
      traverser(node, stack, traverse_in, traverse_out, err)
    end

    return function(tree, handler, opts)
      result = {} -- Reset result

      traverser(tree, stack, traverse_in, traverse_out, err)

      if opts.debug and debug_node then
        for _, value in ipairs(result) do
          debug_node(value.node, value.stack)
        end
      end

      for _, value in ipairs(result) do
        handler(value.node, value.stack)
      end
    end
  end,
}

--
-- EXAMPLE OF TRAVERSING MODULES
--

-- This example implements depth first traversal of doom modules

-- Here we define a new traverser for doom modules, instead of being
-- responsible for the traversal of the tree itself, tree_traverser allows us
-- to build a custom traversal algorithm specifically for our use case.

local modules_traverser = tree_traverser.build({
  -- Builds the traversal function defining how we should move through the tree
  -- @param node any The node itself
  -- @param next function(node: any) Traverse into the traverse_in node, adding the node to the stack
  -- @param traverse_out function() Traverses back a depth, pops the value from the stack
  -- @param err function(message: string) Traverses back a depth, this value is skipped by the handler (see below)
  traverser = function(node, stack, traverse_in, traverse_out, err)
    local parent = stack[#stack]
    local parent_is_section = (
      parent == nil or (type(parent.key) == "string" and type(parent.node) == "table")
    )
    if type(node) == "table" and parent_is_section then
      if vim.tbl_count(node) == 0 then
        traverse_out() -- Handle case if a table is empty.
      end
      for key, value in pairs(node) do
        traverse_in(key, value) -- Traverse into next layer.
      end
      traverse_out() -- Travel back up when a sub table has been completed.

    elseif type(node) == "string" and not parent_is_section then
      traverse_out() -- This is a leaf, traverse back a layer.
    else
      err(
        ("doom-nvim: Error traversing doom modules in `modules.lua`, unexpected value `%s`."):format(
          vim.inspect(node)
        )
      ) -- Traverse back a layer but do not pass this value to the handler function.
    end
  end,
  -- Optional debugging function that can be used to
  debug_node = function(node, stack)
    local parent = stack[#stack]
    local indent_str = string.rep("--", #stack)
    local indent_cap = type(node) == "table" and "+" or ">"
    print(("%s%s %s"):format(indent_str, indent_cap, type(node) == "table" and parent.key or node))
  end,
})

local modules = {
  FEATURES = {
    "feature_test",
    "feature_test2",
    EMPTY = {}, -- also handles this case, just in case...
    XXX = {
      "x1",
      "x2",
      YYY = {
        "aaa",
        "bbb",
        "ccc",
      },
    },
  },
  LANGS = {
    "language_test",
    "language_test2",
    -- 1,
    -- { "error" },
    -- nil,
  },
  -- 2,
  -- { "error" },
  -- nil,
}
local dm = require("doom.core.modules").enabled_modules

-- The second variable is a function to handle each node where we can implement
-- the node handling logic and do the task we need. modules_traverser can be
-- re-used anytime we want to iterate over a modules structure now.
modules_traverser(dm, function(node, stack)
  if type(node) == "string" then
    local path = vim.tbl_map(function(stack_node)
      return type(stack_node.key) == "string" and stack_node.key or stack_node.node
    end, stack)
    local path_string = "doom.modules." .. table.concat(path, ".")
    print(path_string)
  end
end, { debug = doom.settings.logging == "trace" or doom.settings.logging == "debug" })

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- print path output when ran on my `modules.lua`

-- doom.modules.core.doom
-- doom.modules.core.nest
-- doom.modules.core.treesitter
-- doom.modules.core.reloader
-- doom.modules.core.updater
-- doom.modules.langs.lua
-- doom.modules.langs.python
-- doom.modules.langs.bash
-- doom.modules.langs.javascript
-- doom.modules.langs.typescript
-- doom.modules.langs.css
-- doom.modules.langs.vue
-- doom.modules.langs.rust
-- doom.modules.langs.cc
-- doom.modules.langs.markdown
-- doom.modules.langs.dockerfile
-- doom.modules.themes.nvim.apprentice
-- doom.modules.themes.nvim.aurora
-- doom.modules.themes.nvim.cassiopeia
-- doom.modules.themes.nvim.catppuccin
-- doom.modules.themes.nvim.github
-- doom.modules.themes.nvim.gruvbox
-- doom.modules.themes.nvim.gruvbuddy
-- doom.modules.themes.nvim.material
-- doom.modules.themes.nvim.monochrome
-- doom.modules.themes.nvim.monokai
-- doom.modules.themes.nvim.moonlight
-- doom.modules.themes.nvim.neon
-- doom.modules.themes.nvim.nightfox
-- doom.modules.themes.nvim.nord
-- doom.modules.themes.nvim.nvcode
-- doom.modules.themes.nvim.nvim_deus
-- doom.modules.themes.nvim.oak
-- doom.modules.themes.nvim.oceanic_next
-- doom.modules.themes.nvim.one
-- doom.modules.themes.nvim.onedark
-- doom.modules.themes.nvim.onenord
-- doom.modules.themes.nvim.roshivim
-- doom.modules.themes.nvim.solarized
-- doom.modules.themes.nvim.sonokai
-- doom.modules.themes.nvim.spaceduck
-- doom.modules.themes.nvim.starry
-- doom.modules.themes.nvim.sunflower
-- doom.modules.themes.nvim.tokyonight
-- doom.modules.themes.nvim.vscode
-- doom.modules.themes.vim.ariake
-- doom.modules.themes.vim.iceberg
-- doom.modules.themes.vim.tender
-- -------------------------------------------------------------------------------
