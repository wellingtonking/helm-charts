{{/*
Render a single ArgoCD source block.

Usage:
  {{ include "applications_v2.source" (dict "source" $sourceObj "default" $.Values.default) }}

The helper is intentionally lenient: a key is only emitted when it has a
non-empty value, so any combination of source type and fields is safe.
*/}}
{{- define "applications.source" -}}
{{- $s := .source -}}
{{- $d := .default -}}
{{- /* ── chart (Helm registry / OCI) ──────────────────────────────────── */}}
{{- if $s.chart }}
chart: {{ $s.chart }}
{{- end }}
{{- /* ── helm ────────────────────────────────────────────────────────── */}}
{{- if $s.helm }}
{{- $helm := $s.helm }}
{{- $defValueFiles := dig "valuesFiles" (list) $d }}
helm:
  {{- if $helm.releaseName }}
  releaseName: {{ $helm.releaseName }}
  {{- end }}
  {{- if $helm.version }}
  version: {{ $helm.version }}
  {{- end }}
  {{- if $helm.passCredentials }}
  passCredentials: {{ $helm.passCredentials }}
  {{- end }}
  {{- if $helm.ignoreMissingValueFiles }}
  ignoreMissingValueFiles: {{ $helm.ignoreMissingValueFiles }}
  {{- end }}
  {{- if $helm.skipCrds }}
  skipCrds: {{ $helm.skipCrds }}
  {{- end }}
  {{- $valueFiles := default $defValueFiles $helm.valueFiles }}
  {{- if $valueFiles }}
  valueFiles:
    {{- $valueFiles | toYaml | nindent 4 }}
  {{- end }}
  {{- if $helm.values }}
  values: |
    {{- $helm.values | nindent 4 }}
  {{- end }}
  {{- if $helm.valuesObject }}
  valuesObject:
    {{- $helm.valuesObject | toYaml | nindent 4 }}
  {{- end }}
  {{- if $helm.parameters }}
  parameters:
    {{- $helm.parameters | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
{{- /* ── kustomize ────────────────────────────────────────────────────── */}}
{{- if $s.kustomize }}
kustomize:
  {{- $s.kustomize | toYaml | nindent 2 }}
{{- end }}
{{- /* ── directory ───────────────────────────────────────────────────── */}}
{{- if $s.directory }}
directory:
  {{- $s.directory | toYaml | nindent 2 }}
{{- end }}
{{- /* ── plugin ──────────────────────────────────────────────────────── */}}
{{- if $s.plugin }}
plugin:
  {{- $s.plugin | toYaml | nindent 2 }}
{{- end }}
{{- /* ── common source fields ───────────────────────────────────────── */}}
{{- if $s.path }}
path: {{ $s.path }}
{{- end }}
repoURL: {{ $s.repoURL }}
{{- if $s.ref }}
ref: {{ $s.ref }}
{{- end }}
targetRevision: {{ default (dig "spec" "source" "targetRevision" "HEAD" $d) $s.targetRevision }}
{{- end -}}

