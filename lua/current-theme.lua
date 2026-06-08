local ok, err = pcall(vim.cmd.colorscheme, "solarized-osaka")

if not ok then
    vim.schedule(function()
        vim.notify("Could not load colorscheme solarized-osaka: " .. err, vim.log.levels.WARN)
    end)
end
