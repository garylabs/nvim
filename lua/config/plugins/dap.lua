return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui', -- Adds UI for debugging
      'mfussenegger/nvim-dap-python', -- Python adapter for DAP
      'theHamsta/nvim-dap-virtual-text', -- Adds virtual text support
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_python = require 'dap-python'

      -- Configure UI
      dapui.setup {
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = 'scopes', size = 0.25 },
              'breakpoints',
              'stacks',
              'watches',
            },
            size = 40, -- 40 columns
            position = 'left',
          },
          {
            elements = {
              'repl',
              'console',
            },
            size = 0.25, -- 25% of total lines
            position = 'bottom',
          },
        },
      }

      -- Initialize Python debugging
      -- This will look for debugpy in your Python environment
      dap_python.setup()

      -- Configure Python test debugging
      dap_python.test_runner = 'pytest'

      -- Add configuration for regular Python files
      dap.configurations.python = dap.configurations.python or {}
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
          return '/usr/bin/python3' -- Adjust this path to your Python interpreter
        end,
      })

      -- Enable virtual text
      require('nvim-dap-virtual-text').setup()

      -- Auto open/close dapui
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Add some highlighting
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#993939', bg = '#31353f' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = '#31353f' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379', bg = '#31353f' })

      -- Define signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '●', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', numhl = 'DapLogPoint' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', numhl = 'DapStopped' })

      -- Keymaps
      local opts = { noremap = true, silent = true }

      -- Debugger controls
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug: Toggle [B]reakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = '[D]ebug: Set [B]reakpoint with condition' })

      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[D]ebug: [C]ontinue' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[D]ebug: Step [I]nto' })
      vim.keymap.set('n', '<leader>do', dap.step_over, { desc = '[D]ebug: Step [O]ver' })
      vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = '[D]ebug: Step [O]ut' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = '[D]ebug: Open [R]EPL' })

      -- UI controls
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[D]ebug: Toggle [U]I' })

      -- Test debugging (integration with neotest)
      vim.keymap.set('n', '<leader>dt', function()
        require('neotest').run.run { strategy = 'dap' }
      end, { desc = '[D]ebug: Current [T]est' })

      -- Launch file debugging
      vim.keymap.set('n', '<leader>dl', function()
        dap.run {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            return '/usr/bin/python3' -- Adjust this path to your Python interpreter
          end,
        }
      end, { desc = '[D]ebug: [L]aunch file' })

      -- Stop debugging
      vim.keymap.set('n', '<leader>dx', function()
        dap.terminate()
        dapui.close()
      end, { desc = '[D]ebug: Stop/[X]' })
    end,
  },
}
