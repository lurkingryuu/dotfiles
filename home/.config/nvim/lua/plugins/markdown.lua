-- markdown rendered in the buffer itself: headings, tables, code blocks,
-- callouts and checkboxes drawn with extmarks. chosen over markview.nvim
-- because the rendering persists while you type - only the cursor line falls
-- back to raw text - rather than collapsing every time the cursor moves.
--
-- no browser preview and no image protocol here on purpose: wezterm's kitty
-- graphics support is partial and known to hang the snacks picker.
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      -- prose settings. conceallevel is left alone: render-markdown manages it.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'tex', 'gitcommit' },
        desc = 'wrap and spellcheck prose',
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
          vim.opt_local.spelllang = 'en_us'
        end,
      })
    end,
    opts = {
      completions = { lsp = { enabled = true } },
      heading = { sign = false },
      code = { sign = false, width = 'block', right_pad = 2 },
      anti_conceal = { enabled = true },
    },
    keys = {
      { '<leader>um', '<cmd>RenderMarkdown toggle<cr>', ft = 'markdown', desc = 'Toggle Markdown Render' },
    },
  },
}
