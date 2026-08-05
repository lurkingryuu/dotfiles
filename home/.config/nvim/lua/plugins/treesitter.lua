-- treesitter on the `main` branch: the 2025 rewrite. `master` is frozen, and
-- the two are not compatible, so treat this as a different plugin to anything
-- you read about pre-2025. parsers are compiled locally, which is why the
-- tree-sitter cli is in home.packages.
--
-- the big gotcha: unlike `master`, this branch does not turn highlighting on
-- for you. the FileType autocmd below is what actually starts it.
local parsers = {
  'bash',
  'c',
  'cpp',
  'css',
  'diff',
  'dockerfile',
  'git_config',
  'git_rebase',
  'gitcommit',
  'gitignore',
  'go',
  'gomod',
  'gosum',
  'hcl',
  'html',
  'java',
  'javascript',
  'json',
  'latex',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'nix',
  'python',
  'query',
  'regex',
  'rust',
  'sql',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- install anything missing in the background; already-present parsers
      -- are a no-op, so this is cheap on every start.
      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'start treesitter highlighting and indent when a parser exists',
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then return end
          if not pcall(vim.treesitter.start, args.buf, lang) then return end
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    -- select and move by syntax node: vif for a function body, ]f for the next
    -- function, and so on. also on the rewritten `main` branch.
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local objects = {
        f = { '@function.outer', '@function.inner', 'Function' },
        c = { '@class.outer', '@class.inner', 'Class' },
        a = { '@parameter.outer', '@parameter.inner', 'Parameter' },
        i = { '@conditional.outer', '@conditional.inner', 'Conditional' },
        l = { '@loop.outer', '@loop.inner', 'Loop' },
      }
      for key, spec in pairs(objects) do
        local outer, inner, name = spec[1], spec[2], spec[3]
        vim.keymap.set({ 'x', 'o' }, 'a' .. key, function()
          select.select_textobject(outer, 'textobjects')
        end, { desc = 'Around ' .. name })
        vim.keymap.set({ 'x', 'o' }, 'i' .. key, function()
          select.select_textobject(inner, 'textobjects')
        end, { desc = 'Inside ' .. name })
      end

      local move = require('nvim-treesitter-textobjects.move')
      local jumps = {
        { ']f', 'goto_next_start', '@function.outer', 'Next Function' },
        { '[f', 'goto_previous_start', '@function.outer', 'Prev Function' },
        { ']c', 'goto_next_start', '@class.outer', 'Next Class' },
        { '[c', 'goto_previous_start', '@class.outer', 'Prev Class' },
      }
      for _, jump in ipairs(jumps) do
        local lhs, fn, query, desc = jump[1], jump[2], jump[3], jump[4]
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          move[fn](query, 'textobjects')
        end, { desc = desc })
      end
    end,
  },
}
