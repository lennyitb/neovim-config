-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8

-- Set leader key to comma
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Custom keymaps
-- Map hh to escape in insert and visual mode
vim.keymap.set('i', 'hh', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('v', 'hh', '<Esc>', { noremap = true, silent = true })

-- Map space to colon in normal mode for quick commands
vim.keymap.set('n', '<Space>', ':', { noremap = true })

-- Map ge to end of line
vim.keymap.set('n', 'ge', '$', { noremap = true })

-- Swap 0 and ^ (0 goes to first non-blank, ^ goes to column 0)
vim.keymap.set('n', '0', '^', { noremap = true })
vim.keymap.set('n', '^', '0', { noremap = true })

-- Hop mappings for w e b variants
vim.keymap.set({'n', 'v'}, '<leader>w', ':HopWordAC<CR>', {silent = true})
vim.keymap.set({'n', 'v'}, '<leader>b', ':HopWordBC<CR>', {silent = true})
vim.keymap.set({'n', 'v'}, '<leader>e', function()
  vim.cmd('HopWordAC')
  vim.defer_fn(function()
    vim.api.nvim_feedkeys('e', 'n', false)
  end, 50)
end, {silent = true})

-- Install lazy. nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup({
    -- Commentary:  gc to comment
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },

    -- Surround: ys, ds, cs for surrounding text
    {
        'kylechui/nvim-surround',
        version = "*",
        config = function()
            require('nvim-surround').setup()
        end
    },

    -- Leap:  Sneak-style jumping with ; and , repeat
    {
        'ggandor/leap.nvim',
        config = function()
            local leap = require('leap')
            -- Use your Dvorak label sequence
            leap.opts.labels = 'aoeuidhtns-pyfgcrlqjkxbmwvz'
            -- s to search forward (like sneak)
            vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap-forward)')
            -- S to search backward
            vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-backward)')
            -- gs to search in other windows
            vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
        end,
    },

    -- Hop: EasyMotion-style jumping that actually works
    {
        'smoka7/hop.nvim',
        version = "*",
        config = function()
            require('hop').setup({
                keys = 'aoeuidhtns-pyfgcrlqjkxbmwvz,.',  -- Your Dvorak sequence! 
                quit_key = '<Esc>',
            })

            -- Set up keymaps
            local hop = require('hop')
            local directions = require('hop.hint').HintDirection

            -- Enhanced f/F/t/T - MULTI-LINE
            vim.keymap.set('', ',f', function()
                hop.hint_char1({ direction = directions. AFTER_CURSOR })
            end, { remap = true })
            vim.keymap.set('', ',F', function()
                hop.hint_char1({ direction = directions.BEFORE_CURSOR })
            end, { remap = true })
            vim.keymap.set('', ',t', function()
                hop.hint_char1({ direction = directions. AFTER_CURSOR, hint_offset = -1 })
            end, { remap = true })
            vim.keymap.set('', ',T', function()
                hop.hint_char1({ direction = directions. BEFORE_CURSOR, hint_offset = 1 })
            end, { remap = true })
        end,
    },

    -- Optional: Nice color scheme
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-night]])
        end,
    },
})

-- Only run this in VSCode
if vim. g.vscode then
    local vscode = require("vscode")
    local function notify_vscode_mode()
        local mode = vim.api.nvim_get_mode().mode
        local mode_name = ""

        if mode == "n" then mode_name = "normal"  -- Added explicit "n" check
        elseif mode == "i" then mode_name = "insert"
        elseif mode == "v" or mode == "V" or mode == "\22" then mode_name = "visual"
        elseif mode == "c" then mode_name = "cmdline"
        elseif mode == "R" then mode_name = "replace"
        else mode_name = mode end

        vscode.action("nvim-ui-plus.setMode", { args = { mode = mode_name } })
    end

    vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*",
        callback = notify_vscode_mode,
    })
end
