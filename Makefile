-include .env
export

TF := terraform -chdir=infra

tf/%: export CLOUDFLARE_API_TOKEN = $(TF_CLOUDFLARE_API_TOKEN)
repo/%: export CLOUDFLARE_API_TOKEN = $(WRANGLER_CLOUDFLARE_API_TOKEN)

.PHONY: tf/init tf/plan tf/apply key

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
