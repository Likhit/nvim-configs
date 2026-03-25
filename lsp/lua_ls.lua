return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
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
