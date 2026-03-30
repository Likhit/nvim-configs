-- Custom statusline
--
-- Layout: [mode] [git branch] [icon + filename + modified]  ...  [lsp status] [diagnostics] [line:col]
-- Uses Nerd Font icons for common filetypes. Requires a Nerd Font in the terminal.

local lsp_status = require("custom.lsp_status")

-- Data tables ----------------------------------------------------------------

local mode_map = {
  ["n"]  = { "NORMAL",  "StatusMode_Normal" },
  ["i"]  = { "INSERT",  "StatusMode_Insert" },
  ["v"]  = { "VISUAL",  "StatusMode_Visual" },
  ["V"]  = { "V-LINE",  "StatusMode_Visual" },
  ["\22"] = { "V-BLOCK", "StatusMode_Visual" },
  ["c"]  = { "COMMAND", "StatusMode_Command" },
  ["R"]  = { "REPLACE", "StatusMode_Replace" },
  ["t"]  = { "TERMINAL","StatusMode_Terminal" },
  ["s"]  = { "SELECT",  "StatusMode_Visual" },
  ["S"]  = { "S-LINE",  "StatusMode_Visual" },
}

-- Nerd Font icons (Unicode escapes to survive file encoding)
local ft_icons = {
  lua        = "\u{e620}",
  python     = "\u{e73c}",
  javascript = "\u{e74e}",
  typescript = "\u{e628}",
  typescriptreact = "\u{e7ba}",
  javascriptreact = "\u{e7ba}",
  html       = "\u{e736}",
  css        = "\u{e749}",
  c          = "\u{e61e}",
  cpp        = "\u{e61d}",
  nix        = "\u{f313}",
  markdown   = "\u{e73e}",
  json       = "\u{e60b}",
  yaml       = "\u{e6a8}",
  bash       = "\u{e795}",
  sh         = "\u{e795}",
  zsh        = "\u{e795}",
  fish       = "\u{e795}",
  rust       = "\u{e7a8}",
  go         = "\u{e627}",
  toml       = "\u{e6b2}",
  vim        = "\u{e62b}",
}

-- LSP state -> { highlight, format }
local lsp_display = {
  starting     = { "DiagnosticWarn",  "LSP\u{2026}" },
  loading      = { "DiagnosticWarn",  "LSP: %s" },
  ok           = { "DiagnosticOk",   "LSP" },
  unresponsive = { "DiagnosticError", "LSP: stuck" },
  error        = { "DiagnosticError", "LSP: %s" },
}

-- Git branch cache -----------------------------------------------------------

local git_branch = ""

local function refresh_git_branch()
  local head = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
  git_branch = vim.v.shell_error == 0 and head:gsub("%s+$", "") or ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("statusline-git", { clear = true }),
  callback = refresh_git_branch,
})

refresh_git_branch()

-- Statusline renderer --------------------------------------------------------

local function hl(group, text)
  return ("%%#%s#%s%%*"):format(group, text)
end

function _G.statusline()
  local parts = {}

  -- Mode
  local info = mode_map[vim.fn.mode()] or { vim.fn.mode():upper(), "StatusMode_Normal" }
  parts[#parts + 1] = hl(info[2], " " .. info[1] .. " ")

  -- Git branch
  if git_branch ~= "" then
    parts[#parts + 1] = hl("StatusGit", "  " .. git_branch .. " ")
  end

  -- Filetype icon + filename + modified
  local icon = ft_icons[vim.bo.filetype]
  local name = vim.fn.expand("%:.")
  if name == "" then name = "[No Name]" end
  local file = icon and (icon .. " " .. name) or name
  if vim.bo.modified then file = file .. " [+]"
  elseif vim.bo.readonly then file = file .. " [-]" end
  parts[#parts + 1] = " " .. file

  -- Spacer
  parts[#parts + 1] = "%="

  -- LSP status
  local ls = lsp_status.get(vim.api.nvim_get_current_buf())
  if ls then
    local disp = lsp_display[ls.state]
    if disp then
      local text = ls.message and disp[2]:format(ls.message) or disp[2]
      parts[#parts + 1] = hl(disp[1], text) .. " "
    end
  end

  -- Diagnostics
  local errs = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  if errs > 0 or warns > 0 then
    local d = {}
    if errs > 0 then d[#d + 1] = hl("DiagnosticError", errs .. "E") end
    if warns > 0 then d[#d + 1] = hl("DiagnosticWarn", warns .. "W") end
    parts[#parts + 1] = table.concat(d, " ") .. "  "
  end

  -- Line:Column
  parts[#parts + 1] = "%l:%c "

  return table.concat(parts)
end

-- Highlights -----------------------------------------------------------------

local function set_highlights()
  local hi = vim.api.nvim_set_hl
  hi(0, "StatusMode_Normal",  { fg = "#1a1b26", bg = "#7aa2f7", bold = true })
  hi(0, "StatusMode_Insert",  { fg = "#1a1b26", bg = "#9ece6a", bold = true })
  hi(0, "StatusMode_Visual",  { fg = "#1a1b26", bg = "#bb9af7", bold = true })
  hi(0, "StatusMode_Command", { fg = "#1a1b26", bg = "#e0af68", bold = true })
  hi(0, "StatusMode_Replace", { fg = "#1a1b26", bg = "#f7768e", bold = true })
  hi(0, "StatusMode_Terminal",{ fg = "#1a1b26", bg = "#7dcfff", bold = true })
  hi(0, "StatusGit",          { fg = "#e0af68", bold = true })
  hi(0, "WinSeparator",       { fg = "#565f89" })
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("statusline-colors", { clear = true }),
  callback = set_highlights,
})

vim.o.statusline = "%!v:lua.statusline()"
