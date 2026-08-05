-- save. <Esc> used to do this, but escape is what dismisses lsp floats,
-- completion menus and pickers, so it had to go back to being escape.
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
-- escape also clears the search highlight, which is what it is for everywhere else
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear Search Highlight' })
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- nothing is lost by <Esc> no longer saving: real files get written whenever
-- you leave the buffer or tab away from the terminal.
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
  desc = 'autosave on leaving a buffer or the terminal',
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= '' then return end
    if not vim.bo[buf].modifiable or vim.bo[buf].readonly then return end
    if not vim.bo[buf].modified then return end
    if vim.api.nvim_buf_get_name(buf) == '' then return end
    vim.api.nvim_buf_call(buf, function() vim.cmd('silent! write') end)
  end,
})
