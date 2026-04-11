-- Git signs configuration
require("gitsigns").setup({
  signs = {
    add          = { text = "▎" },
    change       = { text = "▎" },
    delete       = { text = "▁" },
    topdelete    = { text = "▔" },
    changedelete = { text = "▎" },
  },

  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", gs.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>hd", gs.diffthis, "Diff this file")

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "inner hunk")
  end,
})
