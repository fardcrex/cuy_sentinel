const TELEGRAM_API = 'https://api.telegram.org';

export class TelegramClient {
  readonly #botToken: string;
  readonly #chatId: string;

  constructor(botToken: string, chatId: string) {
    this.#botToken = botToken;
    this.#chatId = chatId;
  }

  async sendMessage(text: string): Promise<void> {
    const res = await fetch(
      `${TELEGRAM_API}/bot${this.#botToken}/sendMessage`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: this.#chatId,
          text,
          parse_mode: 'Markdown',
        }),
      },
    );

    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Telegram API ${res.status}: ${body}`);
    }
  }
}
