-- Vim options: UI, search, indentation, editing behavior

local opt = vim.opt

-- Line numbers: absolute for current line, relative for all others
opt.number = true
opt.relativenumber = true

-- Highlight the line the cursor is on
opt.cursorline = true

-- Always show sign column (used by diagnostics, gitsigns)
opt.signcolumn = "yes"

-- Keep 8 lines visible above/below and left/right of cursor
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 24-bit RGB colors (required for colorschemes)
opt.termguicolors = true

-- Don't show mode in command line (we'll show it in the statusline)
opt.showmode = false

-- Suppress intro splash screen
opt.shortmess:append("I")

-- Case-insensitive search, unless uppercase is used
opt.ignorecase = true
opt.smartcase = true

-- Highlight all search matches
opt.hlsearch = true

-- Live preview of substitutions in a split
opt.inccommand = "split"

-- Use spaces instead of tabs (overridden for plain text in autocmds.lua)
opt.expandtab = true

-- 2-space indentation (overridden per filetype in languages/)
opt.shiftwidth = 2
opt.tabstop = 2

-- New lines inherit indentation, with smart indent for code blocks
opt.autoindent = true
opt.smartindent = true

-- Clipboard via OSC 52 (works through SSH, microVMs, tmux)
-- Requires terminal support (kitty, alacritty, wezterm, ghostty, etc.)
-- Kitty: set `clipboard_control write-clipboard write-primary read-clipboard read-primary` in kitty.conf
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- Route all yank/paste through the clipboard provider above
opt.clipboard = "unnamedplus"

-- Persist undo history across sessions
opt.undofile = true

-- No swap files (git handles recovery)
opt.swapfile = false

-- Auto-reload files changed externally (pairs with checktime autocmd)
opt.autoread = true

-- Splits open below and to the right
opt.splitbelow = true
opt.splitright = true

-- Faster CursorHold events (used by gitsigns, LSP hover, etc.)
opt.updatetime = 250

-- Time in ms to wait for a mapped key sequence to complete
opt.timeoutlen = 300

-- Wrap long lines
opt.wrap = true

-- Completion popup: show even with one match, don't auto-select
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Enable mouse in all modes
opt.mouse = "a"

-- Characters for invisible whitespace (visible with :set list)
opt.listchars = { tab = ">>", trail = ".", nbsp = "~" }

-- Clean up empty line markers (no ~ after buffer end)
opt.fillchars = { eob = " " }

-- Wrapped lines keep their indent level
opt.breakindent = true

-- Text stays in place when opening splits
opt.splitkeep = "screen"

-- Prompt to save instead of erroring on unsaved quit
opt.confirm = true

-- No backup files (undofile handles recovery)
opt.backup = false
opt.writebackup = false

-- Round indent to nearest shiftwidth
opt.shiftround = true

-- Use ripgrep for :grep
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Free cursor movement in visual block mode
opt.virtualedit = "block"

-- Single global statusline across all windows
opt.laststatus = 3

-- Rounded borders on all floating windows (0.11+)
opt.winborder = "rounded"

-- Smarter command-line tab completion
opt.wildmode = "longest:full,full"

-- Exclude common junk from file completion
opt.wildignore:append({ "*.o", "*.pyc", "__pycache__", ".git", "node_modules" })

-- Stop syntax highlighting after column 300 (performance)
opt.synmaxcol = 300

-- Scroll by screen line instead of logical line (smoother with wrapped lines)
opt.smoothscroll = true
