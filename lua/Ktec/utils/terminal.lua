local M = {}

local function title(label)
    return "  Terminal" .. (label and (": " .. label) or "")
end

function M.window_options(opts)
    opts = opts or {}

    local wo = {
        wrap = true,
        linebreak = true,
        breakindent = true,
        breakindentopt = "shift:2,sbr",
        showbreak = "> ",
        scrolloff = 0,
        sidescrolloff = 0,
    }
    if opts.wo then
        wo = vim.tbl_extend("force", wo, opts.wo)
    end

    return wo
end

local function split_window(position)
    if position == "right" then
        vim.cmd("rightbelow vertical split")
    elseif position == "left" then
        vim.cmd("leftabove vertical split")
    elseif position == "bottom" then
        vim.cmd("belowright split")
    elseif position == "top" then
        vim.cmd("aboveleft split")
    end
end

local function resize_current(position, opts)
    opts = opts or {}

    if position == "right" or position == "left" then
        local columns = vim.o.columns
        local width = opts.width or math.max(32, math.floor(columns * 0.4))
        vim.cmd("vertical resize " .. width)
    elseif position == "bottom" or position == "top" then
        local lines = vim.o.lines
        local height = opts.height or math.max(10, math.floor(lines * 0.35))
        vim.cmd("resize " .. height)
    end
end

function M.open(position, opts)
    opts = opts or {}
    position = position or "float"

    local win = {
        border = "rounded",
        title = title(opts.title),
        title_pos = "center",
        wo = M.window_options(opts),
    }

    if position == "float" then
        win.position = "float"
        win.height = opts.height or 0.7
        win.width = opts.width or 0.85
    else
        split_window(position)
        resize_current(position, opts)
        win.position = "current"
    end

    return require("snacks").terminal.open(opts.cmd, {
        win = win,
        cwd = opts.cwd,
        env = vim.tbl_extend("force", { SHELL = os.getenv("SHELL") or "/bin/zsh" }, opts.env or {}),
        auto_close = opts.auto_close == nil and false or opts.auto_close,
    })
end

function M.open_many(position, count, opts)
    count = tonumber(count) or 1

    for index = 1, count do
        local item_opts = vim.deepcopy(opts or {})
        if count > 1 and item_opts.title then
            item_opts.title = item_opts.title .. " " .. index
        end
        M.open(position, item_opts)
    end
end

function M.choose(opts)
    opts = opts or {}

    vim.ui.select({
        { label = "Float", position = "float" },
        { label = "Right", position = "right" },
        { label = "Left", position = "left" },
        { label = "Bottom", position = "bottom" },
        { label = "Top", position = "top" },
    }, {
        prompt = opts.prompt or "Terminal split:",
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            M.open_many(choice.position, vim.v.count1, { title = choice.label })
        end
    end)
end

return M
