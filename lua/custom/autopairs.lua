-- Autopairs: auto-close brackets and quotes
--
-- Typing an opener inserts the closer and places the cursor between them.
-- No skip-over, no context detection — just simple auto-close.

local pairs = {
  { "(", ")" },
  { "[", "]" },
  { "{", "}" },
  { '"', '"' },
  { "'", "'" },
  { "`", "`" },
}

for _, pair in ipairs(pairs) do
  vim.keymap.set("i", pair[1], pair[1] .. pair[2] .. "<Left>", {
    noremap = true,
    desc = "Auto-close " .. pair[1] .. pair[2] .. " #autopairs #editing",
  })
end
