# Translator-Broker's Helm Chart


# Installation

```shell
helm install -n translator translator wellingtonking/translator-broker
```

```shell
helm install \
	-n translator \
	--set deepl.api_key.secrets_name=my-deepl-secret \
	--set deepl.api_key.secrets_key=api_key \
	--set deepl.api_url.secrets_name=my-deepl-secret \
	--set deepl.api_url.secrets_key=api_url \
	translator wellingtonking/translator-broker
```

## DeepL Example Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-deepl-secret
type: Opaque
stringData:
  api_url: https://api.deepl.com/v2
  api_key: aabbccdd-eeff-gghh-iijj-kkllmmnnoopp
```

## Google Application Key Example Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-google-secret
type: Opaque
stringsData:
  api_key: foobarbaz123123123123
```