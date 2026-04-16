RELEASE ?= test
CHART ?= .
NAMESPACE ?= cloudflare
TOKEN ?= "YOUR_TUNNEL_TOKEN"

test: lint validate clean

lint: lint-helm lint-yaml ct-lint

lint-helm:
	helm lint --strict .

lint-yaml:
	yamllint Chart.yaml values.yaml

ct-lint:
	ct lint --chart-dirs . --charts .

validate: validate-schema validate-api

validate-schema: output.nogit.yaml
	kubeconform -strict -summary -ignore-missing-schemas output.nogit.yaml

validate-api: output.nogit.yaml
	kube-linter lint output.nogit.yaml

output.nogit.yaml:
	helm template $(RELEASE) $(CHART) --namespace $(NAMESPACE) > output.nogit.yaml

clean:
	rm -f output.nogit.yaml

secret:
	kubectl -n $(NAMESPACE) create secret generic cloudflared-tunnel-token \
	--from-literal=token='$(TOKEN)'
	
