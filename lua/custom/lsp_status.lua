-- LSP status tracking with health checks
--
-- Tracks the lifecycle of LSP clients: starting -> loading -> ok -> unresponsive.
-- Periodically pings servers to detect stuck/unresponsive states.
-- Provides :LspReload to restart stuck clients.
--
-- Usage:
--   local lsp_status = require("custom.lsp_status")
--   lsp_status.get(bufnr)  -- returns { state, message } or nil

local M = {}

-- States
local STARTING     = "starting"      -- client attached, waiting for progress
local LOADING      = "loading"       -- server attached, indexing/working
local OK           = "ok"            -- server ready
local UNRESPONSIVE = "unresponsive"  -- server not responding to pings
local ERROR        = "error"         -- server failed to attach

-- Per-client state: client_id -> { state = string, message = string|nil }
local client_state = {}

-- Tracks which buffers have ever had an LSP client, so we can distinguish
-- "no LSP configured" (nil) from "LSP was here but crashed" (error).
local buf_had_lsp = {}

-- Resolve the aggregate status for a buffer by checking all attached clients.
-- Returns { state, message } or nil if no LSP has ever attached to this buffer.
-- Priority: loading > starting > unresponsive > error > ok
function M.get(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  -- No clients and no record of any attachment — not an LSP buffer
  if #clients == 0 then
    -- A client attached before but is now gone (detached/crashed)
    if buf_had_lsp[bufnr] then
      return { state = ERROR, message = "no server" }
    end
    return nil
  end

  local worst = { state = OK }
  for _, client in ipairs(clients) do
    local cs = client_state[client.id]
    if not cs then goto continue end
    if cs.state == LOADING or cs.state == STARTING then
      return cs
    elseif cs.state == UNRESPONSIVE and worst.state == OK then
      worst = cs
    elseif cs.state == ERROR and worst.state == OK then
      worst = cs
    end
    ::continue::
  end
  return worst
end

-- Health check: ping LSP clients to detect unresponsive servers
local PING_INTERVAL_OK      = 60000  -- 1 min when healthy
local PING_INTERVAL_UNHEALTHY = 15000  -- 15s otherwise
local PING_TIMEOUT           = 5000   -- 5s to respond

local ping_timer = vim.uv.new_timer()

local function ping_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in ipairs(clients) do
    local cs = client_state[client.id]
    if not cs or (cs.state ~= OK and cs.state ~= LOADING and cs.state ~= UNRESPONSIVE) then
      goto continue
    end

    local ok, req_id = client.request("textDocument/hover", {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      position = { line = 0, character = 0 },
    }, function()
      if client_state[client.id] and client_state[client.id].state == UNRESPONSIVE then
        client_state[client.id] = { state = OK }
        vim.cmd.redrawstatus()
      end
    end, bufnr)

    if ok and req_id then
      vim.defer_fn(function()
        if client.requests and client.requests[req_id]
          and client.requests[req_id].type == "pending" then
          client_state[client.id] = { state = UNRESPONSIVE }
          client.cancel_request(req_id)
          vim.cmd.redrawstatus()
        end
      end, PING_TIMEOUT)
    end
    ::continue::
  end

  -- Schedule next ping
  local status = M.get(bufnr)
  local interval = (status and status.state == OK) and PING_INTERVAL_OK or PING_INTERVAL_UNHEALTHY
  ping_timer:stop()
  ping_timer:start(interval, 0, vim.schedule_wrap(ping_clients))
end

local function start_pinging()
  ping_timer:stop()
  ping_timer:start(PING_INTERVAL_UNHEALTHY, 0, vim.schedule_wrap(ping_clients))
end

-- Autocmds
local augroup = vim.api.nvim_create_augroup("lsp-status", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    buf_had_lsp[ev.buf] = true
    client_state[ev.data.client_id] = client_state[ev.data.client_id] or { state = STARTING }
    start_pinging()
    vim.cmd.redrawstatus()
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  group = augroup,
  callback = function(ev)
    local val = ev.data.params and ev.data.params.value
    if not val then return end

    local client_id = ev.data.client_id
    if val.kind == "end" then
      -- Check for remaining in-progress work
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        for _, item in ipairs(client.progress:peek() or {}) do
          if item and item.value and item.value.kind ~= "end" then
            vim.cmd.redrawstatus()
            return
          end
        end
      end
      client_state[client_id] = { state = OK }
    else
      client_state[client_id] = { state = LOADING, message = val.title or val.message or "loading" }
    end
    vim.cmd.redrawstatus()
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = augroup,
  callback = function(ev)
    client_state[ev.data.client_id] = nil
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.cmd.redrawstatus()
      end
    end, 100)
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup,
  callback = function(ev) buf_had_lsp[ev.buf] = nil end,
})

-- :LspReload command
vim.api.nvim_create_user_command("LspReload", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.WARN)
    return
  end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
    client_state[client.id] = nil
    client:stop()
  end
  vim.defer_fn(function()
    vim.cmd.edit()
    vim.notify("LSP reloaded: " .. table.concat(names, ", "))
  end, 500)
end, { desc = "Stop and restart LSP clients for the current buffer" })

return M
