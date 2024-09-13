local wez = require 'wezterm'

local M = {}

local function kubernetes_pod_list()
  local pod_list = {}
  local success, stdout, stderr = wez.run_child_process {
    'kubectl',
    'get',
    'pods',
    '--no-headers',
    '--output',
    'custom-columns=ID:.metadata.uid,Name:.metadata.name'
  }

  if not success then
    wez.log_error("Failed to run 'kubectl': " .. (stderr or "unknown error"))
    return pod_list
  end

  for _, line in ipairs(wez.split_by_newlines(stdout)) do
    local id, name = line:match '(.-)%s+(.+)'
    if id and name then
      pod_list[id] = name
    end
  end
  return pod_list
end

local function make_kubernetes_label_func(id)
  return function(name)
    local _, stdout, _ = wez.run_child_process {
      'kubectl',
      'get',
      'pod',
      name,
      '--output',
      'jsonpath={.status.phase}'
    }
    return 'kubernetes pod named ' .. name
  end
end

local function make_kubernetes_exec_func(name, opts)
  return function(cmd)
    local wrapped = {
      'kubectl',
      'exec',
      '-it',
      name,
      '--',
      opts.kubernetes_shell or '/bin/bash',
    }
    cmd.args = wrapped
    return cmd
  end
end

local function docker_list()
  local container_list = {}
  local _, stdout, _ = wez.run_child_process {
    'docker',
    'container',
    'ls',
    '--format',
    '{{.ID}}:{{.Names}}',
  }
  for _, line in ipairs(wez.split_by_newlines(stdout)) do
    local id, name = line:match '(.-):(.+)'
    if id and name then
      container_list[id] = name
    end
  end
  return container_list
end

local function make_docker_label_func(id)
  return function(name)
    local _, stdout, _ = wez.run_child_process {
      'docker',
      'inspect',
      '--format',
      '{{.State.Running}}',
      id,
    }
    return 'docker container named ' .. name
  end
end

local function make_docker_fixup_func(id, opts)
  return function(cmd)
    local wrapped = {
      'docker',
      'exec',
      '-it',
      id,
      opts.docker_shell or '/bin/bash',
    }
    cmd.args = wrapped
    return cmd
  end
end

function M.compute_ssh_domains()
  local ssh_domains = {}
  for host, _ in pairs(wez.enumerate_ssh_hosts()) do
    table.insert(ssh_domains, {
      name = host,
      remote_address = host,
    })
  end
  return ssh_domains
end

function M.compute_exec_domains(opts)
  local exec_domains = {}
  if not opts.exec_ignore.docker then
    for id, name in pairs(docker_list()) do
      table.insert(
        exec_domains,
        wez.exec_domain(
          'docker:' .. name,
          make_docker_fixup_func(id, opts),
          make_docker_label_func(id)
        )
      )
    end
  end
  if not opts.exec_ignore.kubernetes then
    for id, name in pairs(kubernetes_pod_list()) do
      table.insert(
        exec_domains,
        wez.exec_domain(
          'kubernetes:' .. name,
          make_kubernetes_exec_func(name, opts),
          make_kubernetes_label_func(id)
        )
      )
    end
  end
  if not opts.exec_ignore.ssh then
    for host, config in pairs(wez.enumerate_ssh_hosts()) do
      table.insert(exec_domains,
        wez.exec_domain(
          "ssh:" .. host,
          function(cmd)
            cmd.args = { "ssh", config.user .. "@" .. config.hostname }
            return cmd
          end
        )
      )
    end
  end
  return exec_domains
end

return M
