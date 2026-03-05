{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sengming";
  home.homeDirectory = "/home/sengming";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/alacritty/alacritty.toml" = {
     text = ''
[terminal.shell]
program = "fish" # Or the correct path to your fish executable
args = ["-l"] # -l ensures a login shell is started, loading fish configurations

[font]
normal = { family = "MesloLGS Nerd Font Mono", style = "Regular" }
bold = { family = "MesloLGS Nerd Font Mono", style = "Bold" }
italic = { family = "MesloLGS Nerd Font Mono", style = "Italic" }
bold_italic = { family = "MesloLGS Nerd Font Mono", style = "Bold Italic" }
size = 12.0
     '';
   };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sengming/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  xdg.configFile."nvim/init.lua".text = ''
    vim.g.mapleader = "\\"
    vim.g.maplocalleader = "\\"

    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.cursorline = true
    vim.opt.signcolumn = "yes"
    vim.opt.mouse = "a"
    vim.opt.clipboard = "unnamedplus"
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.updatetime = 250
    vim.opt.timeoutlen = 500
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.termguicolors = true
    vim.opt.completeopt = "menu,menuone,noselect"

    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        vim.highlight.on_yank()
      end,
    })

    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      { "nvim-tree/nvim-tree.lua", lazy = false, dependencies = { "nvim-tree/nvim-web-devicons" }, config = function()
          require("nvim-tree").setup({
            hijack_netrw = true,
            disable_netrw = true,
            view = { width = 30 },
            renderer = {
              icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
            },
          })
        end
      },
      { "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
          { "<leader>rg", function() require("telescope.builtin").live_grep() end },
          { "<leader>ff", function() require("telescope.builtin").find_files() end },
        },
      },
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
          local ok, configs = pcall(require, "nvim-treesitter.configs")
          if not ok then
            return
          end
          configs.setup({
            highlight = { enable = true },
            indent = { enable = true },
          })
        end
      },
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        config = function()
          local cmp = require("cmp")
          local luasnip = require("luasnip")
          require("luasnip.loaders.from_vscode").lazy_load()

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
            }, {
              { name = "buffer" },
            }),
          })
        end
      },
      { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },
      { "tpope/vim-fugitive" },
      { "lewis6991/gitsigns.nvim", config = function()
          require("gitsigns").setup()
        end
      },
    })

    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    vim.keymap.set("n", "<leader>n", ":NvimTreeFindFile<CR>", { silent = true })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.cmd("NvimTreeOpen")
        if vim.fn.argc() > 0 then
          vim.cmd("wincmd p")
        end
      end,
    })


    local function lsp_keymaps(bufnr)
      local opts = { buffer = bufnr }
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        lsp_keymaps(args.buf)
      end,
    })
'';

  programs.tmux = {
    enable = true;
    shell = "/run/current-system/sw/bin/fish";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
