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
map("n", "<leader>ff", fzf.files, { desc = "Find files #fzf #file" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep #fzf #search" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers #fzf #buffer" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Help tags #fzf #help" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files #fzf #file" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor #fzf #search" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document diagnostics #fzf #lsp #diagnostics" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols #fzf #lsp" })
map("n", "<leader>fc", fzf.git_status, { desc = "Changed files (git status) #fzf #git" })
map("n", "<leader>fl", fzf.lsp_references, { desc = "LSP references #fzf #lsp" })
map("v", "<leader>fv", fzf.grep_visual, { desc = "Grep visual selection #fzf #search" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps #fzf" })
map("n", "<leader>f:", fzf.commands, { desc = "Commands #fzf" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last search #fzf" })
