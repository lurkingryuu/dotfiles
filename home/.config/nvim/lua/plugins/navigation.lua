return {
  {
    'stevearc/oil.nvim',
    opts = { view_options = { show_hidden = true } },
    keys = { { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' } },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },      -- lazygit in a float, it is already installed via nix
      terminal = { enabled = true },
      statuscolumn = { enabled = true }, -- signs, folds and numbers in one tidy column
      indent = { enabled = true },       -- indent guides plus current-scope highlight
      words = { enabled = true },        -- highlight other references to the symbol under the cursor
      bigfile = { enabled = true },      -- disable the expensive stuff on huge files
      scratch = { enabled = true },
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = 'Search Buffer' },
      { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<leader>d', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>h', function() Snacks.picker.help() end, desc = 'Help Pages' },
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
      { '<leader>tt', function() Snacks.terminal() end, desc = 'Terminal' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Scratch Buffer' },
      -- lsp keymaps (gd, gr, gI, ...) live in plugins/lsp.lua so they only
      -- exist on buffers where a server is actually attached.
    },
  },
  {
    -- reopen a project where you left it
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },
      { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Restore Last Session' },
    },
  },
}
