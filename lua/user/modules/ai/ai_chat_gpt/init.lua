local chatgpt = {}

-- NOTE: prerequisit get api keys
--  https://platform.openai.com/account/api-keys

-- TODO: add fences to codeblocks
--
-- 1. add this to the default config.
-- 2. how do I use treesitter to highlight here
-- 3. ChatGPT.nvim/lua/chatgpt/module.lua
--    look at the `open_chat` function and
--    see how I can add code fence highlights
--    properly.

-- TODO: command to insert code from a chatgpt question.
--
-- 1. char sequence to open chat gpt for a question.
-- 2. close and await results to be inserted at cursor.
-- 3. see if I can reuse the spinner inline in code
--    to get a cool effect that makes it look nice while
--    waiting for the code.
-- 4. lock editing while waiting, and abort with <Esc> or
--    <C-c>

-- TODO: explain visual selection / object/motion
--
-- take the visual selection
--  -> put into chat gpt window
--    -> add `prefix phrase`, eg. explain the following snippet in detail
--      -> run this in a split window.
--
--  this should allow me to have anything explained on a whim.

-- DOCS:
-- https://platform.openai.com/docs/api-reference/introduction

-- PRICING:
--
--  pricing is pay as you use so this can be configured in the API
--  website.

chatgpt.settings = {
  -- welcome_message = "WELCOME_MESSAGE", -- set to "" if you don't like the fancy godot robot
  -- api_key_cmd = "secret get OPENAI",
  api_key_cmd = "op read op://api_tokens/OOpenAI/credential --no-newline",
  loading_text = "loading",
  question_sign = "", -- you can use emoji if you want e.g. 🙂
  answer_sign = "ﮧ", -- 🤖
  max_line_length = 120,
  yank_register = "+",
  chat_layout = {
    relative = "editor",
    position = "50%",
    size = {
      height = "80%",
      width = "80%",
    },
  },
  settings_window = {
    border = {
      style = "rounded",
      text = {
        top = " Settings ",
      },
    },
  },
  chat_window = {
    filetype = "chatgpt",
    border = {
      highlight = "FloatBorder",
      style = "rounded",
      text = {
        top = " ChatGPT ",
      },
    },
  },
  chat_input = {
    prompt = "  ",
    border = {
      highlight = "FloatBorder",
      style = "rounded",
      text = {
        top_align = "center",
        top = " Prompt ",
      },
    },
  },
  openai_params = {
    model = "text-davinci-003",
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 300,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
  openai_edit_params = {
    model = "code-davinci-edit-001",
    temperature = 0,
    top_p = 1,
    n = 1,
  },
  keymaps = {
    -- <C-c> to close chat window.
    -- <C-u> scroll up chat window.
    -- <C-d> scroll down chat window.
    -- <C-y> to copy/yank last answer.
    -- <C-o> Toggle settings window.
    -- <C-n> Start new session.
    -- <Tab> Cycle over windows.
    -- <C-i> [Edit Window] use response as input.
    close = { "<C-c>", "<Esc>" },
    yank_last = "<C-y>",
    scroll_up = "<C-u>",
    scroll_down = "<C-d>",
    toggle_settings = "<C-o>",
    new_session = "<C-n>",
    cycle_windows = "<Tab>",
  },
}

-- FIX: need to lazy load so I don't get prompted for 1pass on startup.

chatgpt.packages = {
  ["ChatGPT.nvim"] = {
    "jackMort/ChatGPT.nvim",
    dev = true,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  -- https://github.com/terror/chatgpt.nvim
}

chatgpt.configs = {}

chatgpt.configs["ChatGPT.nvim"] = function()
  require("chatgpt").setup(doom.modules.ai.ai_chat_gpt.settings)
end

chatgpt.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "A",
        name = "+ai",
        {
          {
            "c",
            name = "+ChatGPT",
            {
              {
                "t",
                function()
                  local job = require("plenary.job")

                  print("job", job)
                  print("secret testing START")

                  job
                      :new({
                        command = "secret",
                        args = { "get", "OPENAI" },
                        on_stdout = function(j, exit_code)
                          if j ~= nil then
                            local value = j:result() --[1]:gsub("%s+$", "")
                            print("stdout:", vim.inspect(value), exit_code)
                          else
                            print("stdout nothing")
                          end
                        end,
                        on_exit = function(j, exit_code)
                          if j ~= nil then
                            local value = j:result()[1]:gsub("%s+$", "")
                            print("exit:", vim.inspect(value), exit_code)
                          else
                            print("exit nothing")
                          end
                        end,
                        on_stderr = function(j, exit_code)
                          if j ~= nil then
                            local value = j:result() --[1]:gsub("%s+$", "")
                            print("stderr:", vim.inspect(value), exit_code)
                          else
                            print("err nothing")
                          end
                        end,
                      })
                      :start()

                  print("secret testing END")
                end,
                name = "test secret cmd",
              },
              { "c", [[<cmd>ChatGPT<CR>]], name = "Open" },
              --    command which opens a prompt selection from Awesome ChatGPT Prompts to be used with the ChatGPT.
              --    https://github.com/f/awesome-chatgpt-prompts
              { "s", [[<cmd>ChatGPTActAs<CR>]], name = "Act As" },
              -- command which opens interactive window to edit selected text or whole window - demo video.
              { "e", [[<cmd>ChatGPTEditWithInstructions<CR>]], name = "Edit With Instructions" },
            },
          },
        },
      },
    },
  },
}

return chatgpt
