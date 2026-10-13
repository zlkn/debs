-include .env
export

TF := terraform -chdir=infra

.PHONY: tf/init tf/plan tf/apply

tf/init:
	$(TF) init

tf/plan: tf/init
	$(TF) plan -out=tfplan

tf/apply:
	$(TF) apply tfplan

pkg/%:
	./scripts/build.sh $*
