-- blink.cmp: completion, signature help and snippets in one plugin.
-- it uses neovim 0.11's builtin vim.snippet, so no separate snippet engine.
return {
  {
    'saghen/blink.cmp',
    version = '1.*', -- release tags ship the prebuilt rust fuzzy matcher
    event = 'InsertEnter',
    opts = {
      keymap = {
        -- enter accepts, tab/shift-tab walk the list. deliberately not using
        -- tab-to-accept so tab still indents when the menu is closed.
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
