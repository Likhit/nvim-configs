-- Session management
--
-- Saves/restores Neovim sessions (splits, buffers, cursor positions) per project.
-- Sessions stored in stdpath("data")/sessions/ with a companion .path file
-- that records the real project path (avoids lossy filename encoding).
--
-- Usage:
--   local sessions = require("custom.sessions")
--   sessions.save([path])     -- save session (defaults to cwd)
--   sessions.restore(path)    -- restore a session by project path
--   sessions.delete(path)     -- delete a session
--   sessions.list()           -- returns { { path, mtime }, ... } sorted by recency

local M = {}

local sessions_dir = vim.fn.stdpath("data") .. "/sessions"

-- Use a simple hash of the path as the filename to avoid encoding issues.
-- Collisions are effectively impossible for filesystem paths.
local function path_hash(path)
  local h = 5381
  for i = 1, #path do
    h = ((h * 33) + path:byte(i)) % 2147483647
  end
  return string.format("%010d", h)
end

local function session_file(project_path)
  return sessions_dir .. "/" .. path_hash(project_path) .. ".vim"
end

local function path_file(project_path)
  return sessions_dir .. "/" .. path_hash(project_path) .. ".path"
end

-- The currently active session path, or nil. When set, auto-saves on exit.
local active_session = nil

function M.save(project_path)
  project_path = project_path or vim.fn.getcwd()
  vim.fn.mkdir(sessions_dir, "p")
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_file(project_path)))

  -- Write the real path to a companion file
  local f = io.open(path_file(project_path), "w")
  if f then
    f:write(project_path)
    f:close()
  end

  active_session = project_path
end

function M.restore(project_path)
  local file = session_file(project_path)
  if vim.fn.filereadable(file) == 0 then return false end
  vim.cmd("silent! %bwipeout!")
  vim.cmd("source " .. vim.fn.fnameescape(file))
  active_session = project_path
  return true
end

function M.delete(project_path)
  vim.fn.delete(session_file(project_path))
  vim.fn.delete(path_file(project_path))
  if active_session == project_path then active_session = nil end
end

function M.list()
  if vim.fn.isdirectory(sessions_dir) == 0 then return {} end

  local entries = {}
  for _, name in ipairs(vim.fn.readdir(sessions_dir)) do
    if vim.endswith(name, ".path") then
      local pf = sessions_dir .. "/" .. name
      local f = io.open(pf, "r")
      if f then
        local path = f:read("*l")
        f:close()
        local sf = sessions_dir .. "/" .. name:sub(1, -6) .. ".vim"
        if path and vim.fn.filereadable(sf) == 1 then
          entries[#entries + 1] = {
            path = path,
            mtime = vim.fn.getftime(sf),
          }
        end
      end
    end
  end

  table.sort(entries, function(a, b) return a.mtime > b.mtime end)
  return entries
end

-- Auto-save on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("session-autosave", { clear = true }),
  callback = function()
    if active_session then M.save(active_session) end
  end,
})

-- Commands
vim.api.nvim_create_user_command("SessionSave", function()
  M.save()
  vim.notify("Session saved: " .. vim.fn.getcwd())
end, { desc = "Save current session" })

vim.api.nvim_create_user_command("SessionQuit", function()
  if active_session then
    M.save(active_session)
    vim.notify("Session saved: " .. active_session)
  end
  vim.cmd("qall")
end, { desc = "Save session and quit all" })

return M
