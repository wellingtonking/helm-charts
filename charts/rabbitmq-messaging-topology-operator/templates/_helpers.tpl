{{/*
Expand the name of the chart.
*/}}
{{- define "rabbitmq-messaging-topology-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "rabbitmq-messaging-topology-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
The namespace where operator resources are deployed.
*/}}
{{- define "rabbitmq-messaging-topology-operator.namespace" -}}
{{- .Values.namespace | default "rabbitmq-system" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "rabbitmq-messaging-topology-operator.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "rabbitmq-messaging-topology-operator.selectorLabels" . }}
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
{{- define "rabbitmq-messaging-topology-operator.selectorLabels" -}}
app.kubernetes.io/name: messaging-topology-operator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Labels for Services that must also match the Deployment selector.
The Deployment selector uses only app.kubernetes.io/name (without instance),
so the Service selector must match that exact set.
*/}}
{{- define "rabbitmq-messaging-topology-operator.serviceSelectorLabels" -}}
app.kubernetes.io/name: messaging-topology-operator
control-plane: controller-manager
{{- end }}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "rabbitmq-messaging-topology-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default "messaging-topology-operator" }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
The operator container image reference.
*/}}
{{- define "rabbitmq-messaging-topology-operator.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Name of the cert-manager Issuer to reference.
Falls back to the self-signed issuer created by this chart.
*/}}
{{- define "rabbitmq-messaging-topology-operator.issuerName" -}}
{{- .Values.certManager.issuerName | default "messaging-topology-selfsigned-issuer" }}
{{- end }}

