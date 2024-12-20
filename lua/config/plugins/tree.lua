return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- optional but recommended
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        event_handlers = {
          {
            event = 'file_opened',
            handler = function()
              -- Auto close when a file is opened
              require('neo-tree').close_all()
            end,
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true, -- Follow the current file when changing directories
          },
          filtered_items = {
            visible = false, -- This is what hides the files by default
            hide_dotfiles = false,
            hide_gitignored = false,
            event_handlers = {
              {
                event = 'file_opened',
                handler = function()
                  -- Auto close when a file is opened
                  require('neo-tree').close_all()
                end,
              },
            },
            hide_by_name = {
              '.git',
              'node_modules',
            },
            never_show = { -- remains hidden even if visible is toggled
              '.DS_Store',
            },
          },
          find_command = 'fd', -- this is faster than the default find command
        },
        window = {
          width = 30,
          mappings = {
            ['<space>'] = 'none', -- Disable space mapping
            ['/'] = 'noop', -- Disable "/" so we can use it for filtering
            ['f'] = 'filter_on_submit',
            ['<c-x>'] = 'clear_filter',
            ['H'] = 'toggle_hidden',
            ['R'] = 'refresh',
            ['?'] = 'show_help',
            -- Add number-related options
            ['L'] = {
              function(state)
                require('neo-tree.sources.filesystem.commands').toggle_node(state)
                require('neo-tree.ui.renderer').redraw(state)
                vim.cmd 'set relativenumber!'
              end,
              desc = 'toggle relative line numbers',
            },
            ['N'] = {
              function(state)
                require('neo-tree.sources.filesystem.commands').toggle_node(state)
                require('neo-tree.ui.renderer').redraw(state)
                vim.cmd 'set number!'
              end,
              desc = 'toggle line numbers',
            },
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
          name = {
            use_git_status_colors = true,
          },
          git_status = {
            symbols = {
              added = '✚',
              deleted = '✖',
              modified = '',
              renamed = '󰁕',
              untracked = '',
              ignored = '',
              unstaged = '󰄱',
              staged = '',
              conflict = '',
            },
          },
        },
        commands = {
          -- Override the default 'toggle_node' command to maintain line numbers
          toggle_node = function(state, node)
            local node_id = node:get_id()
            if state.explicitly_opened_directories == nil then
              state.explicitly_opened_directories = {}
            end
            if node.type == 'directory' then
              if state.explicitly_opened_directories[node_id] then
                state.explicitly_opened_directories[node_id] = nil
              else
                state.explicitly_opened_directories[node_id] = true
              end
            end
            require('neo-tree.ui.renderer').redraw(state)
          end,
        },
      }

      -- Basic Keymaps
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle [E]xplorer' })
      vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { desc = 'Focus explorer' })
    end,
  },
}
