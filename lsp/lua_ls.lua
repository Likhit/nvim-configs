return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        -- Only include the Neovim runtime (for vim.* API awareness).
        -- nvim_get_runtime_file("", true) includes ALL plugins on the runtimepath
        -- (colorschemes, treesitter grammars, etc.) which makes lua_ls take minutes to index.
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
      diagnostics = {
        -- Recognize vim global
        globals = { "vim" },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
