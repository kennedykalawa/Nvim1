-- ─────────────────────────────────────────────────────────────────────────────
-- Gemini quick shortcuts (floating terminal)
-- For the proper sidebar use <leader>cc (codecompanion)
--
-- Keymaps:
--   <leader>aI  → Open Gemini CLI in a sidebar split
--   <leader>ag  → Quick question (float)
--   <leader>aG  → Review current file (float)
--   <leader>as  → Review visual selection (float)
--   <leader>ae  → Explain error under cursor (float)
-- ─────────────────────────────────────────────────────────────────────────────

-- Gemini CLI sidebar split
vim.keymap.set("n", "<leader>aI", function()
    vim.cmd("botright vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.4))
    vim.cmd("terminal gemini")
    vim.cmd("startinsert")
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn     = "no"
end, { desc = "Gemini: CLI sidebar" })

-- Quick one-off question
vim.keymap.set("n", "<leader>ag", function()
    vim.ui.input({ prompt = " Gemini: " }, function(input)
        if not input or input == "" then return end
        require("snacks").terminal("gemini chat '" .. input:gsub("'", "'\\''") .. "'", {
            win = {
                position  = "float",
                border    = "rounded",
                height    = 0.65,
                width     = 0.75,
                title     = "  Gemini",
                title_pos = "center",
            },
            auto_close = false,
        })
    end)
end, { desc = "Gemini: quick question" })

-- Review current file
vim.keymap.set("n", "<leader>aG", function()
    vim.cmd("silent! write")
    local filepath = vim.fn.expand("%:p")
    local ft       = vim.bo.filetype
    require("snacks").terminal(
        "gemini chat 'Review this " .. ft .. " code for bugs and improvements:' < " .. filepath, {
        win = {
            position  = "float",
            border    = "rounded",
            height    = 0.8,
            width     = 0.85,
            title     = "  Gemini Review: " .. vim.fn.expand("%:t"),
            title_pos = "center",
        },
        auto_close = false,
    })
end, { desc = "Gemini: review file" })

-- Review visual selection
vim.keymap.set("v", "<leader>as", function()
    local lines   = vim.fn.getregion(
        vim.fn.getpos("'<"),
        vim.fn.getpos("'>"),
        { type = vim.fn.visualmode() }
    )
    local tmpfile = vim.fn.tempname() .. "." .. vim.bo.filetype
    vim.fn.writefile(lines, tmpfile)
    require("snacks").terminal(
        "gemini chat 'Explain and review this code:' < " .. tmpfile, {
        win = {
            position  = "float",
            border    = "rounded",
            height    = 0.65,
            width     = 0.78,
            title     = "  Gemini: Selection",
            title_pos = "center",
        },
        auto_close = false,
    })
end, { desc = "Gemini: review selection" })

-- Explain error under cursor
vim.keymap.set("n", "<leader>ae", function()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    local msg   = #diags > 0 and diags[1].message or vim.api.nvim_get_current_line()
    require("snacks").terminal(
        "gemini chat 'Explain this error and how to fix it: " .. msg:gsub("'", "'\\''") .. "'", {
        win = {
            position  = "float",
            border    = "rounded",
            height    = 0.6,
            width     = 0.75,
            title     = "  Gemini: Error Help",
            title_pos = "center",
        },
        auto_close = false,
    })
end, { desc = "Gemini: explain error" })

return {}
