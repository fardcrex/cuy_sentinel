import { formatAlertMessage } from './_format.ts';
import { TelegramClient } from './_telegram.ts';
import { parsePayload } from './_types.ts';

Deno.serve(async (req: Request): Promise<Response> => {
  const webhookSecret = Deno.env.get('WEBHOOK_SECRET');
  if (webhookSecret && req.headers.get('x-webhook-secret') !== webhookSecret) {
    return new Response('Unauthorized', { status: 401 });
  }

  const payload = await parsePayload(req);

  if (!payload) return new Response('Bad Request', { status: 400 });

  if (payload.type !== 'INSERT' || payload.table !== 'alert_events' || !payload.record) {
    return new Response('Ignored', { status: 200 });
  }

  const botToken = Deno.env.get('TELEGRAM_BOT_TOKEN');
  const chatId = Deno.env.get('TELEGRAM_CHAT_ID');

  if (!botToken || !chatId) {
    console.error('Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID');
    return new Response('Telegram not configured', { status: 500 });
  }

  try {
    const telegram = new TelegramClient(botToken, chatId);

    await telegram.sendMessage(formatAlertMessage(payload.record));

    return new Response('OK', { status: 200 });
  } catch (err) {
    console.error(err);
    return new Response('Internal error', { status: 502 });
  }
});
