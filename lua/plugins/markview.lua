-- Markview: inline rendering for Markdown, LaTeX, Typst
-- Plugin is installed via Nix (nix/plugins.nix).

require("markview").setup({
  preview = {
    filetypes = { "markdown", "latex", "typst" },
  },
})
