-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Transparency settings
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })

-- Quality of life improvements
local opt = vim.opt

-- Enhanced scrolling
opt.scrolloff = 8           -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8       -- Keep 8 columns left/right of cursor
opt.smoothscroll = true     -- Smooth scrolling

-- Better search experience
opt.ignorecase = true       -- Ignore case in search
opt.smartcase = true        -- Unless uppercase is used
opt.incsearch = true        -- Incremental search
opt.hlsearch = true         -- Highlight search results

-- Enhanced editing
opt.undofile = true         -- Persistent undo
opt.undolevels = 10000      -- More undo levels
opt.updatetime = 200        -- Faster completion (default 4000ms)
opt.timeoutlen = 300        -- Faster key timeout
opt.autowrite = true        -- Auto write when switching buffers
opt.confirm = true          -- Confirm before discarding changes

-- Better formatting
opt.wrap = false            -- No line wrapping by default
opt.linebreak = true        -- Wrap at word boundaries
opt.breakindent = true      -- Maintain indent when wrapping
opt.showbreak = "↳ "        -- Character to show for wrapped lines

-- Enhanced visual experience
opt.cursorline = true       -- Highlight current line
opt.colorcolumn = "100"     -- Show column at 100 characters
opt.signcolumn = "yes"      -- Always show sign column
opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Show relative line numbers
opt.list = true             -- Show invisible characters
opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "…",
  precedes = "…",
  nbsp = "␣"
}

-- Better splits
opt.splitbelow = true       -- Open horizontal splits below
opt.splitright = true       -- Open vertical splits to the right
opt.splitkeep = "screen"    -- Keep text on screen when splitting

-- Enhanced completion
opt.completeopt = "menu,menuone,noselect,preview"
opt.pumheight = 15          -- Limit popup menu height

-- Better performance
opt.lazyredraw = false      -- Don't redraw during macros (disabled for better experience)
opt.ttyfast = true          -- Faster terminal connection
opt.synmaxcol = 300         -- Don't syntax highlight long lines

-- File handling
opt.backup = false          -- No backup files
opt.writebackup = false     -- No backup before writing
opt.swapfile = false        -- No swap files
opt.autoread = true         -- Auto-reload files changed outside vim

-- Mouse support
opt.mouse = "a"             -- Enable mouse in all modes
opt.mousemodel = "popup"    -- Right click opens popup menu

-- Folding
opt.foldmethod = "expr"     -- Use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99          -- Start with all folds open
opt.foldlevelstart = 99     -- Start with all folds open
opt.foldenable = true       -- Enable folding

-- Session management
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Enhanced clipboard (if available)
if vim.fn.has("clipboard") == 1 then
  opt.clipboard = "unnamedplus"
end

-- Auto-commands for quality of life
local augroup = vim.api.nvim_create_augroup("QualityOfLife", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  pattern = "*",
  command = "wincmd =",
})

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup,
  command = "checktime",
})
