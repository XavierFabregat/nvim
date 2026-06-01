-- Spotify control from within Neovim
-- NOTE: Linux-only. Requires Python `pydbus` and `wmctrl` (for `show`).
return {
  {
    "stsewd/spotify.nvim",
    build = ":UpdateRemotePlugins",
    cmd = "Spotify",
    keys = {
      { "<leader>ss", "<cmd>Spotify play/pause<cr>", desc = "Spotify play/pause" },
      { "<leader>sj", "<cmd>Spotify next<cr>", desc = "Spotify next" },
      { "<leader>sk", "<cmd>Spotify prev<cr>", desc = "Spotify previous" },
      { "<leader>so", "<cmd>Spotify show<cr>", desc = "Spotify focus window" },
      { "<leader>sc", "<cmd>Spotify status<cr>", desc = "Spotify status" },
    },
    opts = {
      notification = {
        backend = "snacks",
      },
    },
    config = function(_, opts)
      require("spotify").setup(opts)
    end,
  },
}
