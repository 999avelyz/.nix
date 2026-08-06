{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      rustfmt
      black
      clang-tools
      nixfmt
      stylua
      ripgrep
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      lualine-nvim
      bufferline-nvim
      toggleterm-nvim
      conform-nvim
    ];

    initLua = ''
      require('nvim-tree').setup({
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          api.config.mappings.default_on_attach(bufnr)

          local opts = function(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          vim.keymap.set('n', 'n', api.tree.change_root_to_node, opts('CD into folder'))
          vim.keymap.set('n', 'b', api.tree.change_root_to_parent, opts('CD to parent folder'))
          vim.keymap.set('n', '<RightMouse>', api.tree.change_root_to_node, opts('CD into folder'))
        end,
      })

      require('lualine').setup()

      require('telescope').setup({
        defaults = {
          -- used by live_grep / grep_string
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/*",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--glob=!**/.git/*" },
          },
        },
      })

      require('bufferline').setup({
        options = {
          diagnostics = "nvim_lsp",
          show_close_icon = true,
          show_buffer_close_icons = true,
          separator_style = "thin",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
              highlight = "NvimTreeNormal",
            }
          }
        },
        highlights = {
          fill = { bg = "NONE" },
          background = { bg = "NONE" },
          buffer_visible = { bg = "NONE" },
          buffer_selected = { bg = "NONE", bold = true, fg = "#89b4fa" },
          separator = { bg = "NONE" },
          separator_visible = { bg = "NONE" },
          separator_selected = { bg = "NONE" },
          close_button = { bg = "NONE" },
          close_button_visible = { bg = "NONE" },
          close_button_selected = { bg = "NONE" },
          modified = { bg = "NONE" },
          modified_visible = { bg = "NONE" },
          modified_selected = { bg = "NONE" },
          offset_separator = { bg = "NONE" },
        }
      })

      require('toggleterm').setup({
        size = 15,
        direction = 'horizontal',
        shade_terminals = false,
      })

      require('conform').setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          rust = { "rustfmt" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          nix = { "nixfmt" },
        },
      })

      local transparent_groups = {
        "Normal", "NormalNC", "NormalFloat", "FloatBorder",
        "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeCursorLine", "NvimTreeCursorLineNC", 
        "NvimTreeGitDirty", "NvimTreeGitStaged", "NvimTreeGitMerge", "NvimTreeGitNew",
        "SignColumn", "LineNr", "CursorLine", "CursorLineNr",
        "EndOfBuffer", "MsgArea", "ToggleTerm", "ToggleTermNormal",
      }

      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
      end

      local devicons = require('nvim-web-devicons')
      for _, icon in pairs(devicons.get_icons()) do
        if icon.hl then
          vim.api.nvim_set_hl(0, icon.hl, { bg = "NONE", ctermbg = "NONE" })
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then return end
          local ok, has_parser = pcall(vim.treesitter.language.add, lang)
          if ok and has_parser then
            vim.treesitter.start(args.buf, lang)
          end
        end,
      })

      vim.opt.number = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true
      vim.opt.mouse = "a"

      vim.g.mapleader = " "

      vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save the file" })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
      vim.keymap.set("n", "<leader><Tab>", ":BufferLineCycleNext<CR>", { desc = "Cycle next tab" })
      vim.keymap.set("n", "<leader><Left>", ":BufferLineCyclePrev<CR>", { desc = "Cycle previous tab" })
      vim.keymap.set("n", "<leader><Right>", ":BufferLineCycleNext<CR>", { desc = "Cycle next tab" })
      vim.keymap.set({"n", "t"}, "<leader>j", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

      vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>d", "<cmd>Telescope live_grep<CR>", { desc = "Search words in files" })
      
      vim.keymap.set({ "n", "v" }, "<leader>F", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format file" })

      vim.keymap.set({"n", "t"}, "<leader>w", "<cmd>wincmd w<CR>", { desc = "Cycle between open windows" })
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, desc = "Exit terminal mode" })

      vim.keymap.set("n", "<leader>c", function()
        local current_buf = vim.api.nvim_get_current_buf()
        local listed_bufs = {}
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "NvimTree" then
            table.insert(listed_bufs, bufnr)
          end
        end

        if #listed_bufs > 1 then
          vim.cmd("bprevious")
          if vim.api.nvim_get_current_buf() == current_buf then
            vim.cmd("bnext")
          end
          vim.api.nvim_buf_delete(current_buf, { force = false })
        else
          vim.api.nvim_buf_delete(current_buf, { force = false })
        end
      end, { desc = "Close current tab" })
    '';
  };
}
