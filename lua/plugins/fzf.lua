-- Fuzzy finder (fzf-lua)
--
-- File search, live grep, buffer list, LSP symbols, diagnostics.
-- Requires fzf, fd, and rg on PATH (installed via Nix).

local fzf = require("fzf-lua")

fzf.setup({
  "default",
  fzf_opts = {
    ["--header"] = "enter:open | ctrl-s:split | ctrl-v:vsplit | ctrl-t:tab | tab:multi-select",
  },
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = {
      layout = "horizontal",
      horizontal = "right:50%",
    },
  },
  files = {
    cmd = "fd --type f --hidden --follow --exclude .git",
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case",
  },
})

-- Use fzf for all vim.ui.select menus (code actions, etc.)
fzf.register_ui_select()

-- Keymaps (all under <leader>f for "find")
local map = vim.keymap.set
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Help tags" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document diagnostics" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>fc", fzf.git_status, { desc = "Changed files (git status)" })
map("n", "<leader>fl", fzf.lsp_references, { desc = "LSP references" })
map("v", "<leader>fv", fzf.grep_visual, { desc = "Grep visual selection" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>f:", fzf.commands, { desc = "Commands" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last search" })
