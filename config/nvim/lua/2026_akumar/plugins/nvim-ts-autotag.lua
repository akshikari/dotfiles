return {
  'windwp/nvim-ts-autotag',
  after = 'nvim-treesitter',
  event = 'BufReadPre',
  config = function()
    require('nvim-ts-autotag').setup {}
  end,
}
