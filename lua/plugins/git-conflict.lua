-- Git-Conflict - Visualize and resolve merge conflicts
return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = false,
        list_opener = "copen",
        highlights = {
          incoming = "DiffAdd",
          current = "DiffText",
          ancestor = "DiffChange",
        },
      })

      -- Custom highlights to match your theme
      vim.api.nvim_set_hl(0, "GitConflictCurrent", { bg = "#2d3149", fg = "#7c3aed" })
      vim.api.nvim_set_hl(0, "GitConflictIncoming", { bg = "#2d3149", fg = "#10b981" })
      vim.api.nvim_set_hl(0, "GitConflictAncestor", { bg = "#2d3149", fg = "#f59e0b" })
      vim.api.nvim_set_hl(0, "GitConflictCurrentLabel", { bg = "#7c3aed", fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "GitConflictIncomingLabel", { bg = "#10b981", fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "GitConflictAncestorLabel", { bg = "#f59e0b", fg = "#000000", bold = true })
    end,
    keys = {
      {
        "<leader>gco",
        "<cmd>GitConflictChooseOurs<cr>",
        desc = "Choose Ours (Current Changes)",
      },
      {
        "<leader>gct",
        "<cmd>GitConflictChooseTheirs<cr>",
        desc = "Choose Theirs (Incoming Changes)",
      },
      {
        "<leader>gcb",
        "<cmd>GitConflictChooseBoth<cr>",
        desc = "Choose Both",
      },
      {
        "<leader>gc0",
        "<cmd>GitConflictChooseNone<cr>",
        desc = "Choose None (Delete Both)",
      },
      {
        "[x",
        "<cmd>GitConflictPrevConflict<cr>",
        desc = "Previous Conflict",
      },
      {
        "]x",
        "<cmd>GitConflictNextConflict<cr>",
        desc = "Next Conflict",
      },
      {
        "<leader>gcl",
        "<cmd>GitConflictListQf<cr>",
        desc = "List Conflicts in Quickfix",
      },
    },
  },
}
