{{- define "trainers_comma_separated" -}}
    {{- if .Values.trainers -}}
        {{ printf ",%s" (join "," .Values.trainers) }}
    {{- else -}}
        {{ printf "" }}
    {{- end -}}
{{- end -}}