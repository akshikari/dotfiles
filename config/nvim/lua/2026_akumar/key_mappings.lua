-- Basic Key Maps
vim.keymap.set('n', 'gl', '^', { desc = 'Move to first non-blank character' })

vim.keymap.set('n', '<leader><C-q>', ':bd<CR>', { desc = 'Close current buffer' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

