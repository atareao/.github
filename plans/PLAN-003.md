# PLAN-003 — Fallback: keep-alive por cron externo

- **Issue:** https://github.com/atareao/.github/issues/5
- **Plan previo:** PLAN-002
- **Estado:** en curso (2026-11-09)

## Objetivo

Red de seguridad que **no dependa del scheduler de GitHub**: un cron externo que dispare `keepalive.yml` vía API, por si el auto-commit mensual resultara insuficiente.

## Mapa de arquitectura

```
cron externo (cron-job.org / UptimeRobot / co1)
     │  POST /repos/atareao/.github/actions/workflows/keepalive.yml/dispatches
     │  Authorization: Bearer <PAT fine-grained, Actions: write>
     └─► keepalive.yml (workflow_dispatch) ──► commit vacío ──► actividad del repo
```

## Tareas

- [ ] T1. Crear PAT fine-grained (`Actions: Read and write`, solo `atareao/.github`).
- [ ] T2. Registrar el cron externo (semanal o mensual).
- [ ] T3. Script de referencia `scripts/keepalive.sh`.
- [ ] T4. Documentar en `README.md`.

## Decisiones

- **Token mínimo**: PAT fine-grained limitado a un repo y al scope `Actions: write` (el mínimo para `workflow_dispatch`). No se usa un PAT clásico con `workflow`.
- **Servicio externo o cron propio**: indiferente; vale cron-job.org, UptimeRobot o un cron en `co1`.

## Follow-ups

- Rotar el PAT periódicamente.