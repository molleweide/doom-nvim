local u_text_manipulation = {}

u_text_manipulation.description = [[
A powerful Lua library designed to enhance your text manipulation experience in
NeoVim, focusing on text-manipulation utilities. This includes a Range utility,
allowing you to work efficiently with text selections based on various
conditions, as well as a declarative Render-er, making coding and editing more
intuitive and productive.

- Rendering System: a utility that can declaratively render NeoVim-specific
    hyperscript into a buffer, supporting creating/managing extmarks, highlights,
    and key-event handling (requires NeoVim >0.11)
- Signals: a simple dependency tracking system that pairs well with the
    rendering utilities for creating reactive/interactive UIs in NeoVim.
- Range Utility: Get context-aware selections with ease. Replace regions with
    new text. Think of it as a programmatic way to work with visual selections (or
    regions of text).
- Code Writer: Write code with automatic indentation and formatting.
- Operator Key Mapping: Flexible key mapping that works with the selected text.
- Text and Position Utilities: Convenient functions to manage text objects and
    cursor positions.
]]

u_text_manipulation.packages = {
    ["u.nvim"] = { "jrop/u.nvim", branch = "v2" },
}

return u_text_manipulation
