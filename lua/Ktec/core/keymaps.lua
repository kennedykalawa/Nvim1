local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Source current file
vim.keymap.set("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Source current file" })

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Navigation
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Indent and stay in visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

local function toggle_word_wrap()
    local wrap = not vim.wo.wrap
    vim.wo.wrap = wrap
    vim.wo.linebreak = wrap
    vim.wo.breakindent = wrap
    vim.wo.breakindentopt = wrap and "shift:2,sbr" or ""
    vim.wo.showbreak = wrap and "> " or ""
    vim.wo.scrolloff = wrap and 0 or vim.o.scrolloff
    vim.wo.sidescrolloff = wrap and 0 or vim.o.sidescrolloff
end

vim.keymap.set("n", "<A-z>", toggle_word_wrap, { desc = "Toggle word wrap" })
vim.keymap.set("n", "<M-z>", toggle_word_wrap, { desc = "Toggle word wrap" })

-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
vim.keymap.set("v", "p", '"_dp', opts)

-- System clipboard yank
vim.keymap.set("n", "<leader>Y", [["+Y]], opts)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })

-- Delete without saving to register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without register" })

-- Escape aliases
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlight", silent = true })

-- Format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })

-- Disable Q
vim.keymap.set("n", "Q", "<nop>")

-- Tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Prevent x from yanking
vim.keymap.set("n", "x", '"_x', opts)

-- Global replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word under cursor" })

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- Tabs
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>",   { desc = "New tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>",     { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>",     { desc = "Prev tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Current buf in new tab" })

-- Splits
vim.keymap.set("n", "<leader>sv", "<C-w>v",          { desc = "Split vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s",          { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=",          { desc = "Equal split sizes" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>",  { desc = "Close split" })

-- Buffer navigation (quick, no plugin needed)
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>",     { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function() require("snacks").bufdelete() end, { desc = "Delete buffer" })

-- Copy filepath
vim.keymap.set("n", "<leader>fp", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    print("Copied: " .. path)
end, { desc = "Copy file path" })

-- Toggle LSP diagnostics
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
    isLspDiagnosticsVisible = not isLspDiagnosticsVisible
    vim.diagnostic.config({
        virtual_text = isLspDiagnosticsVisible,
        underline = isLspDiagnosticsVisible,
    })
end, { desc = "Toggle LSP diagnostics" })

-- LSP diagnostics float
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Quick save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

-- Standard Undo/Redo
vim.keymap.set({ "n", "i" }, "<C-z>", "<cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set({ "n", "i" }, "<C-y>", "<cmd>redo<CR>", { desc = "Redo" })

-- Resize splits with arrows
vim.keymap.set("n", "<C-Up>",    "<cmd>resize +2<CR>",          { desc = "Resize up" })
vim.keymap.set("n", "<C-Down>",  "<cmd>resize -2<CR>",          { desc = "Resize down" })
vim.keymap.set("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Resize left" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize right" })
