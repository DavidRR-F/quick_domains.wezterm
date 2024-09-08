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
  }
}

local function get_ssh_domains(opts)
  local ssh = {}

  for host, _ in pairs(wez.enumerate_ssh_hosts()) do
    table.insert(ssh, {
      label = opts.icons.ssh .. ' ' .. host,
      id = host,
    })
  end

  return ssh
end

local function get_choices(opts)
  -- for later to concat other domain tables
  local sessions = get_ssh_domains(opts)
  return sessions
end

local function fuzzy_attach_to_domain(opts)
  return wez.action_callback(function(window, pane)
    local choices = get_choices(opts)

    window:perform_action(
      act.InputSelector({
        action = wez.action_callback(function(window, pane, id, label)
          if id then
            window:perform_action(
              act.AttachDomain(id),
              pane
            )
            window:perform_action(act.SetPaneSize { 'Rows', 1000 }, pane)
            window:perform_action(act.SetPaneSize { 'Columns', 1000 }, pane)
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
  local keys = {
    {
      key = opts.keys.attach.key,
      mods = opts.keys.attach.mods,
      tbl = opts.keys.attach.tbl,
      action = fuzzy_attach_to_domain(opts)
    },
  }
  for _, key in ipairs(keys) do
    if key.tbl ~= '' then
      config.key_tables = config.key_tables or {}
      config.key_tables[key.tbl] = config.key_tables[key.tbl] or {}
      table.insert(config.key_tables[key.tbl], { key = key.key, mods = key.mods, action = key.action })
    else
      config.keys = config.keys or {}
      table.insert(config.keys, { key = key.key, mods = key.mods, action = key.action })
    end
  end
end

return pub
