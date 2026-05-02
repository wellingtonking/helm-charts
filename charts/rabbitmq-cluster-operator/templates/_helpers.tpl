{{/*
Expand the name of the chart.
*/}}
{{- define "rabbitmq-cluster-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "rabbitmq-cluster-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
The namespace where operator resources are deployed.
*/}}
{{- define "rabbitmq-cluster-operator.namespace" -}}
{{- .Values.namespace | default "rabbitmq-system" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "rabbitmq-cluster-operator.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "rabbitmq-cluster-operator.selectorLabels" . }}
app.kubernetes.io/component: rabbitmq-operator
app.kubernetes.io/part-of: rabbitmq
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used in matchLabels and Pod selectors).
*/}}
{{- define "rabbitmq-cluster-operator.selectorLabels" -}}
app.kubernetes.io/name: rabbitmq-cluster-operator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "rabbitmq-cluster-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default "rabbitmq-cluster-operator" }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
The operator container image reference.
*/}}
{{- define "rabbitmq-cluster-operator.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

