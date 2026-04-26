-- ─────────────────────────────────────────────────────────────────────────────
-- Code Runner — run any file right from Neovim
-- Works like VS Code's Code Runner extension
--
-- Keymaps:
--   <leader>rc  → Run current file
--   <leader>rs  → Run selected lines (visual mode)
--   <leader>rx  → Stop / close runner terminal
--   <leader>rw  → Run with args (prompts you)
-- ─────────────────────────────────────────────────────────────────────────────

-- Map filetypes to their run commands.
-- %f = full file path, %d = file directory, %n = filename no extension
local runners = {
    -- Web
    javascript      = "node %f",
    typescript      = "npx ts-node %f",
    html            = "live-server %d --entry-file=%n.html",

    -- Python
    python          = "python3 %f",

    -- Systems
    c               = "cd %d && gcc %f -o %n && ./%n",
    cpp             = "cd %d && g++ %f -o %n && ./%n",
    rust            = "cd %d && cargo run",
    go              = "go run %f",
    java            = "cd %d && javac %f && java %n",

    -- Scripting
    bash            = "bash %f",
    sh              = "sh %f",
    zsh             = "zsh %f",
    lua             = "lua %f",
    ruby            = "ruby %f",
    php             = "php %f",
    perl            = "perl %f",

    -- Data / ML
    r               = "Rscript %f",
    julia           = "julia %f",

    -- .NET / VB.NET
    vb              = "cd %d && dotnet run",
    cs              = "cd %d && dotnet run",  -- C# too

    -- Config / markup (open in browser)
    markdown        = "glow %f",              -- needs: npm i -g glow OR brew install glow
}

-- Build the command string, substituting placeholders
local function build_cmd(template, filepath)
    local dir      = vim.fn.fnamemodify(filepath, ":h")
    local noext    = vim.fn.fnamemodify(filepath, ":t:r")
    return template
        :gsub("%%f", filepath)
        :gsub("%%d", dir)
        :gsub("%%n", noext)
end

-- Run the current file
local function run_file(args)
    -- Save first
    vim.cmd("silent! write")

    local ft       = vim.bo.filetype
    local filepath = vim.fn.expand("%:p")
    local template = runners[ft]

    if not template then
        vim.notify(
            "No runner configured for filetype: " .. ft .. "\nAdd it to coderunner.lua",
            vim.log.levels.WARN,
            { title = "Code Runner" }
        )
        return
    end

    -- Optionally append user-supplied args
    local cmd = build_cmd(template, filepath)
    if args and args ~= "" then
        cmd = cmd .. " " .. args
    end

    -- Run inside snacks floating terminal
    require("snacks").terminal(cmd, {
        win = {
            position = "float",
            border   = "rounded",
            height   = 0.6,
            width    = 0.75,
            title    = "  Running: " .. vim.fn.expand("%:t"),
            title_pos = "center",
        },
        -- Auto-close on success; keep open on error
        auto_close = false,
    })
end

-- Run visually selected lines by writing them to a temp file
local function run_selection()
    vim.cmd("silent! write")
    local ft    = vim.bo.filetype
    local lines = vim.fn.getregion(
        vim.fn.getpos("'<"),
        vim.fn.getpos("'>"),
        { type = vim.fn.visualmode() }
    )

    -- Write selection to a temp file
    local tmpfile = vim.fn.tempname() .. "." .. ft
    vim.fn.writefile(lines, tmpfile)

    local template = runners[ft]
    if not template then
        vim.notify("No runner for: " .. ft, vim.log.levels.WARN, { title = "Code Runner" })
        return
    end

    local cmd = build_cmd(template, tmpfile)
    require("snacks").terminal(cmd, {
        win = {
            position  = "float",
            border    = "rounded",
            height    = 0.5,
            width     = 0.7,
            title     = "  Running selection",
            title_pos = "center",
        },
        auto_close = false,
    })
end

-- Run with custom args (prompts via snacks input)
local function run_with_args()
    vim.ui.input({ prompt = "Run args: " }, function(input)
        if input ~= nil then
            run_file(input)
        end
    end)
end

-- ─── Register keymaps ────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>rc", run_file,      { desc = "Run file" })
vim.keymap.set("v", "<leader>rs", run_selection, { desc = "Run selection" })
vim.keymap.set("n", "<leader>rw", run_with_args, { desc = "Run file with args" })
vim.keymap.set("n", "<leader>rx", function()
    -- Close the snacks terminal if open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft  = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "snacks_terminal" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end
    vim.notify("No runner terminal open", vim.log.levels.INFO, { title = "Code Runner" })
end, { desc = "Stop / close runner" })

-- ─── Also add live-server for HTML specifically ───────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function(ev)
        vim.keymap.set("n", "<leader>ls", function()
            local dir = vim.fn.expand("%:p:h")
            require("snacks").terminal("live-server " .. dir, {
                win = {
                    position  = "float",
                    border    = "rounded",
                    height    = 0.4,
                    width     = 0.6,
                    title     = "  Live Server",
                    title_pos = "center",
                },
                auto_close = false,
            })
        end, { buffer = ev.buf, desc = "HTML: start live-server" })

        vim.keymap.set("n", "<leader>lS", function()
            vim.fn.jobstart("pkill -f live-server")
            vim.notify("Live server stopped", vim.log.levels.INFO, { title = "Live Server" })
        end, { buffer = ev.buf, desc = "HTML: stop live-server" })
    end,
})

-- This file is sourced directly by core/init.lua — no plugin table needed
return {}
