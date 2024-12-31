return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      notify_on_error = true,
      log_level = vim.log.levels.DEBUG,
      -- Format on save configuration
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
      formatters = {
        stylua = {
          -- Try to force stylua to find the config
          prepend_args = { '--config-path', vim.fn.expand '~/.config/nvim/.stylua.toml' },
        },
        ruff = {
          args = {},
        },
      },
      -- Configure formatters by filetype
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        -- go = { "gofmt" },
        -- rust = { "rustfmt" },
      },
    },
  },
}
