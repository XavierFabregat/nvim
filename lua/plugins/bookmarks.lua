-- Bookmark system for navigation
return {
  {
    "MattesGroeger/vim-bookmarks",
    event = "VeryLazy",
    init = function()
      -- Customize bookmark settings
      vim.g.bookmark_sign = "♥"
      vim.g.bookmark_annotation_sign = "☰"
      vim.g.bookmark_highlight_lines = 1
      vim.g.bookmark_auto_save = 1
      vim.g.bookmark_auto_close = 1
      vim.g.bookmark_manage_per_buffer = 0
      vim.g.bookmark_save_per_working_dir = 1
      vim.g.bookmark_center = 1
      vim.g.bookmark_location_list = 1
      vim.g.bookmark_disable_ctrlp = 1
      vim.g.bookmark_display_annotation = 1
      
      -- Custom bookmark directory
      vim.g.bookmark_auto_save_file = vim.fn.stdpath("data") .. "/bookmarks"
    end,
    keys = {
      { "<leader>mm", "<cmd>BookmarkToggle<cr>", desc = "Toggle bookmark" },
      { "<leader>mi", "<cmd>BookmarkAnnotate<cr>", desc = "Annotate bookmark" },
      { "<leader>ma", "<cmd>BookmarkShowAll<cr>", desc = "Show all bookmarks" },
      { "<leader>mn", "<cmd>BookmarkNext<cr>", desc = "Next bookmark" },
      { "<leader>mp", "<cmd>BookmarkPrev<cr>", desc = "Previous bookmark" },
      { "<leader>mc", "<cmd>BookmarkClear<cr>", desc = "Clear bookmarks in buffer" },
      { "<leader>mx", "<cmd>BookmarkClearAll<cr>", desc = "Clear all bookmarks" },
      { "<leader>ms", "<cmd>BookmarkSave<cr>", desc = "Save bookmarks" },
      { "<leader>ml", "<cmd>BookmarkLoad<cr>", desc = "Load bookmarks" },
    },
  },
  {
    "tom-anders/telescope-vim-bookmarks.nvim",
    dependencies = { "MattesGroeger/vim-bookmarks", "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("vim_bookmarks")
      
      -- Add telescope keymaps for better bookmark navigation
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope vim_bookmarks current_file<cr>", { desc = "Find bookmarks (current file)" })
      vim.keymap.set("n", "<leader>fB", "<cmd>Telescope vim_bookmarks all<cr>", { desc = "Find bookmarks (all files)" })
    end,
  },
}