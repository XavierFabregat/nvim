-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- File explorer
vim.keymap.set("n", "\\", ":Explore<CR>", { silent = true, desc = "Open netrw" })
vim.keymap.set("n", "<leader>e", function() require("snacks").explorer.open() end, { silent = true, desc = "Open Explorer" })

-- Terminal
vim.keymap.set("n", "<leader>tt", ":term<CR>", { silent = true, desc = "Open terminal" })

-- Copilot
vim.keymap.set("i", "<C-y>", "copilot#Accept('<CR>')", { silent = true, noremap = true, expr = true, desc = "Accept copilot" })

-- Quality of life keymaps
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better search
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better paste
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking replaced text" })

-- Quick save and quit
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Buffer management
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to other buffer" })

-- Quick fix and location list
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[l", "<cmd>lprev<CR>", { desc = "Previous location" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>", { desc = "Next location" })

-- Better join
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

-- Center screen on various movements
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Duplicate lines
vim.keymap.set("n", "<leader>d", ":t.<CR>", { desc = "Duplicate line" })
vim.keymap.set("v", "<leader>d", ":'<,'>t'><CR>gv", { desc = "Duplicate selection" })

-- Toggle word wrap
vim.keymap.set("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle word wrap" })

-- Toggle relative line numbers
vim.keymap.set("n", "<leader>ur", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative numbers" })

-- Clear registers
vim.keymap.set("n", "<leader>uR", function()
  for i = 0, 9 do vim.fn.setreg(tostring(i), "") end
  for i = 65, 90 do vim.fn.setreg(string.char(i), "") end
  vim.notify("Cleared all registers", vim.log.levels.INFO)
end, { desc = "Clear all registers" })

-- Format file
vim.keymap.set("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format document" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
