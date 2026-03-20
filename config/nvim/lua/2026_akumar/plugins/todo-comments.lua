return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = true,
  },
  keys = {
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next todo comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous todo comment',
    },
    {
      ']e',
      function()
        require('todo-comments').jump_next { keywords = { 'ERROR', 'WARNING' } }
      end,
      desc = 'Next error/warning todo comment',
    },
    {
      '[e',
      function()
        require('todo-comments').jump_prev { keywords = { 'ERROR', 'WARNING' } }
      end,
      desc = 'Previous error/warning todo comment',
    },
    {
      '<leader>ct',
      '<cmd>TodoTelescope<CR>',
      desc = 'Open List of all [T]odo-related comments in Telescope',
    },
    {
      '<leader>cl',
      '<cmd>TodoLocList<CR>',
      desc = 'Open all Todo-related comments relevant to the current [L]ocation',
    },
  },
}
