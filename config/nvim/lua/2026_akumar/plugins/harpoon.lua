return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { { 'nvim-lua/plenary.nvim' } },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = '[A]dd file to harpoon pick list' })

    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Switch to harpoon file ' .. i })
    end
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>m' .. i, function()
        harpoon:list():replace_at(i)
      end, { desc = 'Replace harpoon file ' .. i })
    end
  end,
}
