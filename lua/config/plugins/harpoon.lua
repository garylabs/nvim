return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- IMPORTANT: This is the Harpoon 2 setup
    harpoon:setup {
      -- Optional configuration settings can go here
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    }

    -- Basic keymaps for Harpoon
    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = '[H]arpoon [A]dd file' })
    vim.keymap.set('n', '<leader>hl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '[H]arpoon [L]ist' })

    -- Navigation using Option (Alt) key on macOS
    -- Note: These use Option + 1-4 to jump to specific marks
    vim.keymap.set('n', '<M-1>', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon to file 1' })
    vim.keymap.set('n', '<M-2>', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon to file 2' })
    vim.keymap.set('n', '<M-3>', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon to file 3' })
    vim.keymap.set('n', '<M-4>', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon to file 4' })
    -- Optional: Navigation between marks
    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end, { desc = '[H]arpoon [P]revious' })
    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end, { desc = '[H]arpoon [N]ext' })
  end,
}
