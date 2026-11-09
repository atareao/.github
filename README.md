# .github — automatizaciones de cuenta de atareao

Repo especial de cuenta. Contiene automatizaciones que aplican a **todos** los repos
de `atareao`, en lugar de un workflow por repo.

## Auto-asignar issues y avisar a Valet

Cada 15 minutos, el workflow [`auto-assign-issues.yml`](.github/workflows/auto-assign-issues.yml):

1. Busca toda issue abierta **sin asignar**: `user:atareao is:issue is:open no:assignee`.
2. Asigna `atareao` a cada resultado.
3. Envía un aviso a **Valet** (`POST /api/notifications`), que aparece en la bandeja y
   como WebPush.

El filtro `no:assignee` es el propio estado: la primera pasada asigna todo lo pendiente
y las siguientes solo cogen lo nuevo. No hay base de datos que mantener.

### Por qué un repo `.github` público

- **Minutos de Actions ilimitados** en repos públicos. Un cron `*/15` en un repo privado
  (~2.880 min/mes) agotaría la cuota gratuita (2.000 min/mes).
- Los secretos **no** van en el fichero del workflow: viven en *Settings → Secrets*.

### Secrets necesarios

| Secret | Qué es |
|---|---|
| `ISSUES_PAT` | Personal Access Token *fine-grained* con **Issues: Read & Write** + **Metadata: Read**, scope **All repositories**. |
| `VALET_URL` | URL base de Valet, sin barra final (p. ej. `https://valet.example.com`). |
| `VALET_INGEST_TOKEN` | Token `val_…` de un *ingest key* creado en Valet. |

### Crear el ingest key en Valet

Con una sesión OIDC válida (navegador o cookie):

```bash
curl -X POST https://valet.example.com/api/ingest-keys \
  --cookie "valet_session=<tu-cookie>" \
  -H "Content-Type: application/json" \
  -d '{"name":"github-issues"}'
# → { "id": "...", "prefix": "val_XXXXXXXX", "token": "val_...<se muestra 1 sola vez>" }
```

El `token` solo aparece en esa respuesta: guárdalo ya.

### Puesta en marcha

1. Crear el PAT fine-grained y guardarlo como secret `ISSUES_PAT`.
2. Definir `VALET_URL` y `VALET_INGEST_TOKEN`.
3. Ejecutar el workflow con **Run workflow** (`workflow_dispatch`) para probar.
4. Suscribirse a WebPush en Valet (navegador) para recibir push además de la bandeja.

### Caveats

- **Corte a 60 días:** GitHub desactiva los workflows programados tras 60 días sin
  actividad del repo. **Cubierto por `keepalive.yml`** (ver más abajo).
- **Primera ejecución:** asigna *todas* las issues abiertas sin asignar. Para acotar,
  añade `created:>AAAA-MM-DD` a `SEARCH_QUERY`.
- **La auto-asignación no notifica:** al hacerla tu propio PAT, GitHub no te avisa; el
  aviso fiable es el de Valet.
- **Valet debe ser alcanzable** desde los runners de GitHub (el `APP_HOST` tras Traefik
  lo es).

## Keep-alive (corte a 60 días)

GitHub desactiva los workflows programados tras **60 días sin actividad** del repo. Como
este repo solo tiene config, [`keepalive.yml`](.github/workflows/keepalive.yml) empuja
**un commit vacío al mes**: así siempre hay actividad dentro de la ventana y ningún cron
se desactiva. Es auto-sostenible (corre cada 30 días < 60).

### Fallback: cron externo

Red de seguridad que no depende del scheduler de GitHub. Un cron externo (cron-job.org,
UptimeRobot, o un cron en `co1`) dispara el workflow vía API:

1. Crea un PAT **fine-grained** con permiso **Actions: Read and write**, limitado **solo**
   al repo `atareao/.github`.
2. Registra el cron (semanal o mensual) que ejecute:

```bash
curl -fsS -X POST \
  -H "Authorization: Bearer <PAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/atareao/.github/actions/workflows/keepalive.yml/dispatches \
  -d '{"ref":"main"}'
```

Script listo para usar: [`scripts/keepalive.sh`](scripts/keepalive.sh).

> El PAT solo necesita `Actions: write`; guárdalo en el servicio externo como secreto y
> rótalo de vez en cuando.
