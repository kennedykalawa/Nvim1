return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-plenary",
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
        require("neotest-python")(),
        require("neotest-jest")(),
      },
      discovery = { enabled = true, concurrent = 1 },
      running = { concurrent = true },
      summary = { open = "botright vsplit | vertical resize 50" },
      output = { open = "botright split | resize 15" },
    })
  end,
  keys = {
    { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
    { "<leader>Ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
    { "<leader>Tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
    { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
    { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },
    { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle test watch" },
  },
}
