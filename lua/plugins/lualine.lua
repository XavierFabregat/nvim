-- Spotify now-playing in the statusline
return {
  "nvim-lualine/lualine.nvim",
  optional = true,
  opts = function(_, opts)
    if vim.fn.has("mac") ~= 1 then
      return
    end
    local sp = require("config.spotify")
    opts.sections = opts.sections or {}
    opts.sections.lualine_x = opts.sections.lualine_x or {}
    table.insert(opts.sections.lualine_x, 1, {
      function()
        return sp.statusline()
      end,
      cond = function()
        return sp.playing()
      end,
      color = { fg = "#1DB954" }, -- Spotify green
      on_click = function()
        sp.play_pause()
      end,
    })
  end,
}
