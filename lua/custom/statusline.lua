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

-- Winbar renderer ------------------------------------------------------------

local winbar_skip = { terminal = true, nofile = true, quickfix = true, help = true, prompt = true }

function _G.winbar()
  local bt = vim.bo.buftype
  if winbar_skip[bt] then return "" end

  local icon = ft_icons[vim.bo.filetype]
  local name = vim.fn.expand("%:.")
  if name == "" then return "" end

  local is_active = vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)

  local label = {}
  if icon then
    label[#label + 1] = hl(is_active and "WinBarIcon" or "WinBarIconNC", icon)
    label[#label + 1] = " "
  end
  label[#label + 1] = hl(is_active and "WinBar" or "WinBarNC", name)
  if vim.bo.modified then
    label[#label + 1] = hl("WinBarModified", " [+]")
  end

  return "%=" .. table.concat(label) .. "%="
end

vim.o.winbar = "%{%v:lua.winbar()%}"

-- Highlights -----------------------------------------------------------------

local function set_highlights()
  local hi = vim.api.nvim_set_hl

  -- Mode highlights: reverse the linked group so text is readable on colored bg
  hi(0, "StatusMode_Normal",  { link = "Function",    bold = true, reverse = true })
  hi(0, "StatusMode_Insert",  { link = "String",      bold = true, reverse = true })
  hi(0, "StatusMode_Visual",  { link = "Keyword",     bold = true, reverse = true })
  hi(0, "StatusMode_Command", { link = "Type",        bold = true, reverse = true })
  hi(0, "StatusMode_Replace", { link = "Error",       bold = true, reverse = true })
  hi(0, "StatusMode_Terminal",{ link = "Special",     bold = true, reverse = true })
  hi(0, "StatusGit",          { link = "Type",        bold = true })

  -- Winbar: use the StatusLine bg so it looks like a darker bar
  local stl = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local bar_bg = stl.bg

  local function fg_of(group)
    local h = vim.api.nvim_get_hl(0, { name = group, link = false })
    return h.fg
  end

  hi(0, "WinBar",             { fg = fg_of("Normal"),   bg = bar_bg, bold = true })
  hi(0, "WinBarNC",           { fg = fg_of("NonText"),  bg = bar_bg })
  hi(0, "WinBarIcon",         { fg = fg_of("Function"), bg = bar_bg, bold = true })
  hi(0, "WinBarIconNC",       { fg = fg_of("NonText"),  bg = bar_bg })
  hi(0, "WinBarModified",     { fg = fg_of("Type"),     bg = bar_bg })

  hi(0, "WinSeparator",       { link = "NonText" })
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("statusline-colors", { clear = true }),
  callback = set_highlights,
})

vim.o.statusline = "%!v:lua.statusline()"
