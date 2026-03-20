return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavor = 'frappe',
  },
  config = function()
    vim.cmd.colorscheme 'catppuccin-frappe'
  end,
}
