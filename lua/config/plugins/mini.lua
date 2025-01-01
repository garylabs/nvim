return {
  {
    'echasnovski/mini.nvim',
    config = function()
      local statusline = require 'mini.statusline'
      require('mini.ai').setup()
      statusline.setup { use_icons = true }
    end,
  },
  -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },
}
