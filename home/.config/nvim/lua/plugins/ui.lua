return {
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true,  -- popup that shows what my leader keys do
  },
  {
    -- statusline: mode, branch, diagnostics, attached lsp, position
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'rose-pine',
        globalstatus = true,
        section_separators = '',
        component_separators = '|',
      },
      sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
          {
            -- which language servers are actually attached to this buffer
            function()
              local names = {}
              for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                names[#names + 1] = client.name
              end
              return table.concat(names, ' ')
            end,
            icon = ' ',
          },
          'filetype',
        },
      },
    },
  },
  {
    -- a real list for diagnostics and references instead of the quickfix window
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix (Trouble)' },
    },
  },
}
