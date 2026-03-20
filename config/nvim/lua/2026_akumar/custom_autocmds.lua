-- Custom autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Automatically return to the last cursor position when reopening a file',
  group = vim.api.nvim_create_augroup('buf-open-cursor', { clear = true }),
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

local cleanup_group = vim.api.nvim_create_augroup('buf-auto-import', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = '',
  group = cleanup_group,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Auto-import dependencies on type and organize imports (when possible)',
  group = cleanup_group,
  pattern = '*.go',
  callback = function()
    ---@diagnostic disable-next-line: inject-field
    local params = vim.lsp.util.make_range_params(0, 'utf-16')
    params.context = { only = { 'source.organizeImports' } }
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format { async = false }
  end,
})
