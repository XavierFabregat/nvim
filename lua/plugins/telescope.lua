return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Disable LazyVim's default <leader>gc keybinding (git commits)
    { "<leader>gc", false },
  },
  opts = {
    defaults = {
      -- Make floating windows respect transparency
      winblend = 0,
      -- Ensure proper highlighting for transparent backgrounds
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  },
}
