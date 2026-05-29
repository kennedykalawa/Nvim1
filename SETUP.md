# Ktec Neovim Setup

This file is the living guide for this Neovim config. Keep it updated whenever a
plugin, workflow, or keymap changes.

## Structure

| Path | Purpose |
| --- | --- |
| `init.lua` | Entry point. Loads core options, plugins, and current theme. |
| `lua/Ktec/core/options.lua` | Editor behavior: numbers, indentation, undo, search, UI, folds. |
| `lua/Ktec/core/keymaps.lua` | Core mappings that should work without waiting for plugins. |
| `lua/Ktec/lazy.lua` | Lazy.nvim bootstrap and plugin imports. |
| `lua/Ktec/plugins/init.lua` | Base plugins and which-key group labels. |
| `lua/Ktec/plugins/lsp/init.lua` | LSP, diagnostics, completion, formatters, Trouble, rename. |
| `lua/Ktec/plugins/snacks.lua` | Snacks terminal, picker, dashboard, rename, lazygit, UI helpers. |
| `lua/Ktec/plugins/previews.lua` | Browser previews, API requests, tasks, database UI. |
| `lua/Ktec/plugins/coderunner.lua` | Run the current file or selection in a terminal. |
| `lua/Ktec/plugins/extras.lua` | Extra editing, git, markdown, folding, movement, and utility plugins. |
| `lua/current-theme.lua` | Persisted theme loaded at startup. |

## Keymap Rules

The leader key is `Space`.

Keymaps are grouped by prefix so which-key stays readable:

| Prefix | Area |
| --- | --- |
| `<leader>a` | AI CLI tools |
| `<leader>b` | Buffers |
| `<leader>c` | Code actions |
| `<leader>d` | Debug/delete |
| `<leader>g` | Git |
| `<leader>h` | Harpoon |
| `<leader>l` | LSP |
| `<leader>p` | Pickers/search |
| `<leader>q` | Comment boxes |
| `<leader>r` | Run/API/rename |
| `<leader>s` | Splits/replace |
| `<leader>t` | Tabs/terminal |
| `<leader>u` | UI/undo |
| `<leader>v` | Preview |
| `<leader>w` | Workspace/session |
| `<leader>x` | Diagnostics/Trouble |

## Core

| Key | Action |
| --- | --- |
| `<leader><leader>` | Source current file |
| `<C-s>` | Save file |
| `<C-c>` | Clear search highlight in normal mode, escape in insert mode |
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to system clipboard |
| `<leader>d` | Delete without changing registers |
| `<leader>p` | Paste without replacing the yank register in visual mode |
| `<leader>f` | Format current buffer |
| `<leader>fp` | Copy current file path |
| `<leader>lx` | Toggle LSP diagnostics display |
| `<leader>e` | Open diagnostic float |
| `[d` / `]d` | Previous/next diagnostic |
| `<C-Up>` / `<C-Down>` | Resize split height |
| `<C-Left>` / `<C-Right>` | Resize split width |

## Tabs, Splits, Buffers

| Key | Action |
| --- | --- |
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn` | Next tab |
| `<leader>tp` | Previous tab |
| `<leader>tf` | Open current buffer in a new tab |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>se` | Equalize split sizes |
| `<leader>sx` | Close split |
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bp` | Pin buffer |
| `<leader>bP` | Close unpinned buffers |
| `<leader>bo` | Close other buffers |
| `<leader>bl` / `<leader>bh` | Close buffers right/left |
| `<leader>1` to `<leader>5` | Jump to buffer 1-5 |

## Pickers And Search

| Key | Action |
| --- | --- |
| `<leader>pf` | Find files |
| `<leader>pr` | Recent files |
| `<leader>pc` | Neovim config files |
| `<leader>ps` | Live grep |
| `<leader>pws` | Grep word or visual selection |
| `<leader>pWs` | Grep full WORD under cursor |
| `<leader>pk` | Keymap picker |
| `<leader>ph` | Help pages |
| `<leader>pb` | Buffers |
| `<leader>pd` | Workspace diagnostics |
| `<leader>pD` | Buffer diagnostics |
| `<leader>po` | LSP symbols |
| `<leader>pt` | All TODOs |
| `<leader>pT` | Main TODO/FIXME/FORGETNOT entries |

## Terminal

Terminal behavior is centralized through Snacks. The older `terminalpop.lua` file
was removed so terminal mappings are not defined twice.

| Key | Action |
| --- | --- |
| `<C-\>` | Toggle floating terminal |
| `<leader>tt` | Toggle floating terminal |
| `<leader>ts` | Open terminal in a split |
| `<leader>tN` | Open named floating terminal |
| `<leader>tP` | Open project terminal |
| `<Esc>` in terminal | Leave terminal insert mode |
| `<C-h/j/k/l>` in terminal | Move between windows |

## Preview And Web

Static preview uses `brianhuster/live-preview.nvim`. Framework apps still use the
real browser because terminal Neovim cannot render a full browser engine.

| Key | Action |
| --- | --- |
| `<leader>vp` | Start static live preview for current file |
| `<leader>vP` | Pick a file to preview |
| `<leader>vx` | Close static live preview |
| `<leader>vv` | Open Vite URL, default `http://localhost:5173` |
| `<leader>vr` | Open React URL, default `http://localhost:3000` |
| `<leader>vb` | Open backend URL, default `http://localhost:8000` |
| `<leader>vu` | Prompt for a custom preview URL |
| `<leader>vt` | Open URL in a right-side terminal browser with browsh |

Preview autosave is enabled for web files by default. Disable it for the current
session with:

```lua
:lua vim.g.ktec_preview_autosave = false
```

## API, Backend, Database

| Key | Action |
| --- | --- |
| `<leader>rr` | Run current HTTP request with Kulala |
| `<leader>ra` | Run all HTTP requests |
| `<leader>r[` | Previous request |
| `<leader>r]` | Next request |
| `<leader>ri` | Inspect request |
| `<leader>ry` | Copy request as curl |
| `<leader>rt` | Toggle response body/headers |
| `<leader>ov` | Toggle Overseer task/status panel |
| `<leader>or` | Run Overseer task |
| `<leader>db` | Toggle database UI |

## Code Runner

`coderunner.lua` escapes file paths before building shell commands, so files with
spaces are safer. HTML `live-server` is tracked by job id instead of using
`pkill -f`.

| Key | Action |
| --- | --- |
| `<leader>rc` | Run current file |
| `<leader>rs` | Run visual selection |
| `<leader>rw` | Run current file with prompted args |
| `<leader>rx` | Close the runner terminal |
| `<leader>rl` | Run line/selection with SnipRun |
| `<leader>rX` | Close SnipRun output |
| `<leader>rN` | Rename current file |
| `<leader>rn` | Rename symbol with live preview |
| `<leader>ls` | Start tracked HTML live-server |
| `<leader>lS` | Stop tracked HTML live-server |

## LSP And Diagnostics

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gI` | Implementation |
| `gy` | Type definition |
| `K` | Hover docs |
| `<C-k>` | Signature help |
| `<leader>lR` | Native LSP rename |
| `<leader>la` | Code action |
| `<leader>lf` | Format |
| `<leader>li` | LSP info |
| `<leader>lr` | Restart LSP |
| `<leader>lh` | Toggle inlay hints when supported |
| `<leader>lm` | Mason |
| `<leader>xx` | Trouble diagnostics |
| `<leader>xX` | Trouble buffer diagnostics |
| `<leader>xl` | Trouble LSP sidebar |
| `<leader>xL` | Trouble location list |
| `<leader>xq` | Trouble quickfix |

Installed LSP servers include frontend, backend, data, and systems tooling:
`ts_ls`, `eslint`, `html`, `cssls`, `tailwindcss`, `svelte`, `graphql`,
`emmet_ls`, `prismals`, `lua_ls`, `bashls`, `pyright`, `gopls`,
`rust_analyzer`, `jsonls`, `yamlls`, `dockerls`,
`docker_compose_language_service`, and `omnisharp`.

## AI CLI

AI integration is CLI-first. It opens the same authenticated tools you use in the
terminal: `codex`, `gemini`, `copilot`, and `claude`. This avoids Neovim-specific
API key setup.

| Key | Action |
| --- | --- |
| `<leader>aa` | Choose an AI CLI to open in a right-side split |
| `<leader>ac` | Open Codex CLI in a right-side split |
| `<leader>ag` | Open Gemini CLI in a right-side split |
| `<leader>ap` | Open Copilot CLI in a right-side split |
| `<leader>al` | Open Claude CLI in a right-side split |
| `<leader>aA` | Ask a one-off prompt through a chosen CLI |
| `<leader>aR` | Review current file through a chosen CLI |
| `<leader>as` | Review visual selection |
| `<leader>ae` | Explain error under cursor |
| `<leader>ar` | Resume the latest Codex session |

Commands are also available:

| Command | Action |
| --- | --- |
| `:Ai` | Choose and open an interactive AI CLI |
| `:AiAsk` | Ask a one-off prompt |
| `:AiReview` | Review the current file |
| `:AiExplainError` | Explain diagnostic/current line |

## Git

| Key | Action |
| --- | --- |
| `<leader>gg` | Fugitive |
| `<leader>gP` | Git push |
| `<leader>gpl` | Git pull with rebase |
| `<leader>gt` | Start upstream push command |
| `<leader>lg` | Lazygit |
| `<leader>gl` | Lazygit log |
| `<leader>gfl` | Lazygit file log |
| `<leader>gbr` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `<leader>gdo` | Diffview open |
| `<leader>gdc` | Diffview close |
| `<leader>gdh` | Current file history |
| `<leader>gdH` | Repository file history |
| `<leader>gn` | Neogit |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghR` | Reset buffer |
| `<leader>ghu` | Undo staged hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghB` | Toggle line blame |
| `<leader>ghd` | Diff this |
| `<leader>ghD` | Diff this against previous |

## Harpoon

| Key | Action |
| --- | --- |
| `<leader>ha` | Add file to Harpoon |
| `<leader>hh` | Harpoon quick menu |
| `<leader>h1` to `<leader>h4` | Jump to Harpoon file 1-4 |
| `<leader>hp` | Previous Harpoon entry |
| `<leader>hn` | Next Harpoon entry |

## UI, Editing, Markdown

| Key | Action |
| --- | --- |
| `<leader>u` | Undo tree |
| `<leader>uc` | Temporary colorscheme picker |
| `<leader>uT` | Persisted theme switcher |
| `<leader>mp` | Markdown preview in browser |
| `<leader>qb` | Comment box |
| `<leader>qc` | Centered comment box |
| `<leader>ql` | Comment line |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek folded lines or hover |
| `s` | Flash jump |
| `S` | Flash Treesitter jump |
| `w`, `e`, `b`, `ge` | Spider word motions |
| `<leader>sk` | Toggle showkeys |
| `-` | Open Oil parent directory |
| `<leader>-` | Toggle Oil float |
| `<leader>ee` | Toggle MiniFiles |
| `<leader>ef` | Open MiniFiles at current file |
| `<leader>cw` | Trim trailing whitespace |
| `sj` / `sk` | Join/split arguments with MiniSplitJoin |

## Maintenance Checklist

Before considering this setup clean after edits:

1. Run `nvim --headless '+quit'`.
2. Search for duplicate mappings with `rg "<key>" ~/.config/nvim/lua`.
3. Update this file when adding, moving, or removing keymaps.
4. Keep plugin-specific mappings in the plugin file that owns the feature.
5. Prefer one owner per prefix to avoid load-order surprises.
