# ⚡ Quick Domains

A faster way to search and attach to domains in wezterm. Inspired by [smart_workpace_switcher.wezterm](https://github.com/MLFlexer/smart_workspace_switcher.wezterm)

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

The `apply_to_config` function takes a second parameter opts. To override any options simply pass a table of the desired changes.

```lua
domains.apply_to_config(
  config,
  {
    keys = {
      attach = {
        key  = 's',
        mods = 'SHIFT',
        tbl  = 'tmux'
      },
      vsplit = {
        key  = 'v',
        mods = 'SHIFT',
        tbl  = 'tmux'
      },
      hsplit = {
        key  = 'h',
        mods = 'SHIFT',
        tbl  = 'tmux'
      }
    }
  }
)
```

You can set a custom [wezterm format](https://wezfurlong.org/wezterm/config/lua/wezterm/format.html) for the domain fuzzy selector items 

```lua 
domains.formatter = function(icon, name, label)
  return wezterm.format({
    { Attribute = { Italic = true } },
    { Foreground = { AnsiColor = 'Fuchsia' } },
    { Background = { Color = 'blue' } },
    { Text = icon .. ' ' .. name .. ': ' .. label },
  })
end
```

Additionally you can expand on the [ssh domain](https://wezfurlong.org/wezterm/config/lua/wezterm/enumerate_ssh_hosts.html) documentation to create [exec domains](https://wezfurlong.org/wezterm/config/lua/ExecDomain.html?h=exec)
for your ssh hosts to enable pane splitting into them

```lua
local wezterm = require 'wezterm'

local ssh_domains = {}
local exec_domains = {}

for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
 
  -- ssh config
    ...

  -- exec ssh config      
  table.insert(exec_domains, 
    wezterm.exec_domain(
        "exec: " .. host,
        function(cmd)
            cmd.args = { "ssh", config.user .. "@" .. config.hostname }
            return cmd
        end
    )
  )
end

return {
  ssh_domains = ssh_domains,
  exec_domains = exec_domains,
}
```

### 🛠️ Defaults

These are the current default setting the can be overridden on your `apply_to_config` function

```lua 
{
  keys = {
    -- open domain in new tab
    attach = {
      -- mod keys for fuzzy domain finder
      mods = 'CTRL',
      -- base key for fuzzy domain finder
      key = 'd',
      -- key table to insert key map to if any
      tbl = '',
    },
    -- open domain in split pane 
    -- excludes remote domains
    -- add remote domains as exec domain for split binds
    vsplit = {
      key  = 'v',
      mods = 'CTRL',
      tbl  = ''
    },
    hsplit = {
      key  = 'h',
      mods = 'CTRL',
      tbl  = ''
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

This is the current default formatter function that can be overridden 

```lua 
domains.formatter = function(icon, name, _)
    return wezterm.format({ { Text = icon .. ' ' .. name } })
end
```
### 🔔 Events

`quick_domain.fuzzy_selector.opened`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |
| action    | Key name that triggered event |

`quick_domain.fuzzy_selector.selected`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |
| action    | Key name that triggered event |
| id        | Domain ID |

`quick_domain.fuzzy_selector.canceled`

| parameter | description |
|:----------|:------------|
| window    | MuxWindow Object |
| pane      | MuxPane Object   |
| action    | Key name that triggered event |
