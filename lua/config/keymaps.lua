-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "\\", ":Explore<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { silent = true })
vim.keymap.set("n", "<leader>tt", ":term<CR>", { silent = true })

-- Accept copilot completion with <C-y>
vim.keymap.set("i", "<C-y>", "copilot#Accept('<CR>')", { silent = true, noremap = true, expr = true })
