local wez = require "wezterm"

local separator = package.config:sub(1, 1) == "\\" and "\\" or "/"
local plugin_dir = wez.plugin.list()[1].plugin_dir:gsub(separator .. "[^" .. separator .. "]*$", "")

--- Checks if the plugin directory exists
local function directory_exists(path)
  local success, result = pcall(wez.read_dir, plugin_dir .. path)
  return success and result
end

--- Returns the name of the package, used when requiring modules
local function get_require_path()
  local path = "httpssCssZssZsgithubsDscomsZsDavidRR-FsZsquick_domainssDswezterm"
  local path_trailing_slash = "httpssCssZssZsgithubsDscomsZsDavidRR-FsZsquick_domainssDsweztermsZs"
  return directory_exists(path_trailing_slash) and path_trailing_slash or path
end

package.path = package.path
    .. ";"
    .. plugin_dir
    .. separator
    .. get_require_path()
    .. separator
    .. "plugin"
    .. separator
    .. "?.lua"

local domains = require 'utils.domains'
local act = wez.action

local pub = {
  formatter = function(icon, name, _)
    return wez.format({ { Text = icon .. ' ' .. name } })
  end,
}

local default_settings = {
  keys = {
    attach = {
      mods = 'CTRL',
      key = 'd',
      tbl = '',
    },
    vsplit = {
      mods = 'CTRL',
      key = 'v',
      tbl = '',
    },
    hsplit = {
      mods = 'CTRL',
      key = 'h',
      tbl = '',
    },
  },
  icons = {
    hosts = '',
    ssh = '󰣀',
    tls = '󰢭',
    exec = '',
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
  },
  auto = {
    ssh_ignore = true,
    exec_ignore = {
      ssh = true,
      docker = true,
      kubernetes = true,
    }
  },
  kubernetes_shell = '/bin/bash',
  docker_shell = '/bin/bash',
}

local function contains_ignore_case(str, pattern)
  return string.find(string.lower(str), string.lower(pattern)) ~= nil
end

local function is_remote_domain(domain)
  local remote_domains = { 'ssh mux', 'tls mux', 'unix mux' }
  for _, domain_type in ipairs(remote_domains) do
    if contains_ignore_case(domain:label(), domain_type) then
      return true
    end
  end
  return false
end

local function filter_remote_domains(domains)
  local filtered = {}
  for _, domain in ipairs(domains) do
    if not is_remote_domain(domain) then
      table.insert(filtered, domain)
    end
  end
  return filtered
end

local function get_choices(domains, opts)
  local choices = {}
  for _, domain in ipairs(domains) do
    local name = domain:name()
    local label = domain:label()
    local icon = ''
    for domain_type, icon_key in pairs(opts.icons) do
      if contains_ignore_case(label, domain_type) then
        icon = icon_key
        break
      end
    end

    if name ~= "TermWizTerminalDomain" then
      table.insert(choices, {
        label = pub.formatter(icon, name, label),
        id = name,
      })
    end
  end
  return choices
end

local function get_local_domains(opts)
  local all_domains = wez.mux.all_domains()
  all_domains = filter_remote_domains(all_domains)
  return get_choices(all_domains, opts)
end

local function get_all_domains(opts)
  local all_domains = wez.mux.all_domains()
  return get_choices(all_domains, opts)
end

local function fuzzy_attach_tab(opts)
  return wez.action_callback(function(window, pane)
    local choices = get_all_domains(opts)
    wez.emit('quick_domain.fuzzy_selector.opened', window, pane)
    window:perform_action(
      act.InputSelector({
        action = wez.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              act.SpawnCommandInNewTab { domain = { DomainName = id } },
              inner_pane
            )
            wez.emit('quick_domain.fuzzy_selector.selected', window, pane, id)
          else
            wez.emit('quick_domain.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Domain",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = opts.icons.hosts .. " " .. "Domains: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

local function fuzzy_attach_vsplit(opts)
  return wez.action_callback(function(window, pane)
    local choices = get_local_domains(opts)
    wez.emit('quick_domain.fuzzy_selector.opened', window, pane)
    window:perform_action(
      act.InputSelector({
        action = wez.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              act.SplitVertical { domain = { DomainName = id } },
              inner_pane
            )
            wez.emit('quick_domain.fuzzy_selector.selected', window, pane, id)
          else
            wez.emit('quick_domain.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Domain",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = opts.icons.hosts .. " " .. "Domains: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

local function fuzzy_attach_hsplit(opts)
  return wez.action_callback(function(window, pane)
    local choices = get_local_domains(opts)
    wez.emit('quick_domain.fuzzy_selector.opened', window, pane)
    window:perform_action(
      act.InputSelector({
        action = wez.action_callback(function(inner_window, inner_pane, id, _)
          if id then
            inner_window:perform_action(
              act.SplitHorizontal { domain = { DomainName = id } },
              inner_pane
            )
            wez.emit('quick_domain.fuzzy_selector.selected', window, pane, id)
          else
            wez.emit('quick_domain.fuzzy_selector.canceled', window, pane)
          end
        end),
        title = "Choose Domain",
        description = "Select a host and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = opts.icons.hosts .. " " .. "Domains: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

local function all_true(tbl)
  for _, value in pairs(tbl) do
    if not value then
      return false
    end
  end
  return true
end

local function deep_setmetatable(user, default)
  user = user or {}
  for k, v in pairs(default) do
    if type(v) == "table" then
      user[k] = deep_setmetatable(user[k], v)
    else
      if user[k] == nil then
        user[k] = v
      end
    end
  end

  return user
end

function pub.apply_to_config(config, user_settings)
  local opts = deep_setmetatable(user_settings or {}, default_settings)

  if not opts.auto.ssh_ignore then
    config.ssh_domains = domains.compute_ssh_domains()
  end

  if not all_true(opts.auto.exec_ignore) then
    config.exec_domains = domains.compute_exec_domains(opts)
  end

  local actions = {
    attach = fuzzy_attach_tab(opts),
    vsplit = fuzzy_attach_vsplit(opts),
    hsplit = fuzzy_attach_hsplit(opts),
  }

  for name, key in pairs(opts.keys) do
    if key.tbl ~= '' then
      config.key_tables = config.key_tables or {}
      config.key_tables[key.tbl] = config.key_tables[key.tbl] or {}
      table.insert(config.key_tables[key.tbl],
        { key = key.key, mods = key.mods, action = actions[name] })
    else
      config.keys = config.keys or {}
      table.insert(config.keys, { key = key.key, mods = key.mods, action = actions[name] })
    end
  end
end

return pub
