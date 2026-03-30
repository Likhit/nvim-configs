-- Autocommands: UI behavior, filetype settings

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Briefly highlight yanked text
autocmd("TextYankPost", {
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last edit position when reopening a file
autocmd("BufReadPost", {
  group = augroup("restore-cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Auto-reload files changed externally
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("auto-reload", { clear = true }),
  command = "checktime",
})

-- Prevent ftplugins from overriding formatoptions
autocmd("FileType", {
  group = augroup("formatoptions", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "o", "r" })
  end,
})

-- Resize splits when terminal window is resized
autocmd("VimResized", {
  group = augroup("resize-splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim-whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Python: 4-space indent (PEP 8)
autocmd("FileType", {
  group = augroup("ft-python", { clear = true }),
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Use tabs instead of spaces for plain text and undetected filetypes
autocmd("FileType", {
  group = augroup("text-tabs", { clear = true }),
  pattern = { "text", "" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})
