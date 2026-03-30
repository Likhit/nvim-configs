-- LSP configuration
--
-- Uses Neovim 0.11's native vim.lsp.config() / vim.lsp.enable().
-- Server configs live in lsp/<server>.lua at the config root.
-- LSP server binaries are installed via Nix (nix/lsp-servers.nix).

-- Advertise blink.cmp capabilities to all LSP servers
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Enable all configured LSP servers
vim.lsp.enable({
  "marksman",
  "clangd",
  "pyright",
  "ts_ls",
  "html",
  "cssls",
  "nil_ls",
  "lua_ls",
})

-- Diagnostics display
vim.diagnostic.config({
  virtual_lines = true,
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
