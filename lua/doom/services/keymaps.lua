---
-- MIT License
--
-- Copyright (c) 2021 Leon Strauss, Connor Meehan
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- TODO: ATTACH MODULE ORIGIN TO ALL BINDS
-- If I attach the module in which all binds are created to the tree,
-- then it would be much easier to get back to a specific bind where it was
-- created so that you can always update anything on the fly.
-- Try first just adding the module string to each bind and see what happens
-- when logging binds with the mapper.
-- (Should the same be done for commands/autocmds??)
-- FIX: This should be done in the `nest` module.

-- TODO: Could the above be used also to then TS query the module so that we
-- can put the cursor back exactly where the bind was created.

local module = {}

--[[
--     TYPES
--]]

--- Extra options that will be passed to nvim when binding keymaps
--- @class NestSettingsOptions
--- @field noremap boolean
--- @field silent boolean
--- @field expr boolean

--- Stores the current keymap state/settings including lhs/prefix
--- @class NestSettings
--- @field buffer boolean|number
--- @field prefix string
--- @field options NestSettingsOptions
--- @field mode string

--- Internal type for a node in a nest.nvim config, this is how the end-user will define their config
--- @class NestNode : NestSettings
--- @field [1] string|table<number, NestNode>
--- @field [2] string|function|table<number,NestNode>
--- @field [3] string|nil Name
--- @field name string|nil Name
--- @field [4] string|nil Description
--- @field description string|nil Description

--- Type definition for nest.nvim integration
--- @class NestIntegration
--- @field name string
--- @field on_init function|nil
--- @field handler function
--- @field on_complete function|nil

--- Paramater passed to handler of NestIntegration
--- @class NestIntegrationNode
--- @field lhs string
--- @field rhs table<number, NestNode>|string
--- @field name string
--- @field description string

--[[
--     EXAMPLE
--]]

-- lsp.binds = function()
--     return {
--         { "K", vim.lsp.buf.hover, name = "Show hover doc" },
--         {
--             "[d",
--             function()
--                 vim.diagnostic.jump({ count = -1 })
--             end,
--             name = "Jump to prev diagnostic",
--         },
--         {
--             "]d",
--             function()
--                 vim.diagnostic.jump({ count = 1 })
--             end,
--             name = "Jump to next diagnostic",
--         },
--         {
--             "g",
--             {
--                 { "D", vim.lsp.buf.declaration, "Jump to declaration" },
--                 { "d", vim.lsp.buf.definition, name = "Jump to definition" },
--                 { "r", vim.lsp.buf.references, name = "Jump to references" },
--                 { "I", vim.lsp.buf.implementation, name = "Jump to implementation" },
--                 { "a", vim.lsp.buf.code_action, name = "Do code action" },
--             },
--         },
--         {
--             "<C-",
--             {
--                 {
--                     "p>",
--                     function()
--                         vim.diagnostic.jump({ count = -1 })
--                     end,
--                     name = "Jump to prev diagnostic",
--                 },
--                 {
--                     "n>",
--                     function()
--                         vim.diagnostic.jump({ count = 1 })
--                     end,
--                     name = "Jump to next diagnostic",
--                 },
--                 {
--                     "k>",
--                     vim.lsp.buf.signature_help,
--                     name = "Show signature help",
--                 },
--             },
--         },
--         {
--             "<leader>",
--             name = "+prefix",
--             {
--                 {
--                     "c",
--                     name = "+code",
--                     {
--                         { "r", vim.lsp.buf.rename, name = "Rename" },
--                         { "a", vim.lsp.buf.code_action, name = "Do action" },
--                         { "t", vim.lsp.buf.type_definition, name = "Jump to type" },

--[[
--     UTILS
--]]

--- Defaults being applied to `applyKeymaps`
-- Can be modified to change defaults applied.
--- @type NestSettings
module.defaults = {
  mode = "n",
  prefix = "",
  buffer = false,
  options = {
    noremap = true,
    silent = true,
  },
}

local function copy(table)
  return vim.deepcopy(table)
end

local function mergeTables(left, right)
  return vim.tbl_extend("force", left, right)
end

-- NOTE: isnt this just a vim.tbl_deep_extend()??
--
--- @param left NestSettings
--- @param right NestSettings
--- @return NestSettings
local function mergeSettings(left, right)
  local ret = copy(left)

  if right == nil then
    return ret
  end

  if right.mode ~= nil then
    ret.mode = right.mode
  end

  if right.buffer ~= nil then
    ret.buffer = right.buffer
  end

  if right.prefix ~= nil then
    ret.prefix = ret.prefix .. right.prefix
  end

  if right.options ~= nil then
    ret.options = mergeTables(ret.options, right.options)
  end

  return ret
end

--[[
--     INTEGRATIONS
--]]
-- Stores all the different handlers for the nest API
module.integrations = {}

-- Allows adding extra keymap integrations
--- @param integration NestIntegration
module.enable = function(integration)
  if integration.name ~= nil then
    module.integrations[integration.name] = integration
  end
end

--- Default nest integration that binds keymaps
--- @type NestIntegration
local default_integration = {}
default_integration.name = "nest"
default_integration.handler = function(node, node_settings)
  -- Skip tables (keymap groups)
  if type(node.rhs) == "table" then
    return
  end

  for mode in string.gmatch(node_settings.mode, ".") do
    local sanitizedMode = mode == "_" and "" or mode

    local buffer = (node_settings.buffer == true) and 0 or node_settings.buffer

    local options = vim.tbl_extend("force", {
      buffer = buffer,
    }, node_settings.options)
    vim.keymap.set(sanitizedMode, node.lhs, node.rhs, options)
  end
end

-- Bind default_integration keymap handler
module.enable(default_integration)

--[[
--     TRAVERSING CONFIG
--]]

--- @param node NestNode
--- @param settings NestSettings|nil
module.traverse = function(node, settings, integrations)
  local mergedSettings = mergeSettings(settings or module.defaults, node)
  local first = node[1]

  -- :: NODE CONTAINER ::
  --
  -- Top level of config, just traverse into each keymap/keymap group
  --
  -- Enter here in two cases. 1. if it is the top level of config, ie. the
  -- <module>.bind table itself { {...}, {...} }, or 2. it is when entering
  -- the child-container table of a branch node.
  --
  if type(first) == "table" then
    for _, child_node in ipairs(node) do
      module.traverse(child_node, mergedSettings, integrations)
    end
    return
  end

  -- TYPE [2] ==  TABLE -> BRANCH W/ CHILD CONTAINER
  --              ELSE  -> LEAF

  -- A branch node can have all the same props as a Leaf node.

  -- First must be a string, append first to the prefix
  mergedSettings.prefix = mergedSettings.prefix .. first
  local second = node[2]

  --- @type string|table<number, NestNode>
  local rhs = second

  -- Populate node.name and node.description if necessary
  if node.name == nil and #node >= 3 then
    node.name = node[3]
  end
  if node.description == nil and #node >= 4 then
    node.description = node[4]
  end
  node.lhs = mergedSettings.prefix
  node.rhs = rhs

  -- Pass current keymap node to all integrations
  for _, integration in pairs(integrations) do
    integration.handler(node, mergedSettings, module.global_opts)
  end

  -- :: HAS NODE CONTAINER -> BRANCH ::

  if type(rhs) == "table" then
    module.traverse(rhs, mergedSettings, integrations)
  end
end

--[[
--    ENTRY POINT
--]]

--- Applies the given `keymapConfig`, creating nvim keymaps
--- @param nest_config table<number, NestNode>
--- @param settings NestSettings|nil
--- @param integrations table<number, NestIntegration> User can parse the nest config with a subset of integrations
module.applyKeymaps = function(nest_config, settings, integrations, opts)
  local ints = integrations or module.integrations

  module.global_opts = opts or {}

  -- Pre hooks
  for _, integration in pairs(ints) do
    if integration.on_init ~= nil then
      integration.on_init(nest_config, settings)
    end
  end

  module.traverse(nest_config, settings, ints)

  -- Post hooks
  for _, integration in pairs(ints) do
    if integration.on_complete ~= nil then
      integration.on_complete()
    end
  end
end

return module
