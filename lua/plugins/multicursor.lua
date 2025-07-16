-- Multi-cursor editing support
return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_theme = "iceblue"
      vim.g.VM_default_mappings = 0
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
        ["Select Cursor Down"] = "<M-C-Down>",
        ["Select Cursor Up"] = "<M-C-Up>",
        ["Select l"] = "<S-Right>",
        ["Select h"] = "<S-Left>",
        ["Switch Mode"] = "<Tab>",
        ["Find Next"] = "]",
        ["Find Prev"] = "[",
        ["Goto Next"] = "}",
        ["Goto Prev"] = "{",
        ["Seek Next"] = "<C-f>",
        ["Seek Prev"] = "<C-b>",
        ["Skip Region"] = "<C-x>",
        ["Remove Region"] = "<C-p>",
        ["Invert Direction"] = "o",
        ["Increase"] = "+",
        ["Decrease"] = "-",
        ["Add Cursor Down"] = "<M-C-j>",
        ["Add Cursor Up"] = "<M-C-k>",
        ["Add Cursor At Pos"] = "m",
        ["Add Cursor At Word"] = "mw",
        ["Reselect Last"] = "gS",
        ["Visual Regex"] = "R",
        ["Visual All"] = "A",
        ["Visual Add"] = "a",
        ["Visual Find"] = "f",
        ["Visual Cursors"] = "c",
        ["Erase Regions"] = "dr",
        ["Transform Regions"] = "tr",
        ["Surround"] = "S",
        ["Replace Pattern"] = "R",
      }
      vim.g.VM_leader = "\\"
      vim.g.VM_custom_motions = {
        ["l"] = "h",
        ["h"] = "l",
      }
      vim.g.VM_set_statusline = 0
    end,
    keys = {
      { "<C-d>", mode = { "n", "x" }, desc = "Multi-cursor: Add cursor on word" },
      { "<M-C-j>", mode = { "n", "x" }, desc = "Multi-cursor: Add cursor down" },
      { "<M-C-k>", mode = { "n", "x" }, desc = "Multi-cursor: Add cursor up" },
      { "<C-x>", mode = { "n", "x" }, desc = "Multi-cursor: Skip region" },
      { "<C-p>", mode = { "n", "x" }, desc = "Multi-cursor: Remove region" },
      { "\\A", mode = { "n", "x" }, desc = "Multi-cursor: Select all" },
      { "\\a", mode = { "n", "x" }, desc = "Multi-cursor: Add selection" },
      { "\\f", mode = { "n", "x" }, desc = "Multi-cursor: Find selection" },
      { "\\c", mode = { "n", "x" }, desc = "Multi-cursor: Create cursors" },
      { "gS", mode = { "n", "x" }, desc = "Multi-cursor: Reselect last" },
    },
  },
}