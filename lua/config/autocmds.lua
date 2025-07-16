-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-save functionality
local function auto_save()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.bo[buf].readonly == false then
    vim.cmd("silent! write")
  end
end

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
  callback = auto_save,
  desc = "Auto-save on focus lost and buffer leave",
})

-- Auto-save on idle (after updatetime)
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("AutoSaveIdle", { clear = true }),
  callback = auto_save,
  desc = "Auto-save on idle",
})
