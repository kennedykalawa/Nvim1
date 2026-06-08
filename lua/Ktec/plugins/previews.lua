local preview_state = {
    dev_task = nil,
    live_task = nil,
    backend_task = nil,
}

local function has_command(command, title)
    if vim.fn.executable(command) == 1 then
        return true
    end

    vim.notify(command .. " is not installed or not in PATH", vim.log.levels.WARN, { title = title or "Preview" })
    return false
end

local function normalize_url(input)
    if not input or input == "" then
        return nil
    end

    if tonumber(input) then
        return "http://localhost:" .. input
    end

    if input:match("^https?://") then
        return input
    end

    return "http://" .. input
end

local function open_url(url)
    url = normalize_url(url)
    if not url then
        return
    end

    vim.g.ktec_preview_url = url

    if not has_command("xdg-open", "Preview") then
        vim.notify("Preview URL: " .. url, vim.log.levels.INFO, { title = "Preview" })
        return
    end

    local job = vim.fn.jobstart({ "xdg-open", url }, { detach = true })
    if job <= 0 then
        vim.notify("Could not open preview URL: " .. url, vim.log.levels.ERROR, { title = "Preview" })
        return
    end

    vim.notify("Opening preview: " .. url, vim.log.levels.INFO, { title = "Preview" })
end

local function prompt_url(default)
    vim.ui.input({
        prompt = "Preview URL/Port: ",
        default = vim.g.ktec_preview_url or default or "http://localhost:5173",
    }, function(input)
        open_url(input)
    end)
end

local function shell_task(name, command)
    local overseer = require("overseer")
    local task = overseer.new_task({
        name = name,
        cmd = vim.o.shell,
        args = { vim.o.shellcmdflag, command },
        components = { "default" },
    })

    task:start()
    vim.cmd("OverseerToggle")
    return task
end

local function package_json(root)
    root = root or vim.fn.getcwd()
    local path = vim.fs.normalize(root .. "/package.json")
    if vim.fn.filereadable(path) ~= 1 then
        return nil
    end

    return table.concat(vim.fn.readfile(path), "\n")
end

local function file_contains(path, pattern)
    if vim.fn.filereadable(path) ~= 1 then
        return false
    end

    return table.concat(vim.fn.readfile(path), "\n"):find(pattern) ~= nil
end

local function first_existing(files)
    for _, file in ipairs(files) do
        if vim.fn.filereadable(file) == 1 then
            return file
        end
    end

    return nil
end

local function python_module(path, root)
    if root and path:sub(1, #root + 1) == root .. "/" then
        path = path:sub(#root + 2)
    end

    return path:gsub("%.py$", ""):gsub("/", ".")
end

local function project_root(markers)
    local start = vim.fn.expand("%:p:h")
    if start == "" then
        start = vim.fn.getcwd()
    end

    local path = vim.fs.normalize(start)

    while path and path ~= "" do
        for _, marker in ipairs(markers) do
            local candidate = path .. "/" .. marker
            if vim.fn.filereadable(candidate) == 1 or vim.fn.isdirectory(candidate) == 1 then
                return path
            end
        end

        local parent = vim.fs.dirname(path)
        if parent == path then
            break
        end
        path = parent
    end

    return vim.fs.normalize(vim.fn.getcwd())
end

local function dev_command(port, root)
    local content = package_json(root)
    if not content then
        return nil
    end

    if content:find('"next"', 1, true) then
        return "npm run dev -- -p " .. port
    end

    if content:find('"react%-scripts"', 1, false) then
        return "PORT=" .. port .. " npm start"
    end

    if content:find('"dev"%s*:') then
        return "npm run dev -- --port " .. port
    end

    if content:find('"start"%s*:') then
        return "PORT=" .. port .. " npm start"
    end

    return nil
end

local function start_dev_server(port)
    port = tostring(port or "5173")

    if not has_command("npm", "Dev Server") then
        return
    end

    local command = dev_command(port)
    if not command then
        vim.notify("No package.json dev/start script found. Opening Overseer picker.", vim.log.levels.WARN, {
            title = "Dev Server",
        })
        vim.cmd("OverseerRun")
        return
    end

    if preview_state.dev_task then
        pcall(function()
            preview_state.dev_task:stop()
        end)
    end

    preview_state.dev_task = shell_task("Dev Server :" .. port, command)
    vim.g.ktec_preview_url = "http://localhost:" .. port
    vim.notify("Starting dev server on port " .. port, vim.log.levels.INFO, { title = "Dev Server" })
end

local function start_dev_server_prompt()
    vim.ui.input({ prompt = "Dev server port: ", default = "5173" }, function(port)
        if port and port ~= "" then
            start_dev_server(port)
        end
    end)
end

local function backend_command(port)
    port = tostring(port or "8000")
    local root = project_root({ "manage.py", "go.mod", "Cargo.toml", "package.json", "pyproject.toml", "requirements.txt", "artisan" })

    if vim.fn.filereadable(root .. "/manage.py") == 1 then
        return {
            command = "python3 manage.py runserver 0.0.0.0:" .. port,
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "python3",
            name = "Django :" .. port,
        }
    end

    local python_app = first_existing({ root .. "/main.py", root .. "/app.py", root .. "/src/main.py", root .. "/src/app.py" })
    if python_app and file_contains(python_app, "FastAPI%(") then
        return {
            command = "uvicorn " .. python_module(python_app, root) .. ":app --reload --host 0.0.0.0 --port " .. port,
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "uvicorn",
            name = "FastAPI :" .. port,
        }
    end

    if python_app and file_contains(python_app, "Flask%(") then
        return {
            command = "flask --app " .. python_module(python_app, root) .. " run --debug --host 0.0.0.0 --port " .. port,
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "flask",
            name = "Flask :" .. port,
        }
    end

    if vim.fn.filereadable(root .. "/go.mod") == 1 then
        return {
            command = "cd " .. vim.fn.shellescape(root) .. " && go run .",
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "go",
            name = "Go backend",
        }
    end

    if vim.fn.filereadable(root .. "/Cargo.toml") == 1 then
        return {
            command = "cd " .. vim.fn.shellescape(root) .. " && cargo run",
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "cargo",
            name = "Rust backend",
        }
    end

    if vim.fn.glob(root .. "/*.csproj") ~= "" or vim.fn.glob(root .. "/*.sln") ~= "" then
        return {
            command = "cd " .. vim.fn.shellescape(root) .. " && dotnet run",
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "dotnet",
            name = ".NET backend",
        }
    end

    if vim.fn.filereadable(root .. "/artisan") == 1 then
        return {
            command = "cd " .. vim.fn.shellescape(root) .. " && php artisan serve --host=0.0.0.0 --port=" .. port,
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "php",
            name = "Laravel :" .. port,
        }
    end

    local node_command = dev_command(port, root)
    if node_command then
        return {
            command = node_command,
            cwd = root,
            url = "http://localhost:" .. port,
            tool = "npm",
            name = "Node backend :" .. port,
        }
    end

    return nil
end

local function start_backend_server(port)
    local backend = backend_command(port or "8000")
    if not backend then
        vim.notify("No backend project type detected. Opening Overseer picker.", vim.log.levels.WARN, {
            title = "Backend",
        })
        vim.cmd("OverseerRun")
        return
    end

    if not has_command(backend.tool, "Backend") then
        return
    end

    require("Ktec.utils.terminal").open("right", {
        cmd = backend.command,
        cwd = backend.cwd,
        title = backend.name,
        width = math.max(40, math.floor(vim.o.columns * 0.45)),
        auto_close = false,
    })
    vim.g.ktec_preview_url = backend.url
    vim.notify("Starting " .. backend.name, vim.log.levels.INFO, { title = "Backend" })
end

local function start_backend_prompt()
    vim.ui.input({ prompt = "Backend port: ", default = "8000" }, function(port)
        if port and port ~= "" then
            start_backend_server(port)
        end
    end)
end

local function start_live_server(port)
    port = tostring(port or "5500")

    if not has_command("live-server", "Live Server") then
        return
    end

    local dir = vim.fn.expand("%:p:h")
    if dir == "" then
        dir = vim.fn.getcwd()
    end

    if preview_state.live_task then
        pcall(function()
            preview_state.live_task:stop()
        end)
    end

    local command = "live-server "
        .. vim.fn.shellescape(dir)
        .. " --host=127.0.0.1 --port="
        .. vim.fn.shellescape(port)

    preview_state.live_task = shell_task("Live Server :" .. port, command)
    vim.g.ktec_preview_url = "http://127.0.0.1:" .. port
    vim.notify("Starting live-server for " .. dir, vim.log.levels.INFO, { title = "Live Server" })
end

local function preview_static()
    vim.cmd("silent! write")

    local ok = pcall(vim.cmd, "LivePreview start")
    if ok then
        vim.g.ktec_preview_url = "http://127.0.0.1:5500"
        return
    end

    start_live_server("5500")
end

local function close_preview()
    pcall(vim.cmd, "LivePreview close")

    if preview_state.live_task then
        pcall(function()
            preview_state.live_task:stop()
        end)
        preview_state.live_task = nil
    end

    vim.notify("Preview closed", vim.log.levels.INFO, { title = "Preview" })
end

local function open_terminal_url(default)
    vim.ui.input({ prompt = "Terminal preview URL: ", default = vim.g.ktec_preview_url or default }, function(url)
        url = normalize_url(url)
        if not url then
            return
        end

        if not has_command("browsh", "Preview") then
            return
        end

        vim.g.ktec_preview_url = url
        require("Ktec.utils.terminal").open("right", {
            cmd = "browsh " .. vim.fn.shellescape(url),
            title = "Browser Preview",
            width = math.max(32, math.floor(vim.o.columns * 0.45)),
            auto_close = false,
        })
    end)
end

local function setup_autosave()
    vim.g.ktec_preview_autosave = vim.g.ktec_preview_autosave ~= false

    local group = vim.api.nvim_create_augroup("KtecWebPreviewAutoSave", { clear = true })
    vim.api.nvim_create_autocmd({ "InsertLeavePre", "TextChanged", "TextChangedI" }, {
        group = group,
        pattern = {
            "*.html",
            "*.css",
            "*.js",
            "*.jsx",
            "*.ts",
            "*.tsx",
            "*.vue",
            "*.svelte",
            "*.svg",
        },
        callback = function()
            if not vim.g.ktec_preview_autosave then
                return
            end

            if vim.bo.modifiable and vim.bo.modified and vim.fn.expand("%") ~= "" then
                vim.cmd("silent! write")
            end
        end,
        desc = "Autosave web files for live preview and HMR",
    })
end

local function create_commands()
    vim.api.nvim_create_user_command("PreviewUrl", function(opts)
        if opts.args ~= "" then
            open_url(opts.args)
        else
            prompt_url()
        end
    end, { nargs = "?", force = true })

    vim.api.nvim_create_user_command("PreviewLast", function()
        open_url(vim.g.ktec_preview_url or "http://localhost:5173")
    end, { force = true })

    vim.api.nvim_create_user_command("PreviewDev", function()
        start_dev_server("5173")
    end, { force = true })

    vim.api.nvim_create_user_command("BackendRun", function(opts)
        start_backend_server(opts.args ~= "" and opts.args or "8000")
    end, { nargs = "?", force = true })

    vim.api.nvim_create_user_command("PreviewDevPort", function(opts)
        start_dev_server(opts.args ~= "" and opts.args or "5173")
    end, { nargs = "?", force = true })

    vim.api.nvim_create_user_command("PreviewLiveServer", function(opts)
        start_live_server(opts.args ~= "" and opts.args or "5500")
    end, { nargs = "?", force = true })

    vim.api.nvim_create_user_command("PreviewTerm", function(opts)
        open_terminal_url(opts.args ~= "" and opts.args or "http://localhost:5173")
    end, { nargs = "?", force = true })
end

return {
    -- Kulala: API / Backend Visual Preview
    {
        "mistweaverco/kulala.nvim",
        ft = { "http", "rest" },
        keys = {
            { "<leader>rr", function() require("kulala").run() end,         desc = "Run request" },
            { "<leader>ra", function() require("kulala").run_all() end,     desc = "Run all requests" },
            { "<leader>r[", function() require("kulala").jump_prev() end,   desc = "Prev request" },
            { "<leader>r]", function() require("kulala").jump_next() end,   desc = "Next request" },
            { "<leader>ri", function() require("kulala").inspect() end,     desc = "Inspect request" },
            { "<leader>ry", function() require("kulala").copy() end,        desc = "Copy as curl" },
            { "<leader>rt", function() require("kulala").toggle_view() end, desc = "Toggle body/headers" },
        },
        opts = {
            winbar = true,
            default_view = "body",
            formatters = {
                json = "jq",
                html = "prettier",
            },
        },
    },

    -- Overseer: Visual Task & Server Management
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
        keys = {
            { "<leader>rv", "<cmd>OverseerToggle<CR>", desc = "Tasks status" },
            { "<leader>ro", "<cmd>OverseerRun<CR>",    desc = "Overseer run task" },
            { "<leader>rb", function() start_backend_server("8000") end, desc = "Run backend" },
            { "<leader>rB", start_backend_prompt, desc = "Run backend on port" },
            { "<leader>rp", start_dev_server_prompt,   desc = "Run dev server on port" },
            { "<leader>rd", function() start_dev_server("5173") end, desc = "Run dev server" },
        },
        opts = {
            templates = { "builtin" },
            task_list = {
                direction = "right",
                bindings = {
                    ["<C-l>"] = false,
                    ["<C-h>"] = false,
                    ["L"] = "IncreaseDetail",
                    ["H"] = "DecreaseDetail",
                },
            },
        },
    },

    -- Web Tools: Browser Sync & HTML Preview
    {
        "brianhuster/live-preview.nvim",
        cmd = { "LivePreview" },
        dependencies = { "folke/snacks.nvim", "stevearc/overseer.nvim" },
        init = function()
            setup_autosave()
            create_commands()
        end,
        config = function()
            require("livepreview.config").set({
                port = 5500,
                browser = "default",
                dynamic_root = false,
                sync_scroll = true,
                picker = "snacks.picker",
                address = "127.0.0.1",
            })
        end,
        keys = {
            { "<leader>vp", preview_static, desc = "Static live preview" },
            { "<leader>vP", "<cmd>LivePreview pick<CR>", desc = "Pick live preview file" },
            { "<leader>vd", function() start_dev_server("5173") end, desc = "Start dev server" },
            { "<leader>vD", start_dev_server_prompt, desc = "Start dev server on port" },
            { "<leader>vl", function() start_live_server("5500") end, desc = "Start live-server" },
            { "<leader>vu", function() prompt_url("http://localhost:5173") end, desc = "Open preview URL/port" },
            { "<leader>vv", function() open_url(vim.g.ktec_preview_url or "http://localhost:5173") end, desc = "Open last preview" },
            { "<leader>vx", close_preview, desc = "Close static preview" },
            { "<leader>vt", function() open_terminal_url("http://localhost:5173") end, desc = "Terminal browser preview" },
        },
    },

    -- Dadbod: Database Visual UI
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
        end,
        keys = {
            { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Database UI" },
        },
    },
}
