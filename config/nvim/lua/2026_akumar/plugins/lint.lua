return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' }, -- Markdown linter
        dockerfile = { 'hadolint' }, -- Dockerfile linter
        json = { 'jsonlint' }, -- JSON linter
        javascript = { 'eslint_d' }, -- JavaScript linter
        typescript = { 'eslint_d' }, -- TypeScript linter
        python = { 'mypy' }, -- Python type checker
        rust = { 'cargo' }, -- Rust linter (via cargo check)
        cpp = { 'clangtidy' }, -- C++ linter
        c = { 'clangtidy' }, -- C linter
        yaml = { 'yamllint' }, -- YAML linter
        terraform = { 'tflint' }, -- Terraform linter
        sql = { 'sqlfluff' }, -- SQL linter
        go = { 'golangcilint' }, -- Golang linter
        html = { 'htmlhint' }, -- HTML linter
        css = { 'stylelint' }, -- CSS linter
      }

      -- Autocommand for linting on specific events
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
