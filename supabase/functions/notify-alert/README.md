# notify-alert

Edge Function de Supabase que recibe un Database Webhook al insertar en `alert_events`
y envía una notificación a Telegram vía Bot API.

## Estructura

```
notify-alert/
  index.ts      # entry point — validación y orquestación
  _types.ts     # interfaces WebhookPayload y AlertRecord
  _format.ts    # formateo del mensaje (emojis, etiquetas de métricas)
  _telegram.ts  # cliente HTTP de Telegram
```

## Requisitos previos

```sh
brew install supabase/tap/supabase deno
supabase login
supabase link --project-ref <PROJECT_REF>   # Settings → General → Reference ID
```

## Secrets

```sh
# Copiar plantilla y completar con valores reales
cp supabase/secrets.example supabase/secrets.env

# Subir secrets a Supabase
bash supabase/secrets.env
```

| Secret               | Descripción                                          |
|----------------------|------------------------------------------------------|
| `TELEGRAM_BOT_TOKEN` | Token del bot (BotFather)                            |
| `TELEGRAM_CHAT_ID`   | ID del chat o grupo que recibirá las notificaciones  |
| `WEBHOOK_SECRET`     | Cadena aleatoria — generada con `openssl rand -hex 32` |

## Deploy

```sh
supabase functions deploy notify-alert --no-verify-jwt
```

## Configurar el Database Webhook

1. Supabase dashboard → **Database → Database Webhooks → Create**
2. Completar el formulario:

| Campo         | Valor                                        |
|---------------|----------------------------------------------|
| Name          | `on_alert_insert`                            |
| Table         | `alert_events`                               |
| Events        | ✅ Insert                                    |
| Type          | Supabase Edge Functions                      |
| Edge Function | `notify-alert`                               |

3. En **HTTP Headers** agregar:

| Name               | Value                         |
|--------------------|-------------------------------|
| `x-webhook-secret` | el valor de `WEBHOOK_SECRET`  |

## Probar manualmente

Insertar una fila en `alert_events` desde el Table Editor de Supabase.
El mensaje llega a Telegram en segundos. Si no llega, revisar:

```
Edge Functions → notify-alert → Logs
```

## Mensaje de ejemplo

```
🔴 Alerta CRITICAL — Passbolt

📊 Métrica: CPU
📈 Valor actual: 95.5
🚧 Umbral: 90
🕒 Hora: 20/05/2026, 14:32:10
```
