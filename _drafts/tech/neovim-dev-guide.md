# Neovim開発環境構築ガイド - 最小構成

実用的な開発環境を最小限の設定で構築します。

## 1. インストール

```bash
# macOS
brew install neovim ripgrep

# Ubuntu/Debian
sudo apt install neovim ripgrep
```

## 2. 設定ファイル

### 2.1 メイン設定（~/.config/nvim/init.lua）

```lua
-- リーダーキー
vim.g.mapleader = " "

-- 基本設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- lazy.nvim自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン読み込み
require("lazy").setup({
  -- カラースキーム
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- LSP自動インストール
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "rust_analyzer" },
        automatic_installation = true,
      })

      -- LSPキーマップ
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })

      -- LSP自動設定
      require("mason-lspconfig").setup_handlers({
        function(server)
          require("lspconfig")[server].setup({})
        end
      })
    end
  },

  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        }
      })
    end
  },

  -- シンタックスハイライト
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "rust", "markdown" },
        highlight = { enable = true },
      })
    end
  },

  -- ファイル検索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
    end
  },
})

-- 基本キーマップ
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
```

## 3. 使い方

### 初回起動
1. Neovimを起動（プラグインが自動インストールされます）
2. `:checkhealth`で状態確認

### 主要操作

**ファイル操作**
- `<Space>e` - ファイルエクスプローラー
- `<Space>ff` - ファイル検索
- `<Space>fg` - 文字列検索
- `<Space>fb` - バッファ一覧

**LSP機能**
- `gd` - 定義へジャンプ
- `K` - ドキュメント表示
- `<Space>ca` - コードアクション
- `<Space>rn` - リネーム

**補完**
- `Tab` - 次の候補
- `Shift+Tab` - 前の候補
- `Enter` - 確定

**基本**
- `<Space>w` - 保存
- `<Space>q` - 終了

## 4. カスタマイズ

### 言語サーバー追加

`ensure_installed`に言語を追加：
```lua
ensure_installed = { "lua_ls", "pyright", "rust_analyzer", "clangd", "gopls" }
```

**Node.js不要の主要言語サーバー:**
- `lua_ls` - Lua
- `pyright` - Python
- `rust_analyzer` - Rust
- `clangd` - C/C++
- `gopls` - Go

利用可能なサーバー一覧は`:Mason`で確認できます。

### テーマ変更

```lua
vim.cmd.colorscheme("catppuccin-latte")  -- ライトテーマ
-- 他の選択肢: mocha, macchiato, frappe
```

## 5. トラブルシューティング

**LSPが動作しない**
```vim
:Mason  " サーバーのインストール状態確認
:LspInfo  " LSP接続状態確認
```

**補完が表示されない**
- ファイルを保存してLSPが起動するまで待つ
- `:checkhealth`でエラー確認

この構成で、主要な開発機能（補完、定義ジャンプ、シンタックスハイライト、ファイル検索）が利用できます。
