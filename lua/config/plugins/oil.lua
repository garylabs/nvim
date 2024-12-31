return {
  'stevearc/oil.nvim',
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    local function get_file_tags(filepath)
      -- Run the tag -l command and capture its output
      local handle = io.popen(string.format('tag -l "%s"', filepath))
      if not handle then
        return ''
      end
      local result = handle:read '*a'
      handle:close()

      print('Filepath: ', filepath)
      print('Tags result: ', result)

      -- Clean up the output and return as a comma-separated string
      return vim.trim(result:gsub('\n', ', '))
    end
    require('oil').setup {
      columns = {
        'icon',
        'size',
        {
          'tags',
          header = 'Tags',
          render = function(entry)
            -- Don't show tags for directories
            if entry.type == 'directory' then
              return ''
            end

            -- Get the full path of the file
            local filepath = require('oil').get_current_dir() .. entry.name
            -- Return the tags for this file
            return get_file_tags(filepath)
          end,
        },
      },
      keymaps = {
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-j>'] = false,
        ['<C-k>'] = false,
        ['<CR>'] = 'actions.select',
        ['<leader>ta'] = {
          callback = function()
            local oil = require 'oil'
            local entry = oil.get_cursor_entry()
            if entry then
              local filepath = oil.get_current_dir() .. entry.name
              -- Prompt for tags
              vim.ui.input({ prompt = 'Tags: ' }, function(tags)
                if tags then
                  -- Execute the tag command
                  vim.fn.system(string.format('tag -a "%s" "%s"', tags, filepath))
                  -- Refresh the current buffer instead of using reload
                  vim.cmd 'edit'
                end
              end)
            end
          end,
          desc = 'Tag file',
        },
        ['<leader>tv'] = {
          callback = function()
            local oil = require 'oil'
            print 'hello hello'
            local entry = oil.get_cursor_entry()
            if entry then
              local filepath = oil.get_current_dir() .. entry.name
              local result = vim.fn.system(string.format('tag -l -N "%s"', filepath))
              vim.notify(result)
            end
          end,
          desc = 'View Tags',
        },
        ['<M-h>'] = 'actions.select_split',
        ['<M-m>'] = {
          callback = function()
            -- Get the current entry under cursor
            local oil = require 'oil'
            local entry = oil.get_cursor_entry()
            if entry then
              -- Get full path of the entry
              local path = oil.get_current_dir() .. entry.name
              -- Spawn mpv process with the file
              vim.fn.jobstart({ 'mpv', '--no-audio', '--start=10%', path }, {
                detach = true, -- Detach the process from Neovim
              })
            end
          end,
          desc = 'Open in mpv', -- Description for which-key
          nowait = true,
        },
      },
      delete_to_trash = false,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      -- Save after file operations
      save_on_change = true,
    }
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '<leader>-', '<CMD>Oil --float<CR>', { desc = 'Open parent directory (floating)' })
  end,
}
