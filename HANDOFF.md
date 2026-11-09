# HANDOFF

## Estado (2026-11-09)

Repo `atareao/.github` (público, default `main`). Automatización de cuenta:

- `auto-assign-issues.yml` — cron `*/15`: asigna `atareao` a toda issue abierta sin
  asignar y avisa a Valet (`POST /api/notifications`). Probado; **0 issues sin asignar**.
- `keepalive.yml` — cron mensual: commit vacío que evita el corte de 60 días.
- Secrets configurados: `ISSUES_PAT`, `VALET_URL`, `VALET_INGEST_TOKEN`.

Planes: `PLAN-001-ARCHIVED.md`, `PLAN-002-ARCHIVED.md`, `PLAN-003.md` (activo).

## Pendiente (retomar)

**Issue #5 — PLAN-003: registrar el cron externo (fallback del keep-alive).** Pasos manuales:

1. Crear un PAT fine-grained con `Actions: Read and write`, limitado al repo `atareao/.github`.
2. Registrar un cron externo (cron-job.org / UptimeRobot / `co1`) que ejecute
   `scripts/keepalive.sh` (o el `curl` del README, sección «Fallback: cron externo»).
3. Cerrar la issue #5.

No es bloqueante: `keepalive.yml` ya cubre el caso normal.

## Notas

- `SEARCH_QUERY` sin filtro de fecha: `no:assignee` limita el trabajo a lo pendiente.
  Para un arranque suave, añadir `created:>AAAA-MM-DD`.
- Al fusionar PRs con `gh`: esperar unos segundos tras `gh pr create` antes de
  `gh pr merge` (si no, falla en silencio porque la mergeabilidad aún no está calculada).
- El PR #10 arregló un bug de paginación: recolectar todas las páginas **antes** de mutar.
