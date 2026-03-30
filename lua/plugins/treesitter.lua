-- TreeSitter configuration
--
-- Grammars are installed via Nix (grammarPlugins in nix/plugins.nix).
-- The parsers are on the runtimepath — Neovim finds them automatically.
-- No nvim-treesitter plugin needed: we use Neovim's built-in treesitter API.

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    local ok = pcall(vim.treesitter.language.add, lang)
    if not ok then
      return
    end

    pcall(vim.treesitter.start, ev.buf, lang)
  end,
})
