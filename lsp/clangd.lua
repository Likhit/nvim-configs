return {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--fallback-style=Google",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
  },
  filetypes = { "c", "cpp", "objc", "objcpp" },
}
