-- ─────────────────────────────────────────────────────────────────────────────
-- Code Runner - run any file right from Neovim
-- Works like VS Code's Code Runner extension
-- ─────────────────────────────────────────────────────────────────────────────

-- Map filetypes to their run commands.
-- %f = full file path, %d = file directory, %n = filename no extension
local runners = {
    -- Web
    javascript      = "node %f",
    typescript      = "npx ts-node %f",
    javascriptreact = "node %f",
    typescriptreact = "npx ts-node %f",

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
    cs              = "cd %d && dotnet run",

    -- Config / markup
    markdown        = "glow %f",
}

local function open_runner(cmd, title)
    -- Append a pause command to keep the terminal open after execution
    local paused_cmd = cmd .. "; echo 'Press Enter to close...'; read -r"
    require("Ktec.utils.terminal").open("right", {
        cmd = paused_cmd,
        title = "Runner: " .. title,
    })
end

-- Build the command string, substituting placeholders
local function build_cmd(template, filepath)
    local dir      = vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":h"))
    local noext    = vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":t:r"))
    local safe_file = vim.fn.shellescape(filepath)
    return template
        :gsub("%%f", safe_file)
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
            "No runner configured for filetype: " .. ft,
            vim.log.levels.WARN,
            { title = "Code Runner" }
        )
        return
    end

    local cmd = build_cmd(template, filepath)
    if args and args ~= "" then
        cmd = cmd .. " " .. args
    end

    open_runner(cmd, vim.fn.expand("%:t"))
end

-- Run visually selected lines
local function run_selection()
    vim.cmd("silent! write")
    local ft    = vim.bo.filetype
    local lines = vim.fn.getregion(
        vim.fn.getpos("'<"),
        vim.fn.getpos("'>"),
        { type = vim.fn.visualmode() }
    )

    local tmpfile = vim.fn.tempname() .. "." .. ft
    vim.fn.writefile(lines, tmpfile)

    local template = runners[ft]
    if not template then
        vim.notify("No runner for: " .. ft, vim.log.levels.WARN, { title = "Code Runner" })
        return
    end

    local cmd = build_cmd(template, tmpfile)
    open_runner(cmd, "selection")
end

-- Run with custom args
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
    -- Snacks terminals are buffers, we can just close the buffer or hide it
    -- For now, let's just close the current window if it's a terminal
    if vim.bo.filetype == "snacks_terminal" then
        vim.api.nvim_win_close(0, true)
    else
        vim.notify("Not in a runner terminal", vim.log.levels.INFO, { title = "Code Runner" })
    end
end, { desc = "Stop / close runner" })

return {}
