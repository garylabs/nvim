return {
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local fzf = require 'fzf-lua'

      -- Configure fzf-lua
      fzf.setup {
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            horizontal = 'right:50%',
            layout = 'horizontal',
            scroll = 'none',
          },
        },
        keymap = {
          builtin = {
            ['<C-d>'] = 'preview-page-down',
            ['<C-u>'] = 'preview-page-up',
          },
        },
      }
    end,
  },
}
