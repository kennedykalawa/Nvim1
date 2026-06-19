-- CLI AI integration.
-- Uses the same authenticated terminal tools you already use outside Neovim.

local providers = {
    codex = {
        label = "Codex",
        command = "codex",
        interactive = function(cwd)
            return { "codex", "--cd", cwd }
        end,
        prompt = function(cwd, prompt)
            return { "codex", "--cd", cwd, prompt }
        end,
        stdin = function(cwd, prompt_file)
            return "codex exec --cd "
                .. vim.fn.shellescape(cwd)
                .. " - < "
                .. vim.fn.shellescape(prompt_file)
        end,
        resume = function(cwd)
            return { "codex", "--cd", cwd, "resume", "--last" }
        end,
    },
    gemini = {
        label = "Gemini",
        command = "gemini",
        interactive = function()
            return { "gemini" }
        end,
        prompt = function(_, prompt)
            return { "gemini", "--prompt-interactive", prompt }
        end,
        stdin = function(_, prompt_file)
            return "gemini --prompt "
                .. vim.fn.shellescape("")
                .. " < "
                .. vim.fn.shellescape(prompt_file)
        end,
        resume = function()
            return { "gemini", "--resume", "latest" }
        end,
    },
    copilot = {
        label = "Copilot",
        command = "copilot",
        interactive = function(cwd)
            return { "copilot", "-C", cwd }
        end,
        prompt = function(cwd, prompt)
            return { "copilot", "-C", cwd, "--interactive", prompt }
        end,
        stdin = function(cwd, prompt_file)
            return "copilot -C "
                .. vim.fn.shellescape(cwd)
                .. " --prompt \"$(cat "
                .. vim.fn.shellescape(prompt_file)
                .. ")\""
        end,
        resume = function(cwd)
            return { "copilot", "-C", cwd, "--continue" }
        end,
    },
    claude = {
        label = "Claude",
        command = "claude",
        interactive = function(cwd)
            return { "claude", "--add-dir", cwd }
        end,
        prompt = function(cwd, prompt)
            return { "claude", "--add-dir", cwd, prompt }
        end,
        stdin = function(cwd, prompt_file)
            return "claude --add-dir "
                .. vim.fn.shellescape(cwd)
                .. " --print < "
                .. vim.fn.shellescape(prompt_file)
        end,
        resume = function()
            return { "claude", "--continue" }
        end,
    },
    ollama = {
        label = "Ollama",
        command = "ollama",
        interactive = function()
            return { "ollama", "launch" }
        end,
        prompt = function(_, prompt)
            return { "ollama", "launch" }
        end,
        stdin = function(_, prompt_file)
            return "ollama launch< " .. vim.fn.shellescape(prompt_file)
        end,
    },
}
local order = { "codex", "gemini", "copilot", "claude", "ollama" }
local default_provider = "codex"

local function cwd()
    return vim.fn.getcwd()
end

local function command_to_string(command)
    if type(command) == "string" then
        return command
    end

    return table.concat(vim.tbl_map(vim.fn.shellescape, command), " ")
end

local function available(provider)
    if vim.fn.executable(provider.command) == 1 then
        return true
    end

    vim.notify(provider.command .. " is not installed or not in PATH", vim.log.levels.WARN, {
        title = "AI CLI",
    })
    return false
end

local function terminal(command, title, opts)
    require("snacks").terminal(command_to_string(command), {
        win = {
            position = opts and opts.position or "right",
            border = "rounded",
            height = opts and opts.height or 0,
            width = opts and opts.width or 0.4,
            title = "  " .. title,
            title_pos = "center",
        },
        auto_close = false,
    })
end

local function with_provider(callback)
    local choices = {}
    for _, key in ipairs(order) do
        local provider = providers[key]
        table.insert(choices, provider.label)
    end

    vim.ui.select(choices, { prompt = "AI CLI:" }, function(label)
        if not label then
            return
        end

        for key, provider in pairs(providers) do
            if provider.label == label and available(provider) then
                callback(key, provider)
                return
            end
        end
    end)
end

local function open_provider(key)
    local provider = providers[key]
    if provider and available(provider) then
        terminal(provider.interactive(cwd()), provider.label)
    end
end

local function prompt_provider(key)
    local provider = providers[key]
    if not provider or not available(provider) then
        return
    end

    vim.ui.input({ prompt = provider.label .. ": " }, function(input)
        if not input or input == "" then
            return
        end

        terminal(provider.prompt(cwd(), input), provider.label)
    end)
end

local function write_prompt_file(instruction, body)
    local file = vim.fn.tempname() .. ".md"
    vim.fn.writefile({
        instruction,
        "",
        "Current file: " .. vim.fn.expand("%:p"),
        "Filetype: " .. vim.bo.filetype,
        "",
        "```" .. vim.bo.filetype,
    }, file)
    vim.fn.writefile(body, file, "a")
    vim.fn.writefile({ "```" }, file, "a")
    return file
end

local function current_buffer_lines()
    vim.cmd("silent! write")
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function visual_lines()
    return vim.fn.getregion(
        vim.fn.getpos("'<"),
        vim.fn.getpos("'>"),
        { type = vim.fn.visualmode() }
    )
end

local function run_with_context(instruction, body, title)
    with_provider(function(_, provider)
        local prompt_file = write_prompt_file(instruction, body)
        terminal(provider.stdin(cwd(), prompt_file), title .. " - " .. provider.label)
    end)
end

local function explain_diagnostic()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    local message = #diagnostics > 0 and diagnostics[1].message or vim.api.nvim_get_current_line()
    run_with_context("Explain this error and give a practical fix:\n\n" .. message, current_buffer_lines(), "Explain Error")
end

vim.api.nvim_create_user_command("Ai", function()
    with_provider(function(key)
        open_provider(key)
    end)
end, {})

vim.api.nvim_create_user_command("AiAsk", function()
    with_provider(function(key)
        prompt_provider(key)
    end)
end, {})

vim.api.nvim_create_user_command("AiReview", function()
    run_with_context("Review this file for bugs, edge cases, and concrete improvements.", current_buffer_lines(), "Review File")
end, {})

vim.api.nvim_create_user_command("AiExplainError", explain_diagnostic, {})

vim.keymap.set("n", "<leader>aa", "<cmd>Ai<CR>", { desc = "AI: choose CLI" })
vim.keymap.set("n", "<leader>ac", function() open_provider("codex") end, { desc = "AI: Codex CLI" })
vim.keymap.set("n", "<leader>ag", function() open_provider("gemini") end, { desc = "AI: Gemini CLI" })
vim.keymap.set("n", "<leader>ap", function() open_provider("copilot") end, { desc = "AI: Copilot CLI" })
vim.keymap.set("n", "<leader>al", function() open_provider("claude") end, { desc = "AI: Claude CLI" })
vim.keymap.set("n", "<leader>ao", function() open_provider("ollama") end, { desc = "AI: Ollama CLI" })
vim.keymap.set("n", "<leader>aA", "<cmd>AiAsk<CR>", { desc = "AI: ask chosen CLI" })
vim.keymap.set("n", "<leader>aR", "<cmd>AiReview<CR>", { desc = "AI: review file" })
vim.keymap.set("n", "<leader>ae", "<cmd>AiExplainError<CR>", { desc = "AI: explain error" })
vim.keymap.set("v", "<leader>as", function()
    run_with_context("Explain and review this selected code.", visual_lines(), "Review Selection")
end, { desc = "AI: review selection" })
vim.keymap.set("n", "<leader>ar", function()
    local provider = providers[default_provider]
    if provider and provider.resume and available(provider) then
        terminal(provider.resume(cwd()), provider.label .. " Resume")
    end
end, { desc = "AI: resume Codex" })

return {}
