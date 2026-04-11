-- Keybindings: leader key, navigation, editing shortcuts

-- Leader key: Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Window navigation: Ctrl+h/j/k/l instead of Ctrl+w then h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window #navigation #window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window #navigation #window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window #navigation #window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window #navigation #window" })

-- Window resizing: Ctrl+arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height #window #resize" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height #window #resize" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width #window #resize" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width #window #resize" })

-- Equalize splits: Ctrl+=
map("n", "<C-=>", "<C-w>=", { desc = "Equalize window sizes #window #resize" })

-- Stay in visual mode after indenting
map("v", "<", "<gv", { desc = "Indent left and reselect #editing #indent" })
map("v", ">", ">gv", { desc = "Indent right and reselect #editing #indent" })

-- Paste over selection without yanking replaced text
map("v", "p", '"_dP', { desc = "Paste without yanking replaced text #editing #clipboard" })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join lines (cursor stays) #editing" })

-- Undo break points in insert mode at punctuation and newlines
map("i", ",", ",<C-g>u", { desc = "Undo break point at comma #editing #undo" })
map("i", ".", ".<C-g>u", { desc = "Undo break point at period #editing #undo" })
map("i", ";", ";<C-g>u", { desc = "Undo break point at semicolon #editing #undo" })
map("i", "<CR>", "<CR><C-g>u", { desc = "Undo break point at newline #editing #undo" })

-- Half-page scroll + center cursor
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page (centered) #navigation #scroll" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page (centered) #navigation #scroll" })

-- Search match + center + open folds
map("n", "n", "nzzzv", { desc = "Next search match (centered) #navigation #search" })
map("n", "N", "Nzzzv", { desc = "Previous search match (centered) #navigation #search" })

-- Smart j/k: move by screen line when no count, logical line with count
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (screen line when no count) #navigation #motion" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (screen line when no count) #navigation #motion" })

-- Terminal: double Esc to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode #terminal" })

-- Terminal: window navigation with Ctrl+h/j/k/l
map("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Move to left window #terminal #navigation #window" })
map("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Move to below window #terminal #navigation #window" })
map("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Move to above window #terminal #navigation #window" })
map("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Move to right window #terminal #navigation #window" })

-- Toggle bottom terminal with Ctrl+`
local term_buf = nil
local function toggle_terminal()
  -- If terminal window is visible, hide it
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_buf then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  end

  -- Open a bottom split
  vim.cmd("botright 20split")

  -- Reuse existing terminal buffer or create a new one
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end

  vim.cmd("startinsert")
end

map({ "n", "t" }, "<C-`>", toggle_terminal, { desc = "Toggle bottom terminal #terminal" })

-- Clear search highlight with Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight #search" })

-- Save with Ctrl+s from any mode
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file #file" })
