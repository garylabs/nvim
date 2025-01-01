require 'config.options'
require('config.autocommands.general').setup()
require('config.autocommands.terminal').setup()
require 'config.lazy'

-- Function to open URL in Chrome without losing focus
local function OpenURLInBackground(url)
  -- Use AppleScript to open the URL in Firefox without stealing focus
  local script = string.format(
    [[
    tell application "Firefox"
      open location "%s"
    end tell
  ]],
    url
  )

  -- Execute the AppleScript
  local result = vim.fn.system { 'osascript', '-e', script }

  -- Check if the command succeeded
  if vim.v.shell_error ~= 0 then
    print 'Failed to open URL. Ensure Firefox is installed and accessible.'
  end
end
-- Keymap for opening URL
vim.keymap.set({ 'n', 'v' }, '<M-o>', function()
  local url

  -- Check if in visual mode
  if vim.fn.mode():match '[vV]' then
    -- Get selected text
    vim.cmd 'normal! y'
    url = vim.fn.getreg '"'
  else
    -- Get URL under cursor
    url = vim.fn.expand '<cfile>'
  end

  -- Validate and open URL
  if url and url:match '^https?://' then
    OpenURLInBackground(url)
    print('Opened in background: ' .. url)
  else
    print('Not a valid URL: ' .. (url or 'nil'))
  end
end, { desc = 'Open URL in background with Chrome' })

-- Map Alt-y to copy to the system clipboard in visual mode
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy to clipboard' })

-- Window/Split navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete!<CR>', { desc = 'Delete buffer' })

-- Move lines up and down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Decrease indent and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Increase indent and reselect' })

-- Center cursor when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
