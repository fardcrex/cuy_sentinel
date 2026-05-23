export interface AlertRecord {
  id: string;
  service_name: string;
  metric_name: string;
  current_value: number;
  threshold_value: number;
  severity: string;
  triggered_at: string;
}

export interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE';
  table: string;
  schema: string;
  record: AlertRecord | null;
  old_record: AlertRecord | null;
}

export async function parsePayload(req: Request): Promise<WebhookPayload | null> {
  try {
    return (await req.json()) as WebhookPayload;
  } catch {
    return null;
  }
}
