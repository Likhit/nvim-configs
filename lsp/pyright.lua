return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        reportMissingTypeStubs = false,
        reportUnknownMemberType = false,
      },
    },
  },
}
