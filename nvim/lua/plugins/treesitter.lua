require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = {
        enable = true,
    },
    autotag = {
      enable = true,
    },
    autopairs = {
      enable = true,
    },
    matchup = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
    },
    incremental_selection = { enable = true },
    textobjects = { enable = true },
}
