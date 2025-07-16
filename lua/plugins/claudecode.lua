return {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("claude-code").setup({
      -- Terminal window configuration
      window = {
        position = "right",
        width = 0.4,
        height = 0.8,
        floating = false,
      },
      -- File refresh settings
      refresh_files = true,
      -- Git project detection
      git_project = true,
      -- Command variants
      commands = {
        default = "claude-code",
        continue = "claude-code --continue",
        resume = "claude-code --resume",
      },
      -- Disable default keymaps (we'll define our own)
      keymaps = false,
    })
  end,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    
    -- Cursor-like flow
    { "<C-k>", "<cmd>ClaudeCode<cr>", mode = { "n", "v" }, desc = "Chat with Claude" },
    
    -- Core Claude operations
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>ar", "<cmd>ClaudeCodeResume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCodeContinue<cr>", desc = "Continue Claude" },
    { "<leader>av", "<cmd>ClaudeCodeVerbose<cr>", desc = "Verbose mode" },
  },
}
