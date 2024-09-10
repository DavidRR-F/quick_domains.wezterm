local wez = require "wezterm"
local act = wez.action

local pub = {}

local default_settings = {
  keys = {
    attach = {
      mods = 'CTRL',
      key = 'd',
      tbl = '',
    }
  },
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

local function contains_ignore_case(str, pattern)
  return string.find(string.lower(str), string.lower(pattern)) ~= nil
end

local function get_domains(opts)
  local domains = {}
  local all_domains = wez.mux.all_domains()

  for _, domain in ipairs(all_domains) do
    local name = domain:name()
    local label = domain:label()
    local icon = ''
    for domain_type, icon_key in pairs(opts.icons) do
      if contains_ignore_case(label, domain_type) then
        icon = icon_key
        break
      end
    end

    if name ~= "TermWizTerminalDomain" then
      table.insert(domains, {
        label = icon .. ' ' .. name,
        id = name,
      })
    end
  end

  return domains
end

local function get_action(domain, action)
  local actions = {
    attach = act.SpawnCommandInNewTab { domain = { DomainName = domain } },
  }

  return actions[action]
end

local function fuzzy_attach_to_domain(opts, action)
  return wez.action_callback(function(window, pane)
    local choices = get_domains(opts)
    wez.emit('quick_domain.fuzzy_selector.opened', window, pane, action)
    window:perform_action(
      act.InputSelector({
        action = wez.action_callback(function(window, pane, id, label)
          if id then
            window:perform_action(
              get_action(id, action),
              pane
            )
            wez.emit('quick_domain.fuzzy_selector.selected', window, pane, action, id)
          else
            wez.emit('quick_domain.fuzzy_selector.canceled', window, pane, action)
          end
        end),
        title = "Choose SSH Host",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = opts.icons.hosts .. " " .. "Hosts: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

function pub.apply_to_config(config, user_settings)
  local opts = setmetatable(user_settings or {}, { __index = default_settings })
  for name, key in pairs(opts.keys) do
    if key.tbl ~= '' then
      config.key_tables = config.key_tables or {}
      config.key_tables[key.tbl] = config.key_tables[key.tbl] or {}
      table.insert(config.key_tables[key.tbl],
        { key = key.key, mods = key.mods, action = fuzzy_attach_to_domain(opts, name) })
    else
      config.keys = config.keys or {}
      table.insert(config.keys, { key = key.key, mods = key.mods, action = fuzzy_attach_to_domain(opts, name) })
    end
  end
end

return pub
