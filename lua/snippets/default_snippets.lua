local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
	lua = {
	    s("default_test", { t("-- default test") }),
	}
}
