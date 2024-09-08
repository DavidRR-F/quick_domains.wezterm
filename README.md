# ⚡ Quick Domains

A faster way to search and attach to domains in wezterm

## Quick Look

![Peek 2024-09-08 17-07](https://github.com/user-attachments/assets/747bb423-a277-4273-b80d-65d94ce2e873)

#### Dependencies

There are no package dependencies, but you need to configured your
`.ssh/config` [Here](https://wezfurlong.org/wezterm/config/lua/wezterm/enumerate_ssh_hosts.html) or configure your ssh domains [Here](https://wezfurlong.org/wezterm/config/lua/SshDomain.html) to select ssh domains with this plugin.

### 🚀 Install

This is a wezterm plugin. It can be installed by importing the repo and calling the `apply_to_config` function. It is important that the `apply_to_config` function is called after keys and key_tables have been set.
```lua 
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")
domains.apply_to_config(config)
```

### 🎨 Configuration

The `apply_to_config` function takes a second param opts. To override any options simply pass a table of the desired changes.

```lua
domains.apply_to_config(
  config,
  {
    keys = {
      attach = {
        key  = 's',
        mods = 'SHIFT',
        tbl  = 'tmux'
      }
    }
  }
)
```

### 🛠️ Defaults

These are the current default setting the can be overridden on your `apply_to_config` function

```lua 
{
  keys = {
    attach = {
      -- mod keys for fuzzy domain finder
      mods = 'CTRL',
      -- base key for fuzzy domain finder
      key = 'd',
      -- key table to insert key map to if any
      tbl = '',
    }
  },
  -- swap in and out icons for specific domains
  icons = {
    hosts = '',
    ssh = '󰣀',
    tls = '󰢭',
    unix = '',
    bash = '',
    zsh = '',
    fish = '',
    pwsh = '󰨊',
    powershell = '󰨊',
    wsl = '',
    windows = '',
    docker = '',
    kubernetes = '󱃾',
  }
}

```
