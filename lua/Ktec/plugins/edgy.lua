return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    left = {
      { ft = "oil", title = "Oil", size = { width = 30 } },
      { ft = "Trouble", title = "Trouble", size = { width = 30 } },
    },
    right = {
      { ft = "dapui_watches", title = "Debug", size = { width = 30 } },
      { ft = "dapui_stacks", title = "Debug Stacks", size = { width = 30 } },
      { ft = "dapui_scopes", title = "Debug Scopes", size = { width = 30 } },
      { ft = "dapui_breakpoints", title = "Debug Breakpoints", size = { width = 30 } },
      { ft = "dap-repl", title = "Debug REPL", size = { width = 30 } },
      { ft = "lazygit", title = "LazyGit", size = { width = 40 } },
    },
    bottom = {
      { ft = "qf", title = "QuickFix", size = { height = 10 } },
      { ft = "help", title = "Help", size = { height = 20 } },
    },
  },
}
