return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#0b0f1a',
				base01 = '#0b0f1a',
				base02 = '#8c95a5',
				base03 = '#8c95a5',
				base04 = '#e0eaff',
				base05 = '#f2f6ff',
				base06 = '#f2f6ff',
				base07 = '#f2f6ff',
				base08 = '#ff3f75',
				base09 = '#ff3f75',
				base0A = '#266eff',
				base0B = '#4cff67',
				base0C = '#8cb2ff',
				base0D = '#266eff',
				base0E = '#4c88ff',
				base0F = '#4c88ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#8c95a5',
				fg = '#f2f6ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#266eff',
				fg = '#0b0f1a',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#8c95a5' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#8cb2ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#4c88ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#266eff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#266eff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#8cb2ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#4cff67',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#e0eaff' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#e0eaff' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#8c95a5',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
