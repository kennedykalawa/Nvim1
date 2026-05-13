-- Floating terminal using Snacks (replaces any custom terminal setup)
-- Snacks.terminal handles this beautifully — see snacks.lua for config.
-- This file just sets up the global toggle keymaps.

vim.keymap.set({ "n", "t" }, "<C-\\>", function()
    require("snacks").terminal.toggle()
end, { desc = "Toggle floating terminal" })

vim.keymap.set({ "n", "t" }, "<leader>tt", function()
    require("snacks").terminal.toggle()
end, { desc = "Toggle floating terminal" })

-- Open a terminal in a bottom split (like VS Code's integrated terminal)
vim.keymap.set("n", "<leader>ts", function()
    vim.cmd("botright split | resize 15 | terminal")
    vim.cmd("startinsert")
end, { desc = "Open terminal split (bottom)" })

-- Terminal escape back to normal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: normal mode" })
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal: move left" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal: move down" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal: move up" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal: move right" })
