return {
  "wakatime/vim-wakatime",
  lazy = false, -- must load eagerly to track from the start
  init = function()
    -- Explicit path to wakatime-cli binary (adjust if installed elsewhere)
       vim.g.wakatime_CLIPath = vim.fn.expand("~/.pyenv/shims/wakatime")  
  end,
}
