-include .env
export

TF := terraform -chdir=infra
WRANGLER ?= wrangler

tf/%: export CLOUDFLARE_API_TOKEN = $(TF_CLOUDFLARE_API_TOKEN)
web/%: export CLOUDFLARE_API_TOKEN = $(PAGES_CLOUDFLARE_API_TOKEN)

.PHONY: tf/init tf/plan tf/apply key repo/index repo/publish web/build web/deploy

tf/init:
	$(TF) init

tf/plan: tf/init
	$(TF) plan -out=tfplan

tf/apply:
	$(TF) apply tfplan

pkg/%:
	./scripts/build.sh $*

key:
	./scripts/gen-key.sh

repo/index:
	./scripts/index.sh

repo/publish:
	./scripts/publish.sh

web/build:
	./scripts/web.py

web/deploy: web/build
	$(WRANGLER) pages deploy build/web --project-name debs --branch main
