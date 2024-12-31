return {
  'rebelot/kanagawa.nvim',
  config = function()
    require('kanagawa').setup {
      transparent = false,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
    }

    local bg_transparent = true
    local toggle_transparency = function()
      bg_transparent = not bg_transparent
      require('kanagawa').setup {
        transparent = bg_transparent,
      }
      vim.cmd.colorscheme 'kanagawa'
    end
    vim.keymap.set('n', '<leader>bg', toggle_transparency, { desc = 'Toggle Transparency' })
    vim.cmd.colorscheme 'kanagawa'
  end,
}
