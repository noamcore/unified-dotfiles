local utils = require('../utils')
local lsp = require('lspconfig')

local noremap = {
  noremap = true,
  silent = true,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}

local noremap_expr = vim.tbl_extend('force', noremap, {expr = true})

utils.set_globals {
    completion_matching_strategy_list = {'exact', 'substring', 'fuzzy', 'all'},
}

local on_attach = function (client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.resolved_capabilities.document_formatting then
    utils.remap {
      n = {{'<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', noremap}}
    }
  end

  if client.resolved_capabilities.document_range_formatting then
    utils.remap {
      v = {{'<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', noremap}}
    }
  end

  if client.resolved_capabilities.document_highlight then
    vim.cmd[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> Lspsaga show_cursor_diagnostics
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end
end

local servers = {
  'cmake',
  'vimls',
  'gopls',
  'clangd',
  'texlab',
  'tsserver',
  'elixirls',
  'rust_analyzer',
  'java_language_server',
}

local servers_settings = {
  rust_analyzer = {
    updates = {
      channel = "nightly"
    },
  },
  elixirls = {
    projectDir = ".",
  },
  sumneko_lua = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = {'vim', 'use', 'use_rocks'},
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        }
      },
      telemetry = {
        enable = false,
      }
    }
  },
  texlab = {
    bibtex = {
      formatting = {
        lineLength = 80,
      },
    },
    texlab = {
      build = {
        args = {
          "-xelatex",
          "-synctex=1",
          "-shell-escape",
          "-interaction=nonstopmode",
          "-output-directory=build",
          "%f"
        },
        onSave = true,
        outputDirectory = "build",
      },
      lint = {
        onChange = true,
      },
      rootDirectory = ".",
    }
  },
  gopls = {
    analyses = {
      unusedparams = true,
    },
    staticcheck = true,
  }
}

local commands = {
  elixirls = { '/usr/local/bin/elixir-ls/language_server.sh' },
  java_language_server = { '/Users/iago/Projects/java/java-language-server/dist/lang_server_mac.sh' },
  gopls = {vim.fn.expand('~/go/bin/gopls'), 'serve'}
}

for _, server in pairs(servers) do
  lsp[server].setup {
    on_attach = on_attach,
    settings = servers_settings[server],
    capabilities = capabilities,
    cmd = commands[server],
  }
end

utils.remap {
  n = {
    {'<F2>', '<cmd>lua vim.lsp.buf.rename()<CR>', noremap},
    {'<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', noremap},
    {'<leader>sd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', noremap},
    {'K', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap},
    {'[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', noremap},
    {']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', noremap},
    {'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', noremap},
    {'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', noremap},
    {'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', noremap},
    {'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', noremap},
    {'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', noremap},
    {'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', noremap},
    {'gr', '<cmd>lua vim.lsp.buf.references()<CR>', noremap},
    {'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', noremap},
    {'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', noremap},
    {'<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', noremap},
    {'<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', noremap},
    {'<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', noremap},
  },
  i = {
    {'<cr>', 'v:lua.completion_confirm()', noremap_expr},
    {'<tab>', 'pumvisible() ? "<C-n>" : "<tab>"', noremap_expr},
    {'<S-tab>', 'pumvisible() ? "<C-p>" : "<S-tab>"', noremap_expr},
  }
}
