-- language servers, driven by neovim 0.11's native vim.lsp.config/enable api.
-- nvim-lspconfig is here purely as the data package: it ships the per-server
-- lsp/*.lua definitions (cmd, root markers, filetypes) that vim.lsp.enable
-- picks up off the runtimepath. we never call require('lspconfig').
--
-- the servers themselves are installed with nix, see home.packages.
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- blink advertises the completion capabilities it can actually handle
      -- (snippets, resolve support, ...) on top of neovim's own defaults.
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- lua_ls needs to be told it is editing neovim config, otherwise every
      -- `vim` reference is an undefined global.
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- ruff handles lint + format; let pyright own hover so the two don't
      -- both answer with different content.
      vim.lsp.config('ruff', {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.enable({
        'lua_ls',
        'pyright',
        'ruff',
        'gopls',
        'clangd',
        'rust_analyzer',
        'ts_ls',
        'terraformls',
        'marksman',
        'texlab',
        'jsonls',
      })

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, prefix = '●' },
        float = { border = 'rounded', source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
          },
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'lsp keymaps and per-buffer features',
        callback = function(args)
          local buf = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
          end

          -- 0.11 already gives us K, grn, gra, grr and gri out of the box.
          -- these route the same jobs through the snacks picker instead, which
          -- is the picker used everywhere else in this config.
          map('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition')
          map('gD', function() Snacks.picker.lsp_declarations() end, 'Goto Declaration')
          map('gr', function() Snacks.picker.lsp_references() end, 'References')
          map('gI', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
          map('gy', function() Snacks.picker.lsp_type_definitions() end, 'Goto Type Definition')
          map('<leader>ss', function() Snacks.picker.lsp_symbols() end, 'Document Symbols')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename Symbol')
          map('<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')

          -- inlay hints are useful but noisy in dense code, so they are a toggle.
          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            map('<leader>uh', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })
    end,
  },
}
