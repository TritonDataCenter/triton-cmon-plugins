<!-- This Source Code Form is subject to the terms of the Mozilla Public
   - License, v. 2.0. If a copy of the MPL was not distributed with this
   - file, You can obtain one at https://mozilla.org/MPL/2.0/. -->

<!--
   - Copyright 2025 Edgecast Cloud LLC.
   -->

# triton-cmon-plugins

These plugins are for the [Triton][triton] [Container Monitor][cmon] system.

These are unofficial. They are used in Edgecast's production infrastructure but
may or may not work with your system. A valid workaround for you might be to
install to an alternate location and symlink the plug-ins you wish to use.

[triton]: https://github.com/tritondatacenter/triton
[cmon]: https://github.com/tritondatacenter/triton-cmon

## Installing

To install the plugins, download the latest version, copy it out to all compute
nodes, and extract it to `/opt/custom/cmon`.

Run these commands from your `headnode`.

    mkdir -p /opt/custom
    latest=$(curl -s https://api.github.com/repos/tritondatacenter/triton-cmon-plugins/releases/latest | json assets.0.browser_download_url)
    curl -o /tmp/cmon-plugins.tar.gz -L "$latest"
    sdc-oneachnode -c -X -g /tmp/cmon-plugins.tar.gz -d /tmp
    sdc-oneachnode -a 'mkdir -p /opt/custom ; gtar zxf /tmp/cmon-plugins.tar.gz --no-same-owner -C /opt/custom'

## Using

Once the plugins are installed, they'll show up automatically by polling CMON.
See the [CMON documentation][cmon-doc] for an example. Note that for global-zone
metrics, you need to use `file_sd` with a JSON file of targets.

[cmon-doc]: https://github.com/joyent/triton-cmon/blob/master/docs/INSTALLING.md#sample-prometheus-server

## Building

Just run `make` to produce a tar.

## Developing

See the [`triton-cmon-agent`][agent-docs] documentation for developing plug-ins.

Prefer making plugins with `.prom` extension so that they can be checked with
`promtool`.

Before committing, your plugin should be lint clean with whatever language you
used to develop it (e.g., `jsvascriptlint`, `shellcheck`, `clippy`) and pass
`make check` which lints plugin output. 

### Prerequisites for Development

To use `make check`, you'll need `promtool` installed in your PATH. Since `go get` 
outside of a module is deprecated, install it manually:

    go install github.com/prometheus/prometheus/cmd/promtool@latest

See: https://pkg.go.dev/github.com/prometheus/prometheus/cmd/promtool

If you use external commands that may not be present or functional in a 
development environment, or may be dangerous to run (for whatever reason...), 
also create an appropriate `mock` tool to simulate its output for use with 
`make check`.

[agent-docs]: https://github.com/joyent/triton-cmon-agent/tree/master/docs#plugins

## Releasing

Run `make release` and a new release will be created and pushed to GitHub.
You'll need the `hub` command, and be a member of the Joyent organization.
