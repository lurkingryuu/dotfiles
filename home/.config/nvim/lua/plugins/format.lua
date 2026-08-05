-- formatting on save via conform. it applies a minimal diff rather than
-- replacing the buffer, so cursor position, marks and folds survive.
--
-- linting is not handled here: ruff, eslint (via vscode-langservers-extracted)
-- and clangd already report diagnostics through lsp.
return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cf',
        function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        mode = { 'n', 'v' },
        desc = 'Format Buffer',
      },
      {
        '<leader>uf',
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify('format on save ' .. (vim.g.disable_autoformat and 'off' or 'on'))
        end,
        desc = 'Toggle Format On Save',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        go = { 'gofmt' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        java = { 'clang_format' },
        rust = { 'rustfmt' },
        terraform = { 'terraform_fmt' },
        hcl = { 'terraform_fmt' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        yaml = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        markdown = { 'prettierd' },
      },
      -- returning nil here skips formatting entirely, which is how the
      -- <leader>uf toggle takes effect.
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
    },
  },
}
