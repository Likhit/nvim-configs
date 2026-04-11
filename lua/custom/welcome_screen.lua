-- Welcome screen: shown when Neovim opens with no arguments
--
-- Lists existing sessions sorted by recency. Keymaps:
--   enter  - open selected session
--   n      - create new session for cwd
--   d      - delete selected session
--   q      - quit

local sessions = require("custom.sessions")
local ns = vim.api.nvim_create_namespace("welcome_screen")

local function time_ago(mtime)
  local diff = os.time() - mtime
  if diff < 60 then return "just now" end
  if diff < 3600 then return math.floor(diff / 60) .. "m ago" end
  if diff < 86400 then return math.floor(diff / 3600) .. "h ago" end
  if diff < 604800 then return math.floor(diff / 86400) .. "d ago" end
  return os.date("%Y-%m-%d", mtime)
end

-- Build the buffer content. Returns a table with lines, highlights, session data, and row range.
local function build_content()
  local session_list = sessions.list()
  local lines = {}
  local highlights = {} -- { line_0idx, col_start, col_end, hl_group }

  lines[#lines + 1] = ""
  lines[#lines + 1] = "  Neovim"
  highlights[#highlights + 1] = { #lines - 1, 2, 8, "Title" }
  lines[#lines + 1] = ""

  local first_row, last_row = 0, 0

  if #session_list > 0 then
    lines[#lines + 1] = "  Sessions:"
    highlights[#highlights + 1] = { #lines - 1, 2, 11, "Label" }
    lines[#lines + 1] = ""
    first_row = #lines + 1

    for _, entry in ipairs(session_list) do
      local age = time_ago(entry.mtime)
      local padding = math.max(1, 50 - #entry.path)
      local line = "    " .. entry.path .. string.rep(" ", padding) .. age
      lines[#lines + 1] = line
      highlights[#highlights + 1] = { #lines - 1, 4, 4 + #entry.path, "Directory" }
      highlights[#highlights + 1] = { #lines - 1, #line - #age, #line, "Comment" }
    end
    last_row = #lines
  else
    lines[#lines + 1] = "  No sessions yet."
    highlights[#highlights + 1] = { #lines - 1, 2, 20, "Comment" }
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = ""
  local footer = "  [enter] Open   [n] New session   [d] Delete   [q] Quit"
  lines[#lines + 1] = footer
  highlights[#highlights + 1] = { #lines - 1, 2, #footer, "Comment" }

  return {
    lines = lines,
    highlights = highlights,
    session_list = session_list,
    first_row = first_row,
    last_row = last_row,
  }
end

local function open_welcome_screen()
  if vim.fn.argc() > 0 then return end
  if vim.fn.exists("$GIT_EXEC_PATH") == 1 then return end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "welcome_screen"

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = true

  local state = { session_list = {}, first_row = 0, last_row = 0 }

  local function render()
    local content = build_content()
    state.session_list = content.session_list
    state.first_row = content.first_row
    state.last_row = content.last_row

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content.lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, hl in ipairs(content.highlights) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
    end

    if #state.session_list > 0 then
      vim.api.nvim_win_set_cursor(win, { state.first_row, 4 })
    end
  end

  local function selected_session()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local idx = row - state.first_row + 1
    if idx >= 1 and idx <= #state.session_list then
      return state.session_list[idx]
    end
    return nil
  end

  -- Reset window options that were overridden for the welcome screen
  -- back to global defaults, so session save/restore doesn't persist them.
  local function reset_win_opts()
    vim.wo[win].number = vim.go.number
    vim.wo[win].relativenumber = vim.go.relativenumber
    vim.wo[win].signcolumn = vim.go.signcolumn
    vim.wo[win].cursorline = vim.go.cursorline
  end

  local function open_session()
    local entry = selected_session()
    if not entry then return end
    reset_win_opts()
    -- restore() wipes all buffers (including this one) then sources the session
    sessions.restore(entry.path)
  end

  local function new_session()
    local cwd = vim.fn.getcwd()
    vim.ui.input({ prompt = "Project directory: ", default = cwd }, function(path)
      if not path or path == "" then return end
      path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
      reset_win_opts()
      -- Wipe welcome buffer, cd, and save an initial session
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.cmd.cd(path)
      sessions.save(path)
      vim.notify("Session created: " .. path)
    end)
  end

  local function delete_session()
    local entry = selected_session()
    if not entry then return end
    vim.ui.input({ prompt = "Delete session for " .. entry.path .. "? (y/N): " }, function(input)
      if input and input:lower() == "y" then
        sessions.delete(entry.path)
        vim.notify("Deleted session: " .. entry.path)
        render()
      end
    end)
  end

  render()

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", open_session, opts)
  vim.keymap.set("n", "n", new_session, opts)
  vim.keymap.set("n", "d", delete_session, opts)
  vim.keymap.set("n", "q", "<cmd>quit<CR>", opts)

  local clamping = false
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      if clamping then return end
      clamping = true
      if #state.session_list == 0 then
        vim.api.nvim_win_set_cursor(win, { 4, 0 })
      else
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local target = math.max(state.first_row, math.min(row, state.last_row))
        vim.api.nvim_win_set_cursor(win, { target, 4 })
      end
      clamping = false
    end,
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("welcome-screen", { clear = true }),
  callback = function()
    vim.schedule(open_welcome_screen)
  end,
})
