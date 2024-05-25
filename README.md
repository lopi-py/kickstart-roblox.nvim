# kickstart-roblox.nvim

Starting point for your Neovim configuration for Roblox. This is **NOT** a Neovim distro.

## Requirements

- Neovim 0.10+
- A C++ compiler (gcc, g++, clang, etc)
- A [nerd font](https://www.nerdfonts.com/) (optional)

## Features

- Single and small configuration file
- Detailed comments to understand the configuration
- Support for editing your Neovim config
- Support for Roblox lua/luau projects
- Support for Roblox typescript projects
- Support for luau-lsp studio plugin
- Git integration
- LSP configuration:
    + Autoimports
    + Completion
    + Diagnostics
    + Go to definition
- Snippets
- Format on save
- Fuzzy file finder
- Syntax highlight

## Installation

### I do not have a config (first time using Neovim)

Download [init.lua](https://github.com/lopi-py/kickstart-roblox.nvim/blob/main/init.lua) and place it into your Neovim config

<details>

<summary>Linux and Mac</summary>

```bash
mkdir ~/.config/nvim
cd ~/.config/nvim

curl https://raw.githubusercontent.com/lopi-py/kickstart-roblox.nvim/main/init.lua -o ~/.config/nvim/init.lua
```

</details>

<details>

<summary>Windows (powershell)</summary>

```bash
mkdir ~\AppData\Local\nvim
cd ~\AppData\Local\nvim

curl https://raw.githubusercontent.com/lopi-py/kickstart-roblox.nvim/main/init.lua -o $env:USERPROFILE\AppData\Local\nvim\init.lua
```

</details>

Start Neovim in your project folder

```bash
nvim
```

### I already have a config (I just want to try)

<details>

<summary>Linux and Mac</summary>

```bash
curl https://raw.githubusercontent.com/lopi-py/kickstart-roblox.nvim/main/init.lua -o /tmp/kickstart-roblox.lua

# start Neovim in your project folder
nvim -u /tmp/kickstart-roblox.lua
```

</details>

<details>

<summary>Windows (powershell)</summary>

```bash
curl https://raw.githubusercontent.com/lopi-py/kickstart-roblox.nvim/main/init.lua -o $env:USERPROFILE\Downloads\kickstart-roblox.lua

# start Neovim in your project folder
nvim -u $env:USERPROFILE\Downloads\kickstart-roblox.lua
```

</details>

## Getting Started

Here are some essential key mappings to help you navigate and search through your files efficiently:
- `<space>sf`: Search files - Quickly find and open files within the project.
- `<space>sg`: Search by grep - Perform a text search within your project files using grep.
- `<space><space>`: List opened buffers - View and switch between currently opened buffers.
