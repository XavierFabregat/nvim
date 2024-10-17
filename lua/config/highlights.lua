-- ~/.config/nvim/lua/config/highlights.lua

local function set_transparent_background()
  local hl_groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
    "TabLineFill",
    "LineNr",
    "StatusLine",
    "StatusLineNC",
  }
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

-- Apply the highlights after the colorscheme is loaded
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_transparent_background,
})

-- Call the function initially to set the highlights
set_transparent_background()
