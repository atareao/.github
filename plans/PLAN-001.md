# PLAN-001 — Auto-asignar issues y avisar a Valet

- **Issue:** https://github.com/atareao/.github/issues/1
- **Repo anfitrión:** `atareao/.github` (público)
- **Estado:** en curso (2026-11-09)

## Objetivo

Que toda issue abierta en cualquier repo de `atareao` se me asigne automáticamente y que Valet me avise (bandeja + WebPush), con **una sola pieza central** en vez de un workflow por repo.

## Mapa de arquitectura

```
GitHub Actions (atareao/.github)
   cron */15  ──►  gh search: user:atareao is:issue is:open no:assignee
                        │
                        ├─► POST /repos/{repo}/issues/{n}/assignees   (asignar atareao)
                        │
                        └─► POST {VALET_URL}/api/notifications        (ingest key val_…)
                                   │
                                   └─► Valet: bandeja + WebPush
```

Componentes:
- `atareao/.github` — repo anfitrión, público (minutos de Actions ilimitados).
- Workflow programado `.github/workflows/auto-assign-issues.yml`.
- Valet — endpoint `POST /api/notifications` autenticado por ingest key.
- Secrets: `ISSUES_PAT`, `VALET_URL`, `VALET_INGEST_TOKEN`.

## Tareas

- [ ] T1. Crear repo `atareao/.github` (público). [issue #1]
- [ ] T2. Workflow `auto-assign-issues.yml` (cron */15 + workflow_dispatch).
- [ ] T3. Crear ingest key `github-issues` en Valet y guardar el token.
- [ ] T4. Definir secrets `ISSUES_PAT`, `VALET_URL`, `VALET_INGEST_TOKEN`.
- [ ] T5. `README.md` con setup, secrets y keep-alive.
- [ ] T6. Probar con `workflow_dispatch` y verificar asignación + aviso en Valet.
- [ ] T7. Keep-alive para el corte de 60 días de inactividad.

## Decisiones

- **Repo público**: minutos de Actions ilimitados; un cron */15 en privado (~2.880 min/mes) agotaría la cuota gratuita de 2.000 min.
- **Filtro `no:assignee` como estado**: sin base de datos; la 1ª pasada asigna lo pendiente y las siguientes solo lo nuevo.
- **Valet como canal de aviso**: la auto-asignación con el propio PAT no notifica en GitHub; el aviso fiable es Valet.
- **`curl` best-effort**: un fallo al avisar a Valet no rompe el job (warning, no error).

## Follow-ups

- Keep-alive (cron-job.org → `workflow_dispatch` vía API, o commit mensual).
- Acotar la 1ª pasada con `created:>AAAA-MM-DD` si el volumen inicial es alto.
- Rotar `ISSUES_PAT` y el ingest key periódicamente.