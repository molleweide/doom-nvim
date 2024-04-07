local leap = {}

leap.packages = {
  ["leap.nvim"] = { "ggandor/leap.nvim" },
}

-- leap.configs = {}
-- leap.configs["leap.nvim"] = function()
--   require("leap").opts.max_phase_one_targets = nil
--   require("leap").opts.highlight_unlabeled_phase_one_targets = false
--   require("leap").opts.max_highlighted_traversal_targets = 10
--   require("leap").opts.case_sensitive = false
--   require("leap").opts.equivalence_classes = { " \t\r\n" }
--   require("leap").opts.substitute_chars = {}
--   -- require("leap").opts.safe_labels = { 's', 'f', 'n', 'u', 't', . . . }
--   -- require("leap").opts.labels = { 's', 'f', 'n', 'j', 'k', . . . }
--   require("leap").opts.special_keys = {
--     repeat_search = "<enter>",
--     next_phase_one_target = "<enter>",
--     next_target = { "<enter>", ";" },
--     prev_target = { "<tab>", "," },
--     next_group = "<space>",
--     prev_group = "<tab>",
--     multi_accept = "<enter>",
--     multi_revert = "<backspace>",
--   }
-- end

-- leap.binds = {}

return leap
