-- Explicit float for lazygit: call-site win opts outrank the global terminal
-- config (position = "bottom"), which is why the style alone wasn't enough.
local lazygit_float = {
  win = {
    position = "float",
    width = 0.9,
    height = 0.9,
    border = "rounded",
    backdrop = 60,
  },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Enhanced quality of life features
    bigfile = { 
      enabled = true,
      notify = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
    },
    dashboard = { 
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { 
      enabled = true,
      replace_netrw = true,
    },
    indent = { 
      enabled = true,
      animate = {
        enabled = true,
        easing = "linear",
        duration = {
          step = 20,
          total = 500,
        },
      },
    },
    input = { 
      enabled = true,
      icon = " ",
    },
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<C-j>"] = { "move_down", mode = { "i", "n" } },
            ["<C-k>"] = { "move_up", mode = { "i", "n" } },
          },
        },
      },
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
    notifier = { 
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { 
      enabled = true,
      animate = {
        duration = { step = 15, total = 250 },
        easing = "linear",
      },
    },
    statuscolumn = { 
      enabled = true,
      left = { "mark", "sign" },
      right = { "fold", "git" },
      folds = {
        open = true,
        git_hl = false,
      },
      git = {
        patterns = { "GitSign", "MiniDiffSign" },
      },
    },
    words = { 
      enabled = true,
      debounce = 200,
      notify_jump = false,
      notify_end = true,
      foldopen = true,
      jumplist = true,
      modes = { "n", "i", "c" },
    },
    zen = {
      enabled = true,
      -- Auto-play the focus playlist (if M.config.focus_playlist is set) on Zen.
      on_open = function()
        pcall(function()
          require("config.spotify").focus_enter()
        end)
      end,
      on_close = function()
        pcall(function()
          require("config.spotify").focus_leave()
        end)
      end,
    },
    terminal = { 
      enabled = true,
      win = {
        position = "bottom",
        height = 0.4,
      },
    },
    toggle = { enabled = true },
    dim = { enabled = true },
  },
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gg", function() Snacks.lazygit(lazygit_float) end, desc = "Lazygit (cwd)", mode = "n" },
    { "<leader>gf", function() Snacks.lazygit.log_file(lazygit_float) end, desc = "Lazygit Current File History" },
    { "<leader>gl", function() Snacks.lazygit.log(lazygit_float) end, desc = "Lazygit Log (cwd)" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<c-_>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
}
