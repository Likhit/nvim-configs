-- Completion engine setup (blink.cmp)
--
-- Built-in sources: LSP, buffer words, file paths, snippets, cmdline.
-- Snippets use Neovim's native vim.snippet (no external engine needed).
-- Renders its own completion menu (ignores completeopt).

require("blink.cmp").setup({
  keymap = {
    preset = "none",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-e>"] = { "hide", "fallback" },
  },

  completion = {
    documentation = { auto_show = true },
    list = {
      selection = {
        preselect = false,
        auto_insert = true,
      },
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  cmdline = {
    enabled = true,
  },
})
