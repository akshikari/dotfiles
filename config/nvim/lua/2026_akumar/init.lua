require '2026_akumar.configs'
require '2026_akumar.key_mappings'
require '2026_akumar.custom_autocmds'
require '2026_akumar.lazy_init'

require('lazy').setup({
  { import = '2026_akumar.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
