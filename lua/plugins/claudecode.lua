return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    
    -- Core Claude operations
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>aq", "<cmd>ClaudeCodeQuit<cr>", desc = "Quit Claude" },
    
    -- File and buffer management
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>aB", "<cmd>ClaudeCodeAdd .<cr>", desc = "Add current directory" },
    { "<leader>al", "<cmd>ClaudeCodeList<cr>", desc = "List added files" },
    { "<leader>ax", "<cmd>ClaudeCodeClear<cr>", desc = "Clear all files" },
    
    -- Send content to Claude
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    { "<leader>aS", "<cmd>ClaudeCodeSend<cr>", desc = "Send current line" },
    { "<leader>ap", "<cmd>ClaudeCodeSendParagraph<cr>", desc = "Send paragraph" },
    { "<leader>aw", "<cmd>ClaudeCodeSendWord<cr>", desc = "Send word under cursor" },
    
    -- Tree file operations
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file from tree",
      ft = { "NvimTree", "neo-tree", "oil" },
    },
    
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    { "<leader>an", "<cmd>ClaudeCodeDiffNext<cr>", desc = "Next diff" },
    { "<leader>aP", "<cmd>ClaudeCodeDiffPrev<cr>", desc = "Previous diff" },
    
    -- Quick actions
    { "<leader>ai", "<cmd>ClaudeCode implement this function<cr>", desc = "Implement function" },
    { "<leader>ae", "<cmd>ClaudeCode explain this code<cr>", desc = "Explain code" },
    { "<leader>at", "<cmd>ClaudeCode write tests for this<cr>", desc = "Write tests" },
    { "<leader>ao", "<cmd>ClaudeCode optimize this code<cr>", desc = "Optimize code" },
    { "<leader>aD", "<cmd>ClaudeCode add documentation<cr>", desc = "Add documentation" },
  },
}
