-- lua/config/autocommands/terminal.lua
--[[
Terminal Management Module

This module provides a streamlined terminal management system for Neovim with smart
window arrangement. It supports:
- Named terminals that persist across sessions
- Intelligent window layouts (horizontal/vertical splits)
- Easy terminal toggling and switching
- Simple terminal creation and destruction

Window Layout Strategy:
1. First terminal: Opens in a horizontal split at the bottom
2. Second terminal: Opens in a vertical split next to the first
3. Additional terminals: Open in horizontal splits below

Usage:
- <leader>tn - Create new named terminal
- <leader>tt - Toggle last used terminal
- <leader>tl - List and select from available terminals
- <leader>tq - Close current terminal
]]

local M = {}

-- Global state for terminal management
-- We use _G to persist the state across module reloads
_G.term_state = _G.term_state
  or {
    -- Map of terminal names to their buffer numbers
    terminals = {},
    -- Name of the last used terminal for quick toggling
    last_used = nil,
    -- Controls the height of horizontal terminal splits
    height_ratio = 0.3, -- 30% of window height
  }

---Sets the height of a terminal window based on the configured ratio
---@param win_id number? Window ID to resize (defaults to current window)
local function set_terminal_size(win_id)
  local height = math.floor(vim.o.lines * _G.term_state.height_ratio)
  vim.api.nvim_win_set_height(win_id or 0, height)
end

---Creates a new named terminal with smart window arrangement
local function create_terminal()
  vim.ui.input({ prompt = 'Terminal name: ' }, function(name)
    -- Input validation
    if not name or name == '' then
      vim.notify('Terminal name is required', vim.log.levels.WARN)
      return
    end

    -- Check for duplicate names
    if _G.term_state.terminals[name] then
      vim.notify('Terminal with this name already exists', vim.log.levels.WARN)
      return
    end

    -- Find existing terminal windows to determine layout
    local term_wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == 'terminal' then
        table.insert(term_wins, win)
      end
    end

    -- Create split based on existing terminal windows
    if #term_wins == 0 then
      -- First terminal: horizontal split at bottom
      vim.cmd 'botright split | terminal'
    elseif #term_wins == 1 then
      -- Second terminal: vertical split to the right
      vim.cmd 'vertical belowright split | terminal'
    else
      -- Additional terminals: horizontal split at bottom
      vim.cmd 'botright split | terminal'
    end

    -- Set consistent height for horizontal splits
    if #term_wins ~= 1 then
      set_terminal_size()
    end

    -- Store terminal information
    local bufnr = vim.api.nvim_get_current_buf()
    _G.term_state.terminals[name] = bufnr
    _G.term_state.last_used = name

    -- Configure terminal buffer
    vim.api.nvim_buf_set_name(bufnr, 'term://' .. name)
    vim.cmd 'startinsert'
  end)
end

---Toggles visibility of a terminal by name
---@param name string? Terminal name (uses last_used if nil)
local function toggle_terminal(name)
  -- Default to last used terminal if no name provided
  name = name or _G.term_state.last_used
  if not name then
    vim.notify('No terminal to toggle', vim.log.levels.INFO)
    return
  end

  -- Validate terminal existence
  local bufnr = _G.term_state.terminals[name]
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    _G.term_state.terminals[name] = nil
    vim.notify('Terminal no longer exists', vim.log.levels.WARN)
    return
  end

  -- Find if terminal is visible in any window
  local term_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      term_win = win
      break
    end
  end

  if term_win then
    -- Hide terminal if visible
    vim.api.nvim_win_close(term_win, true)
  else
    -- Show terminal using smart window arrangement
    local visible_terms = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == 'terminal' then
        table.insert(visible_terms, {
          win = win,
          buf = buf,
        })
      end
    end

    -- When showing the terminal, follow the same rules as creation:
    -- 1. If no terminals visible: horizontal split at bottom
    -- 2. If one terminal visible: vertical split next to it
    -- 3. If multiple terminals: horizontal split at bottom
    if #visible_terms == 0 then
      -- First terminal goes in a bottom horizontal split
      vim.cmd 'botright split'
      vim.api.nvim_win_set_buf(0, bufnr)
      set_terminal_size()
    elseif #visible_terms == 1 then
      -- Second terminal goes in a vertical split
      vim.cmd 'vertical belowright split'
      vim.api.nvim_win_set_buf(0, bufnr)
      -- No need to set size for vertical splits
    else
      -- Additional terminals go in horizontal splits
      vim.cmd 'botright split'
      vim.api.nvim_win_set_buf(0, bufnr)
      set_terminal_size()
    end

    vim.cmd 'startinsert'
  end

  _G.term_state.last_used = name
end

---Shows a minimal fzf selector for terminals
local function list_terminals()
  -- Collect valid terminals and clean up invalid ones
  local terms = {}
  for name, bufnr in pairs(_G.term_state.terminals) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(terms, name)
    else
      _G.term_state.terminals[name] = nil
    end
  end

  if #terms == 0 then
    vim.notify('No terminals found', vim.log.levels.INFO)
    return
  end

  -- Create minimal fzf-lua window for terminal selection
  require('fzf-lua').fzf_exec(terms, {
    prompt = 'Terminals> ',
    winopts = {
      -- Create a small window in the center
      height = 0.2,
      title = false,
      border = 'single',
    },
    actions = {
      ['default'] = function(selected)
        -- Toggle the selected terminal
        if selected and selected[1] then
          toggle_terminal(selected[1])
        end
      end,
    },
  })
end

---Closes the current terminal and cleans up its state
local function close_terminal()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Find terminal name by buffer number
  local term_name
  for name, bufnr in pairs(_G.term_state.terminals) do
    if bufnr == current_buf then
      term_name = name
      break
    end
  end

  if term_name then
    -- Clean up terminal state
    _G.term_state.terminals[term_name] = nil
    if _G.term_state.last_used == term_name then
      _G.term_state.last_used = nil
    end
    -- Force close the buffer
    vim.cmd('bdelete! ' .. current_buf)
    vim.notify('Closed terminal: ' .. term_name)
  else
    vim.notify('Not in a terminal buffer', vim.log.levels.WARN)
  end
end

---Sets up terminal management functionality
function M.setup()
  -- Create autogroup for terminal settings
  local term_group = vim.api.nvim_create_augroup('custom_terminal', { clear = true })

  -- Configure terminal buffer settings
  vim.api.nvim_create_autocmd('TermOpen', {
    group = term_group,
    callback = function()
      -- Terminals don't need line numbers or sign column
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = 'no'
    end,
  })

  -- Set up keymaps
  local opts = { noremap = true, silent = true }

  -- Terminal management commands
  vim.keymap.set('n', '<leader>tn', create_terminal, { desc = '[T]erminal: [N]ew' })
  vim.keymap.set('n', '<leader>tt', function()
    toggle_terminal()
  end, { desc = '[T]erminal: [T]oggle last used' })
  vim.keymap.set('n', '<leader>tl', list_terminals, { desc = '[T]erminal: [L]ist and select' })
  vim.keymap.set('n', '<leader>tq', close_terminal, { desc = '[T]erminal: [Q]uit current' })

  -- Terminal navigation (when in terminal mode)
  vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', opts)
  vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', opts)
  vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', opts)
  vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', opts)
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', opts)
end

return M
