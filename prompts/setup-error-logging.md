# Setup Error Logging System

This prompt helps you set up a complete error logging system that works with the `/process-logs` command.

## What You'll Get

1. **Database table** for structured error logging
2. **Logger service** to capture errors from your app
3. **Admin UI** (optional) for viewing errors
4. **Auto-mute rules** for expected errors

---

## Step 1: Create Database Table

### For Supabase/PostgreSQL:

```sql
-- Create error_logs table
CREATE TABLE error_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),

  -- Error details
  error_message TEXT NOT NULL,
  stack_trace TEXT,
  severity TEXT CHECK (severity IN ('WARNING', 'ERROR', 'CRITICAL')) DEFAULT 'ERROR',

  -- Status tracking
  status TEXT CHECK (status IN ('new', 'in_progress', 'resolved', 'ignored', 'auto_muted')),
  notes TEXT,
  resolved_at TIMESTAMPTZ,

  -- Context (customize for your app)
  environment TEXT CHECK (environment IN ('dev', 'stage', 'prod')),
  user_id UUID,
  request_id TEXT,

  -- For API errors
  endpoint TEXT,
  input_data JSONB,

  -- For grouping similar errors
  fingerprint TEXT,

  -- Additional metadata
  metadata JSONB
);

-- Index for common queries
CREATE INDEX idx_error_logs_status ON error_logs(status);
CREATE INDEX idx_error_logs_severity ON error_logs(severity);
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at DESC);
CREATE INDEX idx_error_logs_fingerprint ON error_logs(fingerprint);

-- Enable RLS (adjust policies for your auth setup)
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Service role can do everything
CREATE POLICY "Service role full access" ON error_logs
  FOR ALL
  USING (auth.role() = 'service_role');

-- Policy: Authenticated admins can read
CREATE POLICY "Admins can read" ON error_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'superadmin')
    )
  );
```

### For Prisma:

```prisma
model ErrorLog {
  id           String    @id @default(uuid())
  createdAt    DateTime  @default(now())

  errorMessage String
  stackTrace   String?
  severity     String    @default("ERROR") // WARNING, ERROR, CRITICAL

  status       String?   // new, in_progress, resolved, ignored, auto_muted
  notes        String?
  resolvedAt   DateTime?

  environment  String?   // dev, stage, prod
  userId       String?
  requestId    String?

  endpoint     String?
  inputData    Json?

  fingerprint  String?
  metadata     Json?

  @@index([status])
  @@index([severity])
  @@index([createdAt])
  @@index([fingerprint])
}
```

---

## Step 2: Create Logger Service

### TypeScript (Node.js/Next.js):

```typescript
// lib/logger/error-service.ts

import crypto from 'crypto';

interface LogErrorParams {
  message: string;
  stack?: string;
  severity?: 'WARNING' | 'ERROR' | 'CRITICAL';
  environment?: string;
  userId?: string;
  requestId?: string;
  endpoint?: string;
  inputData?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
}

// Generate fingerprint for grouping similar errors
function generateFingerprint(message: string, stack?: string): string {
  const normalized = message
    // Replace UUIDs with placeholder
    .replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi, '<UUID>')
    // Replace timestamps
    .replace(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/g, '<TIMESTAMP>')
    // Replace large numbers
    .replace(/\b\d{3,}\b/g, '<NUM>')
    .trim()
    .toLowerCase();

  const firstStackLine = stack?.split('\n')[0] || '';

  return crypto
    .createHash('md5')
    .update(`${normalized}|||${firstStackLine}`)
    .digest('hex');
}

// Auto-mute rules for expected errors
const AUTO_MUTE_PATTERNS = [
  { pattern: /Redis connection (ended|closed)/i, reason: 'graceful_shutdown' },
  { pattern: /graceful.*shutdown/i, reason: 'graceful_shutdown' },
  { pattern: /\/health.*404/i, reason: 'monitoring_probe' },
  { pattern: /Cloudflare.*5\d{2}/i, reason: 'external_service' },
  { pattern: /ECONNRESET/i, reason: 'network_reset' },
];

function shouldAutoMute(message: string): { mute: boolean; reason?: string } {
  for (const rule of AUTO_MUTE_PATTERNS) {
    if (rule.pattern.test(message)) {
      return { mute: true, reason: rule.reason };
    }
  }
  return { mute: false };
}

export async function logError(params: LogErrorParams): Promise<void> {
  const fingerprint = generateFingerprint(params.message, params.stack);
  const autoMute = shouldAutoMute(params.message);

  const logData = {
    error_message: params.message,
    stack_trace: params.stack || null,
    severity: params.severity || 'ERROR',
    environment: params.environment || process.env.NODE_ENV,
    user_id: params.userId || null,
    request_id: params.requestId || null,
    endpoint: params.endpoint || null,
    input_data: params.inputData || null,
    fingerprint,
    status: autoMute.mute ? 'auto_muted' : null,
    notes: autoMute.mute ? `Auto-muted: ${autoMute.reason}` : null,
    metadata: params.metadata || null,
  };

  // For Supabase:
  // const { error } = await supabaseAdmin.from('error_logs').insert(logData);

  // For Prisma:
  // await prisma.errorLog.create({ data: logData });

  // Fallback: console log
  console.error('[ERROR_LOG]', JSON.stringify(logData, null, 2));
}

// Convenience wrappers
export const logger = {
  warning: (message: string, meta?: Partial<LogErrorParams>) =>
    logError({ message, severity: 'WARNING', ...meta }),

  error: (message: string, meta?: Partial<LogErrorParams>) =>
    logError({ message, severity: 'ERROR', ...meta }),

  critical: (message: string, meta?: Partial<LogErrorParams>) =>
    logError({ message, severity: 'CRITICAL', ...meta }),
};
```

### Usage in your app:

```typescript
// In API route
import { logger } from '@/lib/logger/error-service';

export async function POST(req: Request) {
  try {
    // ... your logic
  } catch (error) {
    await logger.error(error.message, {
      stack: error.stack,
      endpoint: '/api/users',
      inputData: await req.json(),
      requestId: req.headers.get('x-request-id'),
    });

    return Response.json({ error: 'Internal error' }, { status: 500 });
  }
}

// Global error handler (Next.js)
// app/error.tsx
'use client';

import { useEffect } from 'react';
import { logger } from '@/lib/logger/error-service';

export default function Error({ error, reset }) {
  useEffect(() => {
    logger.error(error.message, { stack: error.stack });
  }, [error]);

  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

---

## Step 3: Add Auto-Mute Rules (Optional)

Customize auto-mute patterns for your project:

```typescript
// lib/logger/auto-mute-rules.ts

export const AUTO_MUTE_RULES = [
  // Graceful Shutdown
  { pattern: /Redis connection (ended|closed)/i, reason: 'graceful_shutdown' },
  { pattern: /graceful.*shutdown/i, reason: 'graceful_shutdown' },

  // Monitoring Probes
  { pattern: /\/health.*404/i, reason: 'monitoring_probe' },
  { pattern: /\/api\/health/i, reason: 'monitoring_probe' },

  // External Services
  { pattern: /Cloudflare.*5\d{2}/i, reason: 'external_service' },
  { pattern: /ECONNRESET.*external/i, reason: 'external_service' },

  // Network Issues (transient)
  { pattern: /ETIMEDOUT/i, reason: 'network_timeout' },
  { pattern: /ECONNREFUSED/i, reason: 'network_refused' },

  // Add your project-specific rules here
  // { pattern: /your-expected-error/i, reason: 'your_reason' },
];
```

---

## Step 4: Verify Setup

Run these queries to verify everything works:

```sql
-- Check table exists
SELECT COUNT(*) FROM error_logs;

-- Insert test error
INSERT INTO error_logs (error_message, severity, environment)
VALUES ('Test error from setup', 'WARNING', 'dev');

-- Query new errors (what /process-logs sees)
SELECT id, severity, error_message, status, created_at
FROM error_logs
WHERE status IS NULL OR status NOT IN ('resolved', 'ignored', 'auto_muted')
ORDER BY created_at DESC
LIMIT 10;

-- Cleanup test
DELETE FROM error_logs WHERE error_message = 'Test error from setup';
```

---

## Step 5: Test /process-logs

After setup, run:

```
/process-logs
```

It should:
1. Query your error_logs table
2. Find any new errors
3. Analyze and fix them (or report if none found)

---

## Optional: Admin UI

For a simple admin view, create a page that:
1. Lists errors with filters (severity, status, date)
2. Shows error details (message, stack, metadata)
3. Allows status updates (mark as resolved, ignored)

See the full implementation in the article:
https://habr.com/ru/articles/XXXXX (link to your Habr article)

---

## Customization Checklist

- [ ] Adjust table/column names for your project
- [ ] Configure database connection (Supabase, Prisma, etc.)
- [ ] Add project-specific auto-mute rules
- [ ] Customize severity levels if needed
- [ ] Add relevant context fields (user_id, endpoint, etc.)
- [ ] Set up RLS policies for your auth system
