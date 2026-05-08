-- make sure file detection is enabled
-- should be enabled by default, but just in case
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")


-- UI
-- -----------------------------------------------------------------------------
-- number and relative number combined = current line shows its absolute number, 
-- and other lines show their relative distance from the current line.

-- Show absolute line number for the current line.
-- Default: false
vim.opt.number = true

-- Show relative line numbers for all other lines.
-- Useful for motions like 5j and 3k.
-- Default: false
vim.opt.relativenumber = true

-- Highlight the line where the cursor is currently located.
-- Default: false
vim.opt.cursorline = true

-- Enable 24-bit RGB colors in terminals that support them.
-- Default: false
vim.opt.termguicolors = true

-- Always show the sign column so text does not shift when
-- diagnostics, git signs, or breakpoints appear.
-- Default: "auto"
vim.opt.signcolumn = "yes"


-- MOUSE & CLIPBOARD
-- -----------------------------------------------------------------------------
-- Enable mouse support in all modes.
-- Default: ""
vim.opt.mouse = "a"

-- Use the system clipboard for copy, delete, and paste operations.
-- Default: ""
vim.opt.clipboard = "unnamedplus"


-- INDENTATION
-- -----------------------------------------------------------------------------
vim.opt.tabstop = 4			-- Display width of tab characters (default: 8)
vim.opt.shiftwidth = 4		-- Width for auto indents (default: 8)
vim.opt.softtabstop = 4		-- Width for <Tab> and <Back> (default: 0)
vim.opt.expandtab = false	-- Use spaces instead of tabs (default: false)
vim.opt.autoindent = true	-- Copy indent from current line 
vim.opt.smartindent = true  -- Copy indent from code context (default: false)


-- SCROLLING & WRAPPING
-- -----------------------------------------------------------------------------
-- Disable line wrapping so long lines stay on one screen row.
-- Default: true
vim.opt.wrap = false

-- Keep at least 5 lines visible above and below the cursor while scrolling.
-- Default: 0
vim.opt.scrolloff = 5

-- Keep at least 8 columns visible to the left and right of the cursor
-- while scrolling horizontally.
-- Default: 0
vim.opt.sidescrolloff = 8


-- SEARCH
-- -----------------------------------------------------------------------------
-- Make searches case-insensitive by default.
-- Default: false
vim.opt.ignorecase = true

-- If the search pattern contains uppercase letters,
-- make the search case-sensitive.
-- Default: false
vim.opt.smartcase = true


-- WINDOW SPLITTING
-- -----------------------------------------------------------------------------
-- Open horizontal splits below the current window.
-- Default: false
vim.opt.splitbelow = true

-- Open vertical splits to the right of the current window.
-- Default: false
vim.opt.splitright = true


-- RESPONSIVENESS
-- -----------------------------------------------------------------------------
-- Reduce delay for swap writes, CursorHold, some plugin or diagnostic updates.
-- Default: 4000
vim.opt.updatetime = 250


-- RULERS
-- -----------------------------------------------------------------------------
-- Draw vertical rulers at columns 80, 100, 120, and 132.
-- Default: ""
vim.opt.colorcolumn = "80,100,120,132"


-- HIGHLIGHTS
-- -----------------------------------------------------------------------------
-- Give ruler columns a subtle dark background.
-- Default: colorscheme-defined (by your theme)

--vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a2a" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a2a", nocombine = true})


-- CURSOR
-- -----------------------------------------------------------------------------
-- Use a blinking block cursor in normal, visual, command-line,
-- insert, replace, and operator-pending modes.
-- Default: mode-dependent builtin cursor settings
vim.opt.guicursor = table.concat({
  "n-v-c:block-blinkwait700-blinkon400-blinkoff250",
  "i-ci-ve:ver100-blinkwait100-blinkon80-blinkoff80",
  "r-cr:hor25-blinkwait700-blinkon400-blinkoff250",
  "o:block-blinkwait700-blinkon400-blinkoff250",
}, ",")

-- mode-list:cursor-shape-and-blink-settings
  -- `n-v-c` = apply this rule in these modes
  -- `:` = separator
  -- `block` = use a block cursor
  -- `blinkwait700` = wait 700 ms before starting to blink
  -- `blinkon400` = stay visible for 400 ms
  -- `blinkoff250` = stay invisible for 250 ms

-- modes:
  -- `n` = Normal mode (moving around)
  -- `i` = Insert mode (typing text)
  -- `v` = Visual mode (selecting text)
  -- `r` = Replace mode (overwriting text)
  -- `c` = Command-line mode (typing `:` or `/` commands)
  -- `ci` = Command-line Insert mode
  -- `ve` = Visual Exclusive mode
  -- `cr` = Command-line Replace mode
  -- `o` = Operator-pending mode (after an operator like `d`, `c`, `y`, waiting for a motion)

-- a few other modes:
  -- `a` = all modes (shortcut for “apply everywhere”)
  -- `sm` = showmatch mode
  -- `t` = terminal-job mode (inside terminal buffers)
  -- `l` = when using `:lmap` mappings
  -- `vd` = visual mode with `'selection'` set to "exclusive"? often rarely used directly in practice

-- Common cursor shapes:
  -- `block` = full cell block
  -- `ver25` = vertical bar, 25% width
  -- `ver50` = vertical bar, 50% width
  -- `hor20` = underline, 20% height
  -- `hor50` = thicker underline, 50% height
