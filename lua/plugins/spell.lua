-- Native spell checking with smart auto-enable for text files
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure we have the parsers needed for spell checking
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "comment",
        "markdown",
        "markdown_inline",
      })
    end,
  },
  -- Auto-enable spell checking for text-based files
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Enable spell checking for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit", "NeogitCommitMessage" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
        end,
      })

      -- Spell check keybindings
      vim.keymap.set("n", "<leader>us", function()
        vim.opt.spell = not vim.opt.spell:get()
        if vim.opt.spell:get() then
          vim.notify("Spell check enabled", vim.log.levels.INFO)
        else
          vim.notify("Spell check disabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Spell Check" })
    end,
  },
}