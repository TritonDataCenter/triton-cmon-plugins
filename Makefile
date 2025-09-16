# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Copyright 2025 Edgecast Cloud LLC.

export GOPATH   = $(PWD)/deps/go
export PATH    := $(PWD)/mock:$(GOPATH)/bin:$(PATH)
export COPYFILE_DISABLE=true

PREFIX          = cmon
DESTDIR         = proto

ARCHIVE         = cmon-plugins.tar.gz
RAW_PLUGINS     = $(shell find gz-plugins vm-plugins -type f -name '*.prom')
ALL_PLUGINS     = $(shell find gz-plugins vm-plugins -type f)
VERSION         = $(shell git tag --sort=taggerdate | tail -1)
GITREV          = $(shell git rev-parse HEAD 2>/dev/null)

.PHONY: all check clean deps mrclean version

all: cmon-plugins.tar.gz

version: .version
.version: $(ALL_PLUGINS)
	printf '%s\n%s\n' $(VERSION) $(GITREV) > .version

$(ARCHIVE): .version
	mkdir -p proto/cmon
	rsync -av ./gz-plugins ./vm-plugins $(DESTDIR)/$(PREFIX)/
	cp .version $(DESTDIR)/$(PREFIX)
	sh -c "tar zcf cmon-plugins.tar.gz -C $(DESTDIR) $(PREFIX)"

release: clean .version $(ARCHIVE)
	hub release create -d -a $(ARCHIVE) $(VERSION)

deps: deps/go/bin/promtool

deps/go/bin/promtool:
	@mkdir -p $(GOPATH)
	sh -c "go get github.com/prometheus/prometheus/cmd/promtool"

check: deps
	@[[ -d gz-plugins ]] || mkdir gz-plugins
	@[[ -d vm-plugins ]] || mkdir vm-plugins
	@sh -c "find gz-plugins vm-plugins -type f -name '*.prom' -exec tools/promlint {} +"

clean:
	rm -f $(ARCHIVE)
	rm -rf proto

mrclean: clean
	rm -rf deps
