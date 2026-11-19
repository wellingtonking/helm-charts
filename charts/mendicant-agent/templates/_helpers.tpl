{{- define "mendicant-agent.validateCache" -}}
{{- $unit := regexFind "(Mi|Gi|Ti)$" .Values.cache.size -}}
{{- $number := int64 (regexFind "^[0-9]+" .Values.cache.size) -}}
{{- $factor := index (dict "Mi" 1048576 "Gi" 1073741824 "Ti" 1099511627776) $unit -}}
{{- $physical := mul $number $factor -}}
{{- if or (lt (int64 .Values.cache.maxBytes) 1) (gt (int64 .Values.cache.maxBytes) 1099511627776) -}}
{{- fail "cache.maxBytes must be a positive decimal string no greater than 1 TiB" -}}
{{- end -}}
{{- if lt $physical (add (int64 .Values.cache.maxBytes) 67108864) -}}
{{- fail "cache.size must exceed cache.maxBytes by at least 64 MiB" -}}
{{- end -}}
{{- if and (eq .Values.cache.mode "emptyDir") .Values.cache.existingClaim -}}
{{- fail "cache.existingClaim requires cache.mode=pvc" -}}
{{- end -}}
{{- end -}}
