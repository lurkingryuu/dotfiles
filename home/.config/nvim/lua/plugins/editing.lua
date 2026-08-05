-- the small motions and text-editing plugins. each one replaces a handful of
-- keystrokes you would otherwise repeat all day.
return {
  {
    -- s/S to jump anywhere on screen by typing two characters and a label.
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
    },
  },
  {
    -- gsa/gsd/gsr to add, delete and replace surrounding quotes, brackets, tags.
    -- moved off the default `s` prefix because flash owns `s` now, and leaving
    -- both in place makes every `s` wait out timeoutlen for a possible `sa`.
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    opts = {
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
      },
    },
  },
  {
    'echasnovski/mini.pairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    keys = {
      -- snacks knows about todo-comments, so no telescope needed here
      { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo Comments' },
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Prev Todo' },
    },
  },
}
