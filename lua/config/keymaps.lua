-- Keybindings: leader key, navigation, editing shortcuts

-- Leader key: Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Window navigation: Ctrl+h/j/k/l instead of Ctrl+w then h/j/k/l
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Window resizing: Ctrl+arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Equalize splits: Ctrl+=
map("n", "<C-=>", "<C-w>=")

-- Stay in visual mode after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over selection without yanking replaced text
map("v", "p", '"_dP')

-- Join lines without moving cursor
map("n", "J", "mzJ`z")

-- Undo break points in insert mode at punctuation and newlines
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")
map("i", "<CR>", "<CR><C-g>u")

-- Half-page scroll + center cursor
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Search match + center + open folds
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Smart j/k: move by screen line when no count, logical line with count
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Terminal: double Esc to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- Terminal: window navigation with Ctrl+h/j/k/l
map("t", "<C-h>", "<cmd>wincmd h<CR>")
map("t", "<C-j>", "<cmd>wincmd j<CR>")
map("t", "<C-k>", "<cmd>wincmd k<CR>")
map("t", "<C-l>", "<cmd>wincmd l<CR>")

-- Clear search highlight with Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save with Ctrl+s from any mode
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>")
