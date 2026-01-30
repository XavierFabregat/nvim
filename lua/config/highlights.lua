-- ~/.config/nvim/lua/config/highlights.lua

local function set_transparent_background()
  local hl_groups = {
    -- Core UI
    "Normal",
    "NormalNC",
    "NormalFloat",
    "NormalSB",
    "SignColumn",
    "EndOfBuffer",
    "MsgArea",
    -- Line numbers
    "LineNr",
    "CursorLineNr",
    "LineNrAbove",
    "LineNrBelow",
    -- Status/Tab lines
    "StatusLine",
    "StatusLineNC",
    "TabLine",
    "TabLineFill",
    "TabLineSel",
    -- Splits and borders (removed - we want colored separators)
    -- "VertSplit",
    -- "WinSeparator",
    -- Floating windows
    "FloatBorder",
    "FloatTitle",
    -- Sidebar elements (Neo-tree)
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeEndOfBuffer",
    -- Snacks explorer/picker
    "SnacksNormal",
    "SnacksWinBar",
    "SnacksBackdrop",
    "SnacksNormalNC",
    "SnacksPicker",
    "SnacksPickerNormal",
    "SnacksPickerBorder",
    "SnacksPickerTitle",
    "SnacksPickerPrompt",
    "SnacksPickerPreview",
    "SnacksPickerList",
    "SnacksPickerInput",
    "SnacksPickerInputBorder",
    "SnacksPickerListNormal",
    "SnacksPickerPreviewNormal",
    "SnacksExplorer",
    "SnacksExplorerNormal",
    "SnacksDashboard",
    "SnacksDashboardNormal",
    "SnacksNotifierHistory",
    "SnacksScratch",
    -- Telescope
    "TelescopeNormal",
    "TelescopeBorder",
    "TelescopePromptNormal",
    "TelescopePromptBorder",
    "TelescopeResultsNormal",
    "TelescopeResultsBorder",
    "TelescopePreviewNormal",
    "TelescopePreviewBorder",
    -- Notifications
    "NotifyBackground",
    -- Completion menu
    "Pmenu",
    "PmenuSbar",
    "PmenuThumb",
    "CmpNormal",
    "CmpBorder",
    "CmpDocNormal",
    "CmpDocBorder",
    -- WhichKey
    "WhichKeyFloat",
    -- Lazy
    "LazyNormal",
    -- Mason
    "MasonNormal",
    "MasonHeader",
    -- Noice
    "NoiceCmdlinePopup",
    "NoiceCmdlinePopupBorder",
    "NoiceCmdlineIcon",
    "NoicePopup",
    "NoicePopupBorder",
    "NoiceConfirm",
    "NoiceConfirmBorder",
    -- Folding
    "Folded",
    "FoldColumn",
    -- Git signs column
    "GitSignsAdd",
    "GitSignsChange",
    "GitSignsDelete",
    -- Winbar
    "Winbar",
    "WinbarNC",
    -- Barbecue
    "barbecue_normal",
    "barbecue_ellipsis",
    "barbecue_separator",
    "barbecue_modified",
    "barbecue_dirname",
    "barbecue_basename",
    -- Dressing
    "DressingInput",
    "DressingSelect",
  }
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

-- Apply the highlights after the colorscheme is loaded
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    set_transparent_background()
    -- Ensure fillchars are not overridden by colorscheme
    vim.opt.fillchars = {
      horiz = "─",
      horizup = "┴",
      horizdown = "┬",
      vert = "│",
      vertleft = "┤",
      vertright = "├",
      verthoriz = "┼",
      eob = " ",
      diff = "╱",
      fold = " ",
      foldsep = "│",
      msgsep = "─",
    }
  end,
})

-- Call the function initially to set the highlights
set_transparent_background()

-- Pulsating purple window separators
local function setup_pulsating_separators()
  -- Define purple color shades for pulsation (from lighter to darker and back)
  local purple_shades = {
    "#d8b4fe", -- Lightest purple
    "#c084fc", -- Light purple
    "#a855f7", -- Medium purple
    "#9333ea", -- Purple
    "#7e22ce", -- Dark purple
    "#6b21a8", -- Darker purple
    "#7e22ce", -- Dark purple (going back)
    "#9333ea", -- Purple
    "#a855f7", -- Medium purple
    "#c084fc", -- Light purple
  }

  local current_shade = 1
  local timer = vim.uv.new_timer()

  -- Update separator color
  local function update_separator()
    vim.api.nvim_set_hl(0, "WinSeparator", {
      fg = purple_shades[current_shade],
      bg = "NONE",
      bold = true,
    })
    vim.api.nvim_set_hl(0, "VertSplit", {
      fg = purple_shades[current_shade],
      bg = "NONE",
      bold = true,
    })

    current_shade = current_shade + 1
    if current_shade > #purple_shades then
      current_shade = 1
    end

    -- Force redraw to show the updated colors
    vim.cmd("redraw")
  end

  -- Initial color
  update_separator()

  -- Start pulsating (update every 150ms for smooth animation)
  timer:start(150, 150, vim.schedule_wrap(update_separator))
end

-- Setup pulsating separators
setup_pulsating_separators()
