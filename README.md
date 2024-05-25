# kickstart-roblox.nvim

Starting point for your Neovim configuration for Roblox. **This** is not a Neovim distro.

## Requirements

- Neovim 0.10+
- A C++ compiler (gcc, g++, clang, etc)
- A [nerd font](https://www.nerdfonts.com/) (optional)

## Features

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

## Install

### I do not have a config (first time using Neovim)

Donwload [init.lua](https://github.com/lopi-py/kickstart-roblox.nvim/blob/main/init.lua) and place it into your Neovim config

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
nvim -u /tmp/kickstart-roblox.lua src/client/init.client.luau
```

</details>

<details>

<summary>Windows (powershell)</summary>

```bash
curl https://raw.githubusercontent.com/lopi-py/kickstart-roblox.nvim/main/init.lua -o $env:USERPROFILE\Downloads\kickstart-roblox.lua

# start Neovim in your project folder
nvim -u $env:USERPROFILE\Downloads\kickstart-roblox.lua src/client/init.luau
```

</details>
