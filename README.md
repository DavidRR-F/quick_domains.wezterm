# Quick Domains

A fast wezterm ssh domain finder to quickly attach to your defined ssh sessions

## Quick Look

### Dependencies

There are no package dependencies but this plugin does assume you have configured a 
`.ssh/config` as defined in the [WezTerm](https://wezfurlong.org/wezterm/config/lua/wezterm/enumerate_ssh_hosts.html) documentation

```bash
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur

Host 192.168.1.*
  ForwardAgent yes
  ForwardX11 yes

Host woot
  User someone
  Hostname localhost
```

### Setup

#### Install

This is a wezterm plugin. It can be installed by importing the repo and calling the `apply_to_config` function. It is important that the `apply_to_config` function is called after keys and key_tables have been set.
```lua 
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")
domains.apply_to_config(config)
```

#### Configure

The `apply_to_config` function takes a second param opts. To override any options simply pass a table of the desired changes.

```lua
domains.apply_to_config(
  config,
  {
    keys = {
      attach = {
        key  = 'd',
        mods = '',
        tbl  = 'tmux'
      }
    }
  }
)
```

##### Defaults

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
  icons = {
    -- title icon
    hosts = '',
    -- ssh domain icons
    ssh = '󰣀',
  }
}

```
