-- lua/config/autocommands/terminal.lua
local M = {}

-- Store terminal information globally
_G.terminal_state = _G.terminal_state
  or {
    terminals = {}, -- Store terminal names and bufnrs
    last_active = nil, -- Track last active terminal
  }

-- Constants
local TERMINAL_HEIGHT_RATIO = 0.33 -- Terminal takes 1/3 of window height

-- Helper function to set terminal window size
local function set_terminal_size(win_id)
  local height = math.floor(vim.o.lines * TERMINAL_HEIGHT_RATIO)
  vim.api.nvim_win_set_height(win_id or 0, height)
end

-- Function to create a new named terminal
local function create_named_terminal()
  vim.ui.input({ prompt = 'Terminal name: ' }, function(name)
    if not name or name == '' then
      vim.notify('Terminal name is required', vim.log.levels.WARN)
      return
    end

    -- Check if terminal with this name already exists
    for _, term in pairs(_G.terminal_state.terminals) do
      if term.name == name then
        vim.notify('Terminal with this name already exists', vim.log.levels.WARN)
        return
      end
    end

    -- Create new terminal in a horizontal split
    vim.cmd 'botright split'
    vim.cmd 'terminal'
    set_terminal_size() -- Set consistent size

    -- Get the buffer number of the new terminal
    local bufnr = vim.api.nvim_get_current_buf()

    -- Store terminal information
    _G.terminal_state.terminals[bufnr] = {
      name = name,
      bufnr = bufnr,
    }

    -- Set as last active terminal
    _G.terminal_state.last_active = bufnr

    -- Set buffer name
    vim.api.nvim_buf_set_name(bufnr, 'term://' .. name)

    -- Start in insert mode
    vim.cmd 'startinsert'
  end)
end

-- Function to close current terminal session
local function close_terminal_session()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Check if current buffer is a terminal and is in our terminal state
  if vim.bo[current_buf].buftype == 'terminal' and _G.terminal_state.terminals[current_buf] then
    -- Clean up terminal state
    local term_name = _G.terminal_state.terminals[current_buf].name
    _G.terminal_state.terminals[current_buf] = nil

    -- If this was the last active terminal, clear it
    if _G.terminal_state.last_active == current_buf then
      _G.terminal_state.last_active = nil
    end

    -- Close all windows containing this buffer
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winid) == current_buf then
        vim.api.nvim_win_close(winid, true)
      end
    end

    -- Force close the buffer
    vim.cmd('bdelete! ' .. current_buf)
    vim.notify('Closed terminal session: ' .. term_name, vim.log.levels.INFO)
  else
    vim.notify('Not in a terminal session', vim.log.levels.WARN)
  end
end

-- Function to toggle last active terminal
local function toggle_terminal()
  -- If we have a last active terminal
  if _G.terminal_state.last_active then
    local term = _G.terminal_state.terminals[_G.terminal_state.last_active]
    if term then
      -- Check if terminal buffer is currently visible
      local visible = false
      local term_win = nil
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == term.bufnr then
          visible = true
          term_win = winid
          break
        end
      end

      if visible and term_win then
        -- Hide the terminal
        vim.api.nvim_win_close(term_win, true)
      else
        if vim.api.nvim_buf_is_valid(term.bufnr) then
          vim.cmd 'botright split'
          vim.api.nvim_win_set_buf(0, term.bufnr)
          set_terminal_size() -- Set consistent size
          if vim.bo[term.bufnr].buftype == 'terminal' then
            vim.cmd 'startinsert'
          end
        else
          -- Clean up invalid terminal
          _G.terminal_state.terminals[term.bufnr] = nil
          _G.terminal_state.last_active = nil
          vim.notify('Terminal buffer no longer exists', vim.log.levels.WARN)
        end
      end
    end
  else
    vim.notify('No active terminal to toggle', vim.log.levels.INFO)
  end
end

-- Function to switch terminal in current window
local function switch_terminal()
  local terms = {}
  for bufnr, term in pairs(_G.terminal_state.terminals) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(terms, {
        name = term.name,
        bufnr = bufnr,
      })
    else
      -- Clean up invalid terminals
      _G.terminal_state.terminals[bufnr] = nil
    end
  end

  if #terms == 0 then
    vim.notify('No terminals found', vim.log.levels.INFO)
    return
  end

  -- Create selection list
  local items = {}
  for _, term in ipairs(terms) do
    table.insert(items, string.format('[%d] %s', term.bufnr, term.name))
  end

  vim.ui.select(items, {
    prompt = 'Select terminal to switch to:',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      local bufnr = tonumber(choice:match '%[(%d+)%]')
      if bufnr then
        _G.terminal_state.last_active = bufnr
        vim.api.nvim_win_set_buf(0, bufnr)
        vim.cmd 'startinsert'
      end
    end
  end)
end

-- Function to list and open terminals
local function list_terminals()
  local terms = {}
  for bufnr, term in pairs(_G.terminal_state.terminals) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(terms, {
        name = term.name,
        bufnr = bufnr,
      })
    else
      -- Clean up invalid terminals
      _G.terminal_state.terminals[bufnr] = nil
    end
  end

  if #terms == 0 then
    vim.notify('No terminals found', vim.log.levels.INFO)
    return
  end

  -- Create selection list
  local items = {}
  for _, term in ipairs(terms) do
    table.insert(items, string.format('[%d] %s', term.bufnr, term.name))
  end

  vim.ui.select(items, {
    prompt = 'Select terminal to open:',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      local bufnr = tonumber(choice:match '%[(%d+)%]')
      if bufnr then
        _G.terminal_state.last_active = bufnr

        -- Check if any terminal is currently visible in a horizontal split
        local term_win_found = false
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          local win_buf = vim.api.nvim_win_get_buf(winid)
          if vim.bo[win_buf].buftype == 'terminal' then
            term_win_found = true
            -- Open new terminal in vertical split to the right
            vim.cmd 'vertical belowright split'
            vim.api.nvim_win_set_buf(0, bufnr)
            break
          end
        end

        -- If no terminal window found, open in horizontal split
        if not term_win_found then
          vim.cmd 'botright split'
          vim.api.nvim_win_set_buf(0, bufnr)
          set_terminal_size()
        end

        vim.cmd 'startinsert'
      end
    end
  end)
end

function M.setup()
  -- Create augroup for terminal settings
  local terminal_group = vim.api.nvim_create_augroup('custom_terminal', { clear = true })

  -- Terminal-specific settings
  vim.api.nvim_create_autocmd('TermOpen', {
    group = terminal_group,
    callback = function(ev)
      -- Disable line numbers in terminal
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      -- Disable signcolumn in terminal
      vim.opt_local.signcolumn = 'no'

      -- Set last active terminal when entering a terminal buffer
      if _G.terminal_state.terminals[ev.buf] then
        _G.terminal_state.last_active = ev.buf
      end
    end,
  })

  -- Track terminal focus
  vim.api.nvim_create_autocmd('BufEnter', {
    group = terminal_group,
    callback = function(ev)
      if vim.bo[ev.buf].buftype == 'terminal' and _G.terminal_state.terminals[ev.buf] then
        _G.terminal_state.last_active = ev.buf
      end
    end,
  })

  -- Set up keymaps
  local opts = { noremap = true, silent = true }

  -- Terminal management keymaps
  vim.keymap.set('n', '<leader>tn', create_named_terminal, { desc = '[T]erminal: Create [N]ew named terminal' })
  vim.keymap.set('n', '<leader>tl', list_terminals, { desc = '[T]erminal: [L]ist and open' })
  vim.keymap.set('n', '<leader>tt', toggle_terminal, { desc = '[T]erminal: [T]oggle last active' })
  vim.keymap.set('n', '<leader>ts', switch_terminal, { desc = '[T]erminal: [S]witch in current window' })
  vim.keymap.set('n', '<leader>tq', close_terminal_session, { desc = '[T]erminal: [Q]uit session' })

  -- Better terminal navigation
  vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', opts)
  vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', opts)
  vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', opts)
  vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', opts)

  -- Easy terminal mode exit
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', opts)
end

return M
