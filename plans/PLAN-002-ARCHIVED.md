# PLAN-002 — Keep-alive del workflow programado

- **Issue:** https://github.com/atareao/.github/issues/2
- **Plan previo:** PLAN-001
- **Estado:** completado (2026-11-09) · archivado

## Problema

GitHub **desactiva automáticamente los workflows programados** cuando el repositorio lleva **60 días sin actividad** (sin commits/pushes). Un repo como `atareao/.github`, que solo contiene config, es candidato perfecto a quedarse sin actividad y perder el cron de auto-asignación.

## Solución

Un segundo workflow programado, `keepalive.yml`, que **una vez al mes** empuja un commit vacío. Así el repositorio siempre tiene actividad dentro de la ventana de 60 días y **ninguno de los dos crons se desactiva**.

Es auto-sostenible: como el keep-alive corre cada 30 días (< 60), su propio cron nunca se desactiva, y mantiene vivo también al de auto-asignación.

## Mapa de arquitectura

```
cron "17 6 1 * *" (mensual)  ──►  keepalive.yml
                                     │  git commit --allow-empty
                                     └─► push a main  ──► actividad del repo
                                                             │
                                                            │
                                   (resetea el contador de 60 días de inactividad)
                                                             │
                                   mantiene habilitado auto-assign-issues.yml
```

## Tareas

- [x] T1. Workflow `.github/workflows/keepalive.yml` (cron mensual + `workflow_dispatch`).
- [x] T2. Permisos `contents: write` y commit vacío con identidad de bot.
- [x] T3. Documentar el keep-alive en `README.md`.
- [x] T4. Verificar con `workflow_dispatch` que empuja el commit.

## Alternativa (más a prueba de balas)

Un cron externo (p. ej. cron-job.org / UptimeRobot) que llame a `POST /repos/atareao/.github/actions/workflows/keepalive.yml/dispatches` con un PAT fine-grained (`Actions: write`, solo este repo). No depende de que el repo tenga actividad. Se documenta como fallback por si el auto-commit resultara insuficiente.

## Decisiones

- **Auto-commit mensual** en vez de cron externo: cero dependencias de terceros y cero secretos extra. El cron externo queda documentado como fallback.
- **Commit vacío** (`--allow-empty`): no ensucia el árbol con ficheros, pero sí cuenta como actividad.
- **`GITHUB_TOKEN`**, no PAT: el push no necesita scope extra, solo `contents: write`.

## Follow-ups

- Si en la práctica el auto-commit no resetea el contador, montar el fallback externo.
