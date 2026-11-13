{{- define "mendicant.image" -}}
{{ .Values.image.repository }}@{{ required "image.digest must identify a published immutable image" .Values.image.digest }}
{{- end -}}
{{- define "mendicant.labels" -}}
app.kubernetes.io/name: mendicant-server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
