# TreeSitter in Neovim — Tutorial

## What is TreeSitter?

TreeSitter is a parser that builds a syntax tree of your code in real time.
Unlike regex-based syntax highlighting (which pattern-matches text), TreeSitter
actually understands the structure of your code — it knows what's a function,
what's a variable, what's a string, and how they relate to each other.

This enables:

- Accurate, context-aware syntax highlighting
- Code folding based on actual code structure
- Navigating by code structure (jump between functions, classes, etc.)
- Selecting code by structure (select a whole function, an argument, etc.)
- Smart indentation
- Custom queries and analysis

Our config currently only enables syntax highlighting. This tutorial teaches
you everything else so you can enable features as you learn them.

---

## Part 1: Syntax Highlighting (Beginner)

### What's different about TreeSitter highlighting?

Traditional Vim highlighting uses regex patterns. This means:

- It can be fooled by strings that look like keywords
- It can't tell if a word is a function name vs a variable
- It breaks on complex or nested syntax

TreeSitter parses the actual grammar, so it always knows the context.

### Seeing the difference

Open any code file (`.lua`, `.py`, `.js`, `.c`, etc.). TreeSitter highlighting
is already active.

To see the difference, temporarily disable it:

```vim
:lua vim.treesitter.stop()
```

Notice how the highlighting changes — it falls back to regex-based syntax.
Some things may look different or less accurate. Re-enable:

```vim
:lua vim.treesitter.start()
```

### Which languages have highlighting?

Our config installs parsers for: Lua, Python, C, C++, JavaScript, TypeScript,
TSX, HTML, CSS, Nix, JSON, YAML, Bash, and Markdown.

To check if a parser is available for the current file:

```vim
:lua print(pcall(vim.treesitter.language.add, vim.bo.filetype))
```

`true` means the parser is installed. `false` means it's not — the file will
use regex highlighting instead.

---

## Part 2: Inspecting the Syntax Tree (Beginner)

Understanding the syntax tree is key to using TreeSitter effectively.

### InspectTree

```vim
:InspectTree
```

This opens a split showing the syntax tree of your code. Move your cursor
in the code window and watch the corresponding node highlight in the tree.

Try it:
1. Open `lua/plugins/treesitter.lua`
2. Run `:InspectTree`
3. Place your cursor on the word `vim` — the tree shows it's an `identifier`
4. Move to a string — it shows `string` or `string_content`
5. Move to `function` — it shows `function_declaration` or similar
6. Press `q` to close

### Inspect

```vim
:Inspect
```

This shows details about the cursor position:
- Which highlight groups are applied (what makes it that color)
- The treesitter node type
- Which query matched it

Try placing your cursor on different elements — keywords, strings, function
names, comments — and running `:Inspect` each time.

### Getting node info programmatically

```vim
" Print the node type under cursor
:lua print(vim.treesitter.get_node():type())

" Print the node's text content
:lua print(vim.treesitter.get_node_text(vim.treesitter.get_node(), 0))

" Print the node's range (start_row, start_col, end_row, end_col)
:lua print(vim.treesitter.get_node():range())

" Print the parent node's type
:lua print(vim.treesitter.get_node():parent():type())
```

### Exercise 1: Explore the tree

1. Create a file `tutorials/treesitter/example.py`:

```python
class Animal:
    def __init__(self, name, sound):
        self.name = name
        self.sound = sound

    def speak(self):
        return f"{self.name} says {self.sound}!"

def greet(animal):
    message = animal.speak()
    print(message)

cat = Animal("Cat", "meow")
greet(cat)
```

2. Open it and run `:InspectTree`
3. Identify the node types for:
   - The class definition
   - A method/function definition
   - A parameter
   - A string
   - An f-string
   - A function call
   - A variable assignment

---

## Part 3: Code Folding (Beginner/Intermediate)

TreeSitter can fold code by structure — functions, classes, blocks — rather
than by indentation level.

### Enabling folding

Folding is not enabled in our config by default. To try it in the current
buffer:

```vim
:set foldmethod=expr
:set foldexpr=v:lua.vim.treesitter.foldexpr()
:set foldlevel=99
```

The `foldlevel=99` starts with all folds open.

### Fold commands

| Command | Action |
|---------|--------|
| `za`    | Toggle fold under cursor |
| `zc`    | Close fold under cursor |
| `zo`    | Open fold under cursor |
| `zR`    | Open ALL folds in file |
| `zM`    | Close ALL folds in file |
| `zm`    | Fold one more level (close more) |
| `zr`    | Fold one less level (open more) |
| `zj`    | Move to next fold |
| `zk`    | Move to previous fold |
| `[z`    | Move to start of current fold |
| `]z`    | Move to end of current fold |

### Exercise 2: Folding workflow

1. Open the Python example from Exercise 1
2. Enable folding with the commands above
3. Press `zM` — everything collapses to top-level definitions
4. You should see the class and the standalone function as single lines
5. Press `zo` on the class to open it — methods appear
6. Press `za` on a method to toggle it
7. Press `zR` to open everything

### Exercise 3: Practical folding

1. Open a large file (e.g., `Goal.md` or any source file)
2. Enable folding
3. `zM` to collapse, get a birds-eye view
4. Navigate to the section you want with `zj`/`zk`
5. `zo` to open just that section
6. Work on it, then `zM` again when done

### Making folding permanent

If you like folding, you can enable it in `lua/plugins/treesitter.lua` by
adding these lines inside the autocmd callback, after `vim.treesitter.start()`:

```lua
local winid = vim.fn.bufwinid(ev.buf)
if winid ~= -1 then
  vim.wo[winid].foldmethod = "expr"
  vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo[winid].foldlevel = 99
end
```

---

## Part 4: Navigating by Code Structure (Intermediate)

### Built-in navigation

Even without plugins, you can navigate code structure using treesitter:

```vim
" Jump to the root of the syntax tree
:lua vim.api.nvim_win_set_cursor(0, {vim.treesitter.get_parser():parse()[1]:root():range() + 1, 0})
```

That's awkward though. For practical navigation, we have two options:
the `nvim-treesitter-textobjects` plugin (commented out in our config),
or Neovim's built-in defaults.

### Built-in Neovim 0.11 navigation (no plugins needed)

These work out of the box with LSP (covered in a later phase):

| Key    | Action |
|--------|--------|
| `]d`   | Next diagnostic (error/warning) |
| `[d`   | Previous diagnostic |
| `gd`   | Go to definition |
| `grr`  | Go to references |
| `gra`  | Code actions |
| `grn`  | Rename symbol |
| `gO`   | Document outline (symbols list) |

### Enabling treesitter-based navigation

To enable structured code navigation with treesitter text objects, uncomment
`nvim-treesitter-textobjects` in `nix/plugins.nix`, run `direnv reload`, then
add configuration to `lua/plugins/treesitter.lua`. See Part 7 for details.

---

## Part 5: Understanding Queries (Intermediate)

Queries are the bridge between the syntax tree and Neovim features.
They're patterns written in S-expression syntax that match nodes in the tree.

### Query syntax basics

A query looks like this:

```scheme
; Match any function definition, capture it as @function
(function_definition) @function

; Match a function definition and capture its name
(function_definition
  name: (identifier) @function.name)

; Match a string node
(string) @string

; Match an if statement's condition
(if_statement
  condition: (_) @condition)
```

The `@name` parts are "captures" — they label the matched nodes so Neovim
can do something with them (highlight them, make them selectable, etc.).

### How highlighting queries work

Open a highlight query file to see how colors are defined:

```vim
:lua print(vim.api.nvim_get_runtime_file("queries/lua/highlights.scm", false)[1])
```

Then open that file. You'll see patterns like:

```scheme
(identifier) @variable
(function_call name: (identifier) @function.call)
"return" @keyword.return
(string) @string
(comment) @comment
```

Each `@capture_name` maps to a highlight group, which maps to a color in
your colorscheme.

### EditQuery — interactive query testing

```vim
:EditQuery
```

This opens a scratch buffer where you can write queries and see matches
highlighted in real time in the source buffer.

### Exercise 4: Write your first query

1. Open the Python example file
2. Run `:EditQuery`
3. In the query buffer, type: `(function_definition) @highlight`
4. All function definitions should highlight in the source
5. Try: `(identifier) @highlight` — all identifiers light up
6. Try: `(string) @highlight` — all strings light up
7. Try: `(class_definition name: (identifier) @highlight)` — just class names
8. Try: `(call function: (identifier) @highlight)` — just function calls

### Exercise 5: Explore query predicates

Queries support predicates for more precise matching:

```scheme
; Match identifiers that equal "self"
((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))

; Match identifiers matching a pattern
((identifier) @constant
  (#match? @constant "^[A-Z_]+$"))

; Match comments containing TODO
((comment) @comment.todo
  (#match? @comment.todo "TODO"))
```

Try these in `:EditQuery` with the Python example.

---

## Part 6: Text Objects and Selection (Intermediate/Advanced)

Text objects let you operate on code structures. In Vim, you already know
text objects like `iw` (inner word), `i"` (inner quotes), `ip` (inner
paragraph). TreeSitter adds structural text objects.

### What are treesitter text objects?

With the `nvim-treesitter-textobjects` plugin, you can do things like:

| Command | Action |
|---------|--------|
| `vaf`   | **V**isually select **a** **f**unction (including signature) |
| `vif`   | **V**isually select **i**nner **f**unction (body only) |
| `vac`   | Select a class |
| `vic`   | Select inner class |
| `vaa`   | Select an argument/parameter |
| `via`   | Select inner argument |
| `vai`   | Select a conditional (if/else) |
| `val`   | Select a loop |
| `daf`   | **D**elete a function |
| `cif`   | **C**hange inner function (delete body, enter insert mode) |
| `yaf`   | **Y**ank (copy) a function |

These combine with any Vim operator (`d`, `c`, `y`, `>`, `<`, etc.).

### How text objects work

Text objects are defined by query files (`textobjects.scm`). For Python,
the queries define what counts as a "function", "class", "parameter", etc.

The `outer` variant includes the whole construct (e.g., `def` line + body).
The `inner` variant includes only the body.

### Exercise 6: Text objects (requires enabling the plugin)

1. Uncomment `nvim-treesitter-textobjects` in `nix/plugins.nix`
2. Run `direnv reload`
3. Add text object configuration to `lua/plugins/treesitter.lua` (see Part 7)
4. Open the Python example
5. Place cursor inside the `speak` method
6. Try `vaf` — the entire method should be selected
7. Press `Esc`, try `vif` — just the body is selected
8. Try `vac` on anything inside the class — the whole class is selected
9. Try `daf` to delete a function, then `u` to undo

---

## Part 7: Enabling Advanced Features (Advanced)

This section provides the configuration to add to `lua/plugins/treesitter.lua`
when you're ready for each feature.

### Folding

Add inside the autocmd callback, after `vim.treesitter.start()`:

```lua
local winid = vim.fn.bufwinid(ev.buf)
if winid ~= -1 then
  vim.wo[winid].foldmethod = "expr"
  vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo[winid].foldlevel = 99
end
```

### Text object moves

Uncomment `nvim-treesitter-textobjects` in `nix/plugins.nix`, run
`direnv reload`, then add to `lua/plugins/treesitter.lua`:

```lua
local ts_ok, ts_textobjects = pcall(require, "nvim-treesitter-textobjects")
if not ts_ok then
  return
end

ts_textobjects.setup({
  move = { set_jumps = true },
})

local move = require("nvim-treesitter-textobjects.move")

local move_maps = {
  { "]f", move.goto_next_start, "@function.outer", "Next function start" },
  { "]c", move.goto_next_start, "@class.outer", "Next class start" },
  { "]a", move.goto_next_start, "@parameter.outer", "Next argument start" },
  { "]F", move.goto_next_end, "@function.outer", "Next function end" },
  { "]C", move.goto_next_end, "@class.outer", "Next class end" },
  { "[f", move.goto_previous_start, "@function.outer", "Prev function start" },
  { "[c", move.goto_previous_start, "@class.outer", "Prev class start" },
  { "[a", move.goto_previous_start, "@parameter.outer", "Prev argument start" },
  { "[F", move.goto_previous_end, "@function.outer", "Prev function end" },
  { "[C", move.goto_previous_end, "@class.outer", "Prev class end" },
}

for _, m in ipairs(move_maps) do
  vim.keymap.set({ "n", "x", "o" }, m[1], function()
    m[2](m[3], "textobjects")
  end, { desc = m[4] })
end
```

### Text object selection

Add after the move maps:

```lua
local select_fn = require("nvim-treesitter-textobjects.select").select_textobject

ts_textobjects.setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

local select_maps = {
  ["af"] = { "@function.outer", "Select outer function" },
  ["if"] = { "@function.inner", "Select inner function" },
  ["ac"] = { "@class.outer", "Select outer class" },
  ["ic"] = { "@class.inner", "Select inner class" },
  ["aa"] = { "@parameter.outer", "Select outer argument" },
  ["ia"] = { "@parameter.inner", "Select inner argument" },
  ["ai"] = { "@conditional.outer", "Select outer conditional" },
  ["ii"] = { "@conditional.inner", "Select inner conditional" },
  ["al"] = { "@loop.outer", "Select outer loop" },
  ["il"] = { "@loop.inner", "Select inner loop" },
  ["ab"] = { "@block.outer", "Select outer block" },
  ["ib"] = { "@block.inner", "Select inner block" },
  ["a/"] = { "@comment.outer", "Select outer comment" },
}

for key, mapping in pairs(select_maps) do
  vim.keymap.set({ "x", "o" }, key, function()
    select_fn(mapping[1], "textobjects")
  end, { desc = mapping[2] })
end
```

### Swap arguments

Add after text objects:

```lua
local swap = require("nvim-treesitter-textobjects.swap")

vim.keymap.set("n", "<leader>sa", function()
  swap.swap_next("@parameter.inner")
end, { desc = "Swap argument with next" })

vim.keymap.set("n", "<leader>sA", function()
  swap.swap_previous("@parameter.inner")
end, { desc = "Swap argument with previous" })
```

### Repeatable moves

Makes `;` and `,` repeat the last textobject move (and also makes built-in
`f`/`F`/`t`/`T` repeatable):

```lua
local ts_repeat_ok, ts_repeat = pcall(require, "nvim-treesitter-textobjects.repeatable_move")
if ts_repeat_ok then
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)
  vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true })
end
```

### Incremental selection

This is not part of any plugin — it uses Neovim's built-in treesitter API.
Pressing a key expands the selection to the next parent node in the syntax
tree.

```lua
local selection_stack = {}

local function select_node(node)
  if not node then return end
  local sr, sc, er, ec = node:range()
  vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
  vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
  vim.cmd("normal! gv")
end

local function init_selection()
  selection_stack = {}
  local node = vim.treesitter.get_node()
  if node then
    table.insert(selection_stack, node)
    select_node(node)
  end
end

local function node_incremental()
  local node
  if #selection_stack > 0 then
    node = selection_stack[#selection_stack]:parent()
  else
    node = vim.treesitter.get_node()
  end
  if node then
    table.insert(selection_stack, node)
    select_node(node)
  end
end

local function node_decremental()
  if #selection_stack > 1 then
    table.remove(selection_stack)
    select_node(selection_stack[#selection_stack])
  end
end

-- Choose keybindings that don't conflict with common mappings
vim.keymap.set("n", "<leader>v", init_selection, { desc = "Init treesitter selection" })
vim.keymap.set("x", "<C-k>", node_incremental, { desc = "Expand selection" })
vim.keymap.set("x", "<C-j>", node_decremental, { desc = "Shrink selection" })
```

---

## Part 8: Writing Custom Queries (Advanced)

### Query file structure

Queries live in `queries/<language>/<type>.scm` on the runtimepath. You can
add your own by creating these files in your Neovim config directory.

For example, to add a custom highlight for Python TODOs:

1. Create `queries/python/highlights.scm` in your config
2. Add: `((comment) @comment.todo (#match? @comment.todo "TODO"))`
3. The query extends (not replaces) the built-in queries

### Useful query patterns

**Match a specific node type:**
```scheme
(function_definition) @function
```

**Match with a named child:**
```scheme
(function_definition
  name: (identifier) @function.name
  body: (block) @function.body)
```

**Match any child (wildcard):**
```scheme
(function_definition
  name: (_) @function.name)
```

**Match with predicates:**
```scheme
; Only match if the text equals something
((identifier) @builtin (#eq? @builtin "self"))

; Only match if the text matches a regex
((identifier) @constant (#match? @constant "^[A-Z][A-Z_]*$"))

; Only match if NOT equal
((identifier) @variable (#not-eq? @variable "self"))
```

**Match alternatives:**
```scheme
[
  (function_definition)
  (class_definition)
] @definition
```

**Match strings with specific content:**
```scheme
((string_content) @uri (#match? @uri "^https?://"))
```

### Exercise 7: Custom highlighting

1. Open `:EditQuery` with a Python file
2. Try highlighting all function calls:
   `(call function: (identifier) @highlight)`
3. Try highlighting all string interpolations in f-strings:
   `(interpolation) @highlight`
4. Try highlighting all assignments:
   `(assignment left: (_) @highlight)`
5. Try highlighting all return statements:
   `(return_statement) @highlight`

### Exercise 8: Cross-language comparison

1. Open a Lua file and run `:InspectTree`
2. Note the node types for functions: `function_declaration`, `function_definition`
3. Open a Python file and compare: `function_definition`
4. Open a JavaScript file and compare: `function_declaration`, `arrow_function`
5. Run `:EditQuery` in each and try `(function_definition) @highlight`
6. Notice how the same query concept (functions) uses different node types

---

## Part 9: Programmatic TreeSitter API (Advanced)

### Getting the parser

```lua
-- Get parser for current buffer
local parser = vim.treesitter.get_parser()

-- Get the language
print(parser:lang())  -- "lua", "python", etc.

-- Parse and get the tree
local tree = parser:parse()[1]
local root = tree:root()
```

### Walking the tree

```lua
-- Iterate over root's children
for child in root:iter_children() do
  print(child:type(), child:range())
end

-- Get named children only (skips punctuation/whitespace nodes)
for i = 0, root:named_child_count() - 1 do
  local child = root:named_child(i)
  print(child:type())
end
```

### Running queries from Lua

```lua
-- Parse a query
local query = vim.treesitter.query.parse("python", [[
  (function_definition
    name: (identifier) @name)
]])

-- Run it on the tree
local root = vim.treesitter.get_parser():parse()[1]:root()
for id, node, metadata in query:iter_captures(root, 0) do
  local name = query.captures[id]
  local text = vim.treesitter.get_node_text(node, 0)
  print(name, text)
end
```

### Exercise 9: Build a function lister

Run this in Neovim's command line with a Python file open:

```vim
:lua for id, node in require("vim.treesitter.query").parse("python", "(function_definition name: (identifier) @name)"):iter_captures(vim.treesitter.get_parser():parse()[1]:root(), 0) do print(vim.treesitter.get_node_text(node, 0)) end
```

This prints all function names in the current file. This is the foundation
of features like document outline, symbol search, and code navigation.

### Exercise 10: Explore the API

Try these in `:lua` commands:

```lua
-- Count nodes in the tree
local function count_nodes(node)
  local c = 1
  for child in node:iter_children() do
    c = c + count_nodes(child)
  end
  return c
end
print(count_nodes(vim.treesitter.get_parser():parse()[1]:root()))

-- Find the deepest node at cursor
local node = vim.treesitter.get_node()
print("Type:", node:type())
print("Depth:", (function()
  local d, n = 0, node
  while n:parent() do d = d + 1; n = n:parent() end
  return d
end)())

-- Print the tree path from cursor to root
local n = vim.treesitter.get_node()
local path = {}
while n do
  table.insert(path, 1, n:type())
  n = n:parent()
end
print(table.concat(path, " > "))
```

---

## Quick Reference

### Commands

| Command | What it does |
|---------|-------------|
| `:InspectTree` | Show syntax tree in a split |
| `:Inspect` | Show highlight/node info at cursor |
| `:EditQuery` | Interactively write and test queries |
| `:lua vim.treesitter.start()` | Enable TS highlighting for current buffer |
| `:lua vim.treesitter.stop()` | Disable TS highlighting for current buffer |

### Lua API

| Function | What it does |
|----------|-------------|
| `vim.treesitter.get_node()` | Get node at cursor |
| `vim.treesitter.get_node_text(node, bufnr)` | Get text of a node |
| `vim.treesitter.get_parser()` | Get parser for current buffer |
| `vim.treesitter.start(bufnr, lang)` | Enable highlighting |
| `vim.treesitter.stop(bufnr)` | Disable highlighting |
| `vim.treesitter.foldexpr()` | Fold expression function |
| `vim.treesitter.language.get_lang(ft)` | Get TS language for filetype |
| `vim.treesitter.language.add(lang)` | Load a parser |
| `vim.treesitter.query.parse(lang, query)` | Parse a query string |
| `vim.treesitter.query.get(lang, type)` | Get a named query file |

### Node methods

| Method | What it does |
|--------|-------------|
| `node:type()` | Node type name |
| `node:range()` | Start/end row/col |
| `node:parent()` | Parent node |
| `node:iter_children()` | Iterate child nodes |
| `node:named_child_count()` | Count named children |
| `node:named_child(i)` | Get named child by index |
| `node:field(name)` | Get children by field name |
