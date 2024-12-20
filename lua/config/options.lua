local set = vim.opt

set.shiftwidth = 4
set.number = true
set.relativenumber = true
vim.g.mapleader = ' '

set.list = true
set.conceallevel = 2
set.showmode = false -- Dont show mode since we have a statusline
set.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
set.smartcase = true -- Don't ignore case with capitals
set.smartindent = true -- Insert indents automatically
set.splitbelow = true -- Put new windows below current
set.splitkeep = 'screen'
set.splitright = true -- Put new windows right of current
