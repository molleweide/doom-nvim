local luasnip = require("luasnip")
local s = luasnip.s --> snnipet
local i = luasnip.i --> insert node
local t = luasnip.t --> text node

local c = luasnip.choice_node
local d = luasnip.dynamic_node
local f = luasnip.function_node
local sn = luasnip.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

--
-- SNIPPETS
--

local snippets = {
  s(
    "arrow",
    fmt(
      [[
    const {} = ({}) => {{
      {}
    }}
    ]],
      {
        i(1, "name"),
        i(2, "args"),
        i(3, "body"),
      }
    )
  ),
}
-- table.insert(snippets, arrow)

-- local snippets = {
--   -- useState snippet
--   luasnip.s(
--     {
--       trig = "us",
--       name = "useState"
--     },
--     {
--       luasnip.t("const ["),
--       luasnip.i(1),
--       luasnip.t(", "),
--       luasnip.f(
--           function(args)
--             local capitalized_state = args[1][1]:gsub("^%l", string.upper)
--             return "set" .. capitalized_state
--           end,
--           {1}
--       ),
--       luasnip.t("] = useState("),
--       luasnip.i(2),
--       luasnip.t(")")
--     }
--   )
-- }
--

local usestate = s({
  trig = "useStateSnippet",
  dscr = "React useState snippet",
}, {
  t("const ["),
  i(1, "myVar"),
  t(", "),
  f(function(args, snip)
    return "set"
      .. string.sub(args[1][1], 1, 1):upper()
      .. string.sub(args[1][1], 2, args[1][1]:len())
  end, 1),
  t("] = useState("),
  i(2),
  t(")"),
})
table.insert(snippets, usestate)

--
-- AUTOSNIPPETS
--

local autosnippets = {}

local cc = s(
  {
    trig = "cc",
    dscr = "Create react component",
  },
  fmt(
    [[
import React from "react";

const {} = ({}) => {{
  return <div>{}</div>;
}};

export default {};{}
    ]],
    {
      d(1, function(args, parent)
        local env = parent.snippet.env
        return sn(nil, i(1, env.TM_FILENAME:match("(.+)%..+")))
      end),
      c(2, { i(1, "props"), i(2, "") }),
      d(3, function(args, parent)
        return sn(nil, i(1, args[1]))
      end, { 1 }),
      rep(1),
      i(0, ""),
    }
  )
)

table.insert(autosnippets, cc)

return snippets, autosnippets

-- local saferequire = require 'user.util.saferequire'
-- local ls = saferequire 'luasnip'
-- if not ls then
--     return
-- end
--
-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require 'luasnip.util.events'
-- local ai = require 'luasnip.nodes.absolute_indexer'
-- local fmt = require('luasnip.extras.fmt').fmt
-- local rep = require('luasnip.extras').rep
-- local m = require('luasnip.extras').m
-- local lambda = require('luasnip.extras').l
-- local postfix = require('luasnip.extras.postfix').postfix
--
-- local snippets = {}
--
-- local pinnalce_react_memo_template = [[
-- import React from "react";
-- import {{ReactUtil}} from "@pinnacle0/web-ui/util/ReactUtil"
--
-- export const {} = ReactUtil.memo("{}", () => {{
--     return <div{}/>
-- }})
-- ]]
--
-- local get_component_name = function()
--     local filename = vim.fn.expand '%'
--     if not string.match(filename, 'index.ts') then
--         return vim.fn.expand '%:p:t:r'
--     else
--         return vim.fn.expand '%:h:t'
--     end
-- end
--
-- table.insert(
--     snippets,
--     s('pfc', fmt(pinnalce_react_memo_template, { f(get_component_name), f(get_component_name), i(1) }))
-- )
--
-- local react_props_type_template = [[
-- interface Props {{
--     {}
-- }}
-- ]]
-- table.insert(snippets, s('propst', fmt(react_props_type_template, { i(1) })))
--
-- return snippets

-- local ls = require("luasnip")
-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.expand_conditions")
--
-- local capitalizeString = function(arg)
--   return (arg[1][1]:gsub("^%l", string.upper))
-- end
--
-- local returnFileName = function(_, snip)
--   return snip.env.TM_FILENAME:match("(.+)%..+")
-- end
--
-- ls.add_snippets(nil, {
--   typescriptreact = {
--     s("us", {
--       t("const ["), i(1, "name"), t(", set"), f(capitalizeString, 1), t("] = useState("), i(2, "defaultValue"), t(")")
--     }),
--     s({
--       trig = "rfc",
--       name = "React func component",
--       dscr = "Create a React Functional Component",
--       docstring = "Create a React Functional Component"
--     }, fmt([[
-- import React, {{FC}} from 'react'
--
-- type {}Props = {{
--   {}
-- }}
--
-- const {}:FC<{}Props> = ({}) => {{
--   return {}
-- }}
--
-- export default {};
--     ]], {
--       f(returnFileName), i(1, ""), f(returnFileName), f(returnFileName), i(2, "props"), i(0, "<div/>"), f(returnFileName)
--     })),
--     s("ue", fmt([[
--     useEffect(() => {{
--       {}
--     }}, [{}])
--     ]], {
--     i(1, "effect"), i(0, "deps")
--     }))
--   },
--   all = {
--     s('func', fmt([[const {} = () => {{
--       {}
--     }}]], { i(1, "funcName"), i(0, "body") })),
--     s('log', {t("console.log("), i(0), t(")")})
--   }
-- })

-- local ls = require("luasnip")
-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local extras = require("luasnip.extras")
-- local l = extras.lambda
-- local rep = extras.rep
-- local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
--
-- local luasnipUtils = require("zanja.utils.luasnip")
--
-- local snippets = {}
--
-- local computePropTypes = function(index)
--   return f(function(args, parent_args, user_args)
--     local propsList = args[1][1]
--     local props = string.gmatch(propsList, "[^%s]+")
--     local finalString = ""
--     for prop in props do
--       local finalPropStr = prop
--       if string.find(prop, ",") then
--         finalPropStr = string.sub(prop, 1, -2)
--       end
--       finalString = finalString .. finalPropStr .. ": PropTypes.string,"
--     end
--     return finalString
--   end, { index })
-- end
--
-- local computeDefaultProps = function(index)
--   return f(function(args, parent_args, user_args)
--     local propsList = args[1][1]
--     local props = string.gmatch(propsList, "[^%s]+")
--     local finalString = ""
--     for prop in props do
--       local finalPropStr = prop
--       if string.find(prop, ",") then
--         finalPropStr = string.sub(prop, 1, -2)
--       end
--       finalString = finalString .. finalPropStr .. ': "",'
--     end
--     return finalString
--   end, { index })
-- end
--
-- local componentSnippet = s(
--   "component",
--   fmt(
--     [[
-- import React from "react";
-- import PropTypes from "prop-types";
--
-- function {}(props) {{
--   const {{ {} }} = props;
--
--   return (
--     <div>{}</div>
--   );
-- }}
--
-- {}.propTypes = {{
--   {}
-- }};
-- {}.defaultProps = {{
--   {}
-- }};
-- export default {};
--       ]],
--     {
--       luasnipUtils.filenameBase(),
--       i(1),
--       i(0),
--       luasnipUtils.filenameBase(),
--       computePropTypes(1),
--       luasnipUtils.filenameBase(),
--       computeDefaultProps(1),
--       luasnipUtils.filenameBase(),
--     },
--     {}
--   )
-- )
--
-- table.insert(snippets, componentSnippet)
--
-- local propTypesSnippet = s(
--   "proptypes",
--   fmt(
--     [[
-- {}.propTypes = {{
--   {}
-- }};
-- {}.defaultProps = {{
--   {}
-- }};
--     ]],
--     {
--       luasnipUtils.filenameBase(),
--       i(1),
--       luasnipUtils.filenameBase(),
--       rep(1),
--     },
--     {}
--   )
-- )
--
-- table.insert(snippets, propTypesSnippet)
--
-- local reactSnippets = require("zanja.utils.snippets.react")
-- for _, value in pairs(reactSnippets) do
--   table.insert(snippets, value)
-- end
--
-- return snippets

-- local status, ls = pcall(require, 'luasnip')
--
-- if (not status) then
--   print('luasnip not found')
--   return
-- end
--
-- -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#snipmate
--
-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local extras = require("luasnip.extras")
-- local l = extras.lambda
-- local rep = extras.rep
-- local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
--
-- local object_assign = function(t1, t2)
--   local newObject = {};
--
--   for _, value in ipairs(t1) do
--     table.insert(newObject, value)
--   end
--
--   for _, value in ipairs(t2) do
--     table.insert(newObject, value)
--   end
--
--   return newObject
-- end
--
-- local COMMON = {
--   parse('func', 'function ${1}({${2}}){\n${3}\n}'),
--   parse('cfunc', 'const ${1} = ({${2}}) =>{\n${3}\n}'),
--   parse('log', 'console.log({\n${1}\n})')
-- }
--
-- local REACT = {
--   s('rfc', {
--     t { "import React from 'react';", "" },
--     t 'function ',
--     i(1),
--     t '({', i(2),
--     t { "}){", "", "\treturn (", "\t\t" },
--     i(3),
--     t { "", "\t)", "" },
--     t { "}", "", "", },
--     f(function(args)
--       return 'export default ' .. args[1][1] .. ''
--     end,
--       { 1 }
--     ),
--     t { ";" }
--   }),
--   parse('cl', "className={${1}}"),
--   parse('clcn', "className={cn(${1})}"),
-- }
--
-- ls.add_snippets("javascript", COMMON)
-- ls.add_snippets("javascriptreact", object_assign(COMMON, REACT))
--
-- ls.add_snippets("typescript", COMMON)
-- ls.add_snippets("typescriptreact", object_assign(COMMON, REACT))

-- local ls = require "luasnip"
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node
-- local types = require "luasnip.util.types"
-- local rep = require "luasnip.extras".rep
-- local snippet = ls.parser.parse_snippet
--
-- ls.config.set_config {
--   history = true,
--   updateevents = "TextChanged,TextChangedI",
--   ext_opts = {
--     [types.choiceNode] = {
--       active = {
--         virt_text = { { "🤔", "Comment" } }
--       }
--     }
--   },
--   enable_autosnippets = true
-- }
--
-- require("luasnip.loaders.from_vscode").lazy_load()
--
-- ls.add_snippets(
--   "javascript",
--   {
--     snippet("im", "import { $2 } from '$1';"),
--     snippet("ex", "export * from '$1';"),
--     snippet("co", "console.log('$1');"),
--     snippet("exp", "export const ${1:name} = (${2:params}) => $3;"),
--     snippet("for", "for (let ${1:i} = 0; $1 < ${2:length}; $1++) {\n\t$3\n}"),
--     snippet("it", "it('${1:test}', () => {\n\t$2\n});"),
--     s(
--       "des",
--       {
--         t("describe('"),
--         i(1, "test"),
--         t(
--           {
--             "', () => {",
--             "\tconst cases = [",
--             "\t\t['Case 1', {}, []],",
--             "\t\t['Case 2', {}, []],",
--             "\t];",
--             "",
--             "\tit.each(cases)('%s', (_title, args, expected) => {",
--             "\t\texpect("
--           }
--         ),
--         i(2, "func"),
--         t(
--           {
--             "(args)).toEqual(expected);",
--             "\t});",
--             "});"
--           }
--         )
--       }
--     )
--   }
-- )
--
-- ls.add_snippets(
--   "javascriptreact",
--   {
--     s(
--       "re",
--       {
--         t(
--           {
--             "import React from 'react';",
--             "import PropTypes from 'prop-types';",
--             "",
--             "export const "
--           }
--         ),
--         i(1, "Component"),
--         t(" = ({ "),
--         i(2, "prop"),
--         t({ " }) => {", "\t" }),
--         i(3),
--         t({ "", "};", "", "" }),
--         rep(1),
--         t({ ".propTypes = {", "\t" }),
--         rep(2),
--         t({ ": PropTypes.string,", "" }),
--         t({ "};" })
--       }
--     )
--   }
-- )
--
-- ls.add_snippets(
--   "typescriptreact",
--   {
--     s(
--       "re",
--       {
--         t(
--           {
--             "import React from 'react';",
--             "",
--             "interface Props {",
--             "\tparam1: string;",
--             "}",
--             "",
--             "export const "
--           }
--         ),
--         i(1, "Component"),
--         t(
--           {
--             ": React.FC<Props> = ({}) => {",
--             "\treturn <div>{props.chilren}</div>;",
--             "};"
--           }
--         )
--       }
--     )
--   }
-- )
--
-- ls.add_snippets(
--   "tex",
--   {
--     snippet("list", "\\begin{${1|enumerate,itemize|}}\n\t\\item ${2:item}\n\\end{$1}")
--   }
-- )
--
-- ls.filetype_extend("javascriptreact", { "javascript" })
-- ls.filetype_extend("typescript", { "javascript" })
-- ls.filetype_extend("typescriptreact", { "javascript" })
-- ls.filetype_extend("mdx", { "javascript", "typescript", "typescriptreact" })
--
-- --
-- -- keymaps
-- --
--
-- vim.keymap.set("i", "<C-E>", "<Plug>luasnip-next-choice", { desc = "Luasnip: Next choice" })
-- vim.keymap.set("s", "<C-E>", "<Plug>luasnip-next-choice", { desc = "Luasnip: Next choice" })

-- local luasnip = require("luasnip")
--
-- local snippets = {
--   -- public async method
--   luasnip.s(
--     {
--       trig = "ameth",
--       name = "public async method"
--     },
--     {
--       luasnip.t("public async "),
--       luasnip.i(1),
--       luasnip.t("("),
--       luasnip.i(2),
--       luasnip.t("): Promise<"),
--       luasnip.i(3, "void"),
--       luasnip.t("> {"),
--       luasnip.t({
--           "",
--           "  throw new Error('not implemented');"
--         }),
--       luasnip.i(0),
--       luasnip.t({
--           "",
--           "}"
--         })
--     }
--     ),
--   -- private async method
--   luasnip.s(
--     {
--       trig = "pameth",
--       name = "private async method"
--     },
--     {
--       luasnip.t("private async "),
--       luasnip.i(1),
--       luasnip.t("("),
--       luasnip.i(2),
--       luasnip.t("): Promise<"),
--       luasnip.i(3, "void"),
--       luasnip.t("> {"),
--       luasnip.t({
--           "",
--           "  throw new Error('not implemented');"
--         }),
--       luasnip.i(0),
--       luasnip.t({
--           "",
--           "}"
--         })
--     }
--     ),
--   -- public method
--   luasnip.s(
--     {
--       trig = "meth",
--       name = "public method"
--     },
--     {
--       luasnip.t("public "),
--       luasnip.i(1),
--       luasnip.t("("),
--       luasnip.i(2),
--       luasnip.t("): "),
--       luasnip.i(3, "void"),
--       luasnip.t(" {"),
--       luasnip.t({
--           "",
--           "  throw new Error('not implemented');"
--         }),
--       luasnip.i(0),
--       luasnip.t({
--           "",
--           "}"
--         })
--     }
--     ),
--   -- private method
--   luasnip.s(
--     {
--       trig = "pmeth",
--       name = "private method"
--     },
--     {
--       luasnip.t("public "),
--       luasnip.i(1),
--       luasnip.t("("),
--       luasnip.i(2),
--       luasnip.t("): "),
--       luasnip.i(3, "void"),
--       luasnip.t(" {"),
--       luasnip.t({
--           "",
--           "  throw new Error('not implemented');"
--         }),
--       luasnip.i(0),
--       luasnip.t({
--           "",
--           "}"
--         })
--     }
--     )
-- }
--
-- return snippets

-- local luasnip = require('luasnip')
--
-- local snippet = luasnip.s
-- local ins_node = luasnip.i
-- -- local text_node = luasnip.t
-- -- local dynamic_node = luasnip.dynamic_node
-- -- local choice_node = luasnip.choice_node
-- -- local function_node = luasnip.function_node
-- -- local snippet_node = luasnip.snippet_node
--
-- local format = require('luasnip.extras.fmt').fmt
-- local rep_node = require('luasnip.extras').rep
--
-- local snippets, autosnippets = {}, {}
--
-- local function create_snippet(context, nodes, opts)
-- 	local new_snippet = snippet(context, nodes, opts)
-- 	table.insert(snippets, new_snippet)
-- end
--
-- create_snippet(
-- 	{
-- 		trig = 'FC (React Functional Component)',
-- 		name = 'React Functional Component',
-- 		dscr = 'Expands to a React functional component declaration',
-- 	},
-- 	format(
-- 		[[
-- interface Props extends ComponentProps<{}> {{}}
--
-- const {}: FC<Props> = () => {{
--   return (
--     <></>
--   );
-- }};
--
-- export {{ {} }};
-- ]],
-- 		{
-- 			ins_node(1, 'typeof InnerComponent'),
-- 			ins_node(2, 'ComponentName'),
-- 			rep_node(2),
-- 		}
-- 	)
-- )
--
-- create_snippet(
-- 	{
-- 		trig = "it('should",
-- 		name = "Jest it('should ...') block",
-- 		dscr = 'Expands to a Jest it case scenario',
-- 	},
-- 	format(
-- 		[[
-- it('should TODO', async () => {{
--   {}
-- }});
-- ]],
-- 		{
-- 			ins_node(0),
-- 		}
-- 	)
-- )
--
-- create_snippet(
-- 	{
-- 		trig = 'beforeEach()',
-- 		name = 'Jest beforeEach() block',
-- 		dscr = 'Expands to a Jest beforeEach block',
-- 	},
-- 	format(
-- 		[[
-- beforeEach(() => {{
--   {}
-- }});
-- ]],
-- 		{
-- 			ins_node(0),
-- 		}
-- 	)
-- )
--
-- create_snippet(
-- 	{
-- 		trig = 'jest.mock()',
-- 		name = 'Jest mock() block',
-- 		dscr = 'Expands to a Jest mock block',
-- 	},
-- 	format(
-- 		[[
-- jest.mock("{}", () => ({{
--   {}: jest.fn(),
-- }}));
-- ]],
-- 		{
-- 			ins_node(1, 'module'),
-- 			ins_node(2, 'exportedFunction'),
-- 		}
-- 	)
-- )
--
-- return snippets, autosnippets

-- local luasnip = require("luasnip")
-- local utils = require("config.luasnip.utils")
--
-- local snippet = luasnip.snippet
-- local i = luasnip.insert_node
-- local fmt = require("luasnip.extras.fmt").fmt
--
-- return {
-- 	snippet(
-- 		"fc",
-- 		fmt(
-- 			[[
--       import React from 'react';
--
--       export interface {}Props {{}}
--
--       export const {}: React.FC<{}Props> = ({{}}) => {{
--         return (
--           <div>{}</div>
--         );
--       }};
--       ]],
-- 			{ utils.file_name(), utils.file_name(), utils.file_name(), i(0) }
-- 		)
-- 	),
-- 	snippet(
-- 		"ue",
-- 		fmt(
-- 			[[
--       useEffect(() => {{
--         {}
--       }}, [{}])
--       ]],
-- 			{ i(1), i(0) }
-- 		)
-- 	),
-- 	snippet(
-- 		"us",
-- 		fmt(
-- 			"const [{}, set{}] = useState()",
-- 			{ i(1), utils.mirror(1, function(args)
-- 				return args[1][1]:gsub("^%l", string.upper)
-- 			end) }
-- 		)
-- 	),
-- }

-- local luasnip = require("luasnip")
-- local fmt = require("luasnip.extras.fmt").fmt
-- local rep = require("luasnip.extras").rep
--
-- local snippet = luasnip.s
-- local insert_node = luasnip.insert_node
-- local function_node = luasnip.function_node
--
-- return {
--   snippet(
--     { trig = "rfc", name = "React functional component" },
--     fmt(
--       [[
--           import React from 'react';
--
--           const {} = (): JSX.Element => {{
--             return (
--               <div>
--                 {}
--               </div>
--             )
--           }}
--
--           export default {};
--         ]],
--       { insert_node(1, "Component"), rep(1), rep(1) }
--     )
--   ),
--   snippet(
--     {
--       trig = "us",
--       name = "useState",
--       desc = "useState with type annotation",
--     },
--     fmt([[const [{state}, {setState}] = useState({initial_value})]], {
--       state = insert_node(1),
--       setState = function_node(function(args)
--         if args[1][1]:len() > 0 then
--           return "set" .. args[1][1]:sub(1, 1):upper() .. args[1][1]:sub(2)
--         else
--           return ""
--         end
--       end, 1),
--       initial_value = insert_node(0),
--     })
--   ),
--   snippet(
--     {
--       trig = "ue",
--       name = "useEffect",
--       desc = "useEffect",
--     },
--     fmt(
--       [[
--           useEffect(() => {{
--             {body}
--           }}, [{deps}])
--         ]],
--       {
--         body = insert_node(0),
--         deps = insert_node(1),
--       }
--     )
--   ),
--   snippet(
--     {
--       trig = "cn",
--       name = "className",
--       desc = "Insert className attribute",
--     },
--     fmt([[className={{{}}}]], {
--       insert_node(0),
--     })
--   ),
-- }
