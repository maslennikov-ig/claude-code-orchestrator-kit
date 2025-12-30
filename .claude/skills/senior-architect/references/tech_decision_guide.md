# Tech Decision Guide

Decision frameworks and comparison matrices for choosing technologies in the MegaCampusAI stack.

## Database Selection

### Comparison Matrix

| Criteria | PostgreSQL (Supabase) | MongoDB | Redis | SQLite |
|----------|----------------------|---------|-------|--------|
| **ACID compliance** | ✅ Full | ⚠️ Limited | ❌ No | ✅ Full |
| **Schema flexibility** | ⚠️ Rigid | ✅ Very flexible | ✅ Schemaless | ⚠️ Rigid |
| **Query performance** | ✅ Excellent | ✅ Good | ✅ Excellent | ✅ Good |
| **Scalability** | ✅ Vertical + Horizontal | ✅ Horizontal | ✅ Horizontal | ❌ Single file |
| **RLS (Row Level Security)** | ✅ Native | ❌ No | ❌ No | ❌ No |
| **Full-text search** | ✅ Built-in | ✅ Built-in | ❌ No | ✅ FTS5 |
| **JSON support** | ✅ JSONB | ✅ Native | ✅ JSON | ✅ JSON1 |
| **Real-time subscriptions** | ✅ Supabase | ✅ Change streams | ✅ Pub/Sub | ❌ No |
| **Cost (managed)** | $$ | $$ | $ | Free (self-hosted) |

### Decision Tree

```
Do you need ACID transactions?
├─ YES → PostgreSQL or SQLite
│  └─ Do you need multi-tenant security (RLS)?
│     ├─ YES → PostgreSQL (Supabase)
│     └─ NO → SQLite (local) or PostgreSQL
│
└─ NO → MongoDB or Redis
   └─ Do you need persistence?
      ├─ YES → MongoDB
      └─ NO → Redis (cache/sessions)
```

### Use Cases

**PostgreSQL (Supabase)** - Current choice ✅
- Multi-tenant applications
- Relational data (courses, lessons, organizations)
- Row-level security required
- ACID transactions needed
- Real-time subscriptions

**Redis** - For caching
- Session storage
- Rate limiting
- Caching API responses
- Pub/sub messaging
- Temporary data

**MongoDB** - Not recommended for this project
- Rapidly changing schema
- Document-oriented data
- No complex joins needed

**SQLite** - For local development
- Embedded databases
- Mobile apps
- Single-user applications

## State Management (Frontend)

### Comparison Matrix

| Criteria | Zustand | Redux Toolkit | React Context | Jotai | Valtio |
|----------|---------|---------------|---------------|-------|--------|
| **Bundle size** | 1.2 KB | 11 KB | 0 KB | 3 KB | 4 KB |
| **Learning curve** | Low | High | Low | Medium | Low |
| **DevTools** | ✅ Yes | ✅ Excellent | ❌ No | ✅ Yes | ✅ Yes |
| **TypeScript** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Excellent | ✅ Good |
| **Boilerplate** | Minimal | High | Minimal | Minimal | Minimal |
| **Performance** | ✅ Excellent | ✅ Good | ⚠️ Re-render issues | ✅ Excellent | ✅ Good |
| **Middleware** | ✅ Yes | ✅ Yes | ❌ No | ⚠️ Limited | ⚠️ Limited |
| **Immer support** | ✅ Native | ✅ Built-in | ❌ Manual | ✅ Via plugin | ✅ Built-in |

### Decision Tree

```
What type of state are you managing?
│
├─ Server state (API data)
│  └─ Use: TanStack Query (React Query) + Zustand for UI state
│
├─ Form state
│  └─ Use: React Hook Form + Zod validation
│
├─ Simple UI state (modals, toggles)
│  └─ Use: React Context or useState
│
└─ Complex UI state (navigation, multi-step)
   └─ Use: Zustand + Immer
```

### Use Cases

**Zustand + Immer** - Current choice ✅
```typescript
// When to use:
// - Complex nested state
// - Navigation stacks
// - Inspector panels
// - Multi-step forms

import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

const useStore = create<State>()(
  immer((set) => ({
    history: [],
    openDetail: (id) => set((state) => {
      state.history.push(state.current);
      state.current = { view: 'detail', id };
    }),
  }))
);
```

**React Context** - For simple cases
```typescript
// When to use:
// - Theme switching
// - i18n (internationalization)
// - User authentication state
// - Simple toggles/flags

const ThemeContext = createContext<Theme>('light');
```

**TanStack Query** - For server state
```typescript
// When to use:
// - API data fetching
// - Caching server responses
// - Optimistic updates
// - Pagination/infinite scroll

const { data } = useQuery({
  queryKey: ['courses'],
  queryFn: () => trpc.courses.list.query(),
});
```

**Redux Toolkit** - Not recommended unless:
- Team already familiar
- Need time-travel debugging
- Complex state machine logic

## API Architecture

### Comparison Matrix

| Criteria | tRPC | GraphQL | REST | gRPC |
|----------|------|---------|------|------|
| **Type safety** | ✅ End-to-end | ⚠️ Codegen needed | ❌ Manual | ✅ Protobuf |
| **Learning curve** | Low | High | Low | High |
| **Tooling** | Good | Excellent | Excellent | Good |
| **Caching** | Manual | Built-in | Manual | Manual |
| **Batching** | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| **Real-time** | ⚠️ Via WebSocket | ✅ Subscriptions | ⚠️ SSE/WebSocket | ✅ Streaming |
| **Bundle size** | Small | Large | N/A | Medium |
| **Public API** | ❌ No | ✅ Yes | ✅ Yes | ⚠️ Limited |

### Decision Tree

```
Do you control both client and server?
│
├─ YES (Full-stack TypeScript)
│  └─ Use: tRPC (current choice ✅)
│     - End-to-end type safety
│     - Zero code generation
│     - Minimal boilerplate
│
└─ NO (Public API or multiple clients)
   └─ Do clients need flexible queries?
      ├─ YES → GraphQL
      │  - Mobile apps with limited bandwidth
      │  - Complex data requirements
      │
      └─ NO → REST
         - Simple CRUD operations
         - Standard HTTP tooling
```

### Use Cases

**tRPC** - Current choice ✅
```typescript
// When to use:
// - Monorepo with shared TypeScript
// - Internal APIs
// - Full control over client/server

// Backend
export const coursesRouter = router({
  list: publicProcedure.query(async () => { ... }),
});

// Frontend (auto-typed)
const { data } = trpc.courses.list.useQuery();
```

**REST** - For public APIs
```typescript
// When to use:
// - Public API endpoints
// - Third-party integrations
// - Standard HTTP tooling needed

// Next.js API route
export async function GET(request: Request) {
  return Response.json({ courses: [] });
}
```

**GraphQL** - Not recommended unless:
- Complex nested data requirements
- Mobile clients with bandwidth constraints
- Need for real-time subscriptions

## Package Manager

### Comparison Matrix

| Criteria | pnpm | npm | yarn | bun |
|----------|------|-----|------|-----|
| **Disk usage** | ✅ Minimal | ❌ High | ⚠️ Medium | ✅ Minimal |
| **Install speed** | ✅ Fast | ⚠️ Slow | ✅ Fast | ✅ Very fast |
| **Monorepo** | ✅ Excellent | ⚠️ Workspaces | ✅ Good | ✅ Good |
| **Node compatibility** | ✅ Excellent | ✅ Excellent | ✅ Excellent | ⚠️ Good |
| **Lock file merge** | ✅ Easy | ⚠️ Conflicts | ⚠️ Conflicts | ✅ Easy |
| **Stability** | ✅ Stable | ✅ Stable | ✅ Stable | ⚠️ Beta |

### Use Cases

**pnpm** - Current choice ✅
```bash
# Why we chose pnpm:
# 1. Monorepo support (workspace:* protocol)
# 2. Fast installs (content-addressable storage)
# 3. Strict node_modules (prevents phantom dependencies)
# 4. Easy lock file merges

# Monorepo commands
pnpm --filter web add react
pnpm -r type-check
pnpm add -D -w prettier
```

## Validation Libraries

### Comparison Matrix

| Criteria | Zod | Yup | Joi | io-ts |
|----------|-----|-----|-----|-------|
| **TypeScript** | ✅ Native | ⚠️ TS support | ⚠️ TS support | ✅ Native |
| **Type inference** | ✅ Excellent | ⚠️ Manual | ⚠️ Manual | ✅ Good |
| **Bundle size** | 8 KB | 16 KB | 160 KB | 12 KB |
| **Error messages** | ✅ Good | ✅ Good | ✅ Good | ⚠️ Verbose |
| **Schema composition** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Good |
| **Runtime safety** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

### Use Cases

**Zod** - Current choice ✅
```typescript
// Why we chose Zod:
// 1. TypeScript-first design
// 2. Type inference (no duplication)
// 3. Composable schemas
// 4. tRPC integration

import { z } from 'zod';

// Define schema
const CreateCourseSchema = z.object({
  title: z.string().min(3).max(100),
  organizationId: z.string().uuid(),
});

// Infer type (no duplication!)
type CreateCourseInput = z.infer<typeof CreateCourseSchema>;

// Use in tRPC
publicProcedure
  .input(CreateCourseSchema)
  .mutation(async ({ input }) => { ... });
```

## Styling Solutions

### Comparison Matrix

| Criteria | Tailwind CSS | CSS Modules | Styled Components | Emotion | Vanilla CSS |
|----------|--------------|-------------|-------------------|---------|-------------|
| **Bundle size** | ⚠️ Medium | ✅ None | ❌ Large | ⚠️ Medium | ✅ None |
| **Runtime overhead** | ✅ None | ✅ None | ❌ Yes | ⚠️ Small | ✅ None |
| **Type safety** | ❌ No | ❌ No | ✅ Yes | ✅ Yes | ❌ No |
| **Themability** | ✅ Good | ⚠️ Manual | ✅ Excellent | ✅ Excellent | ⚠️ Manual |
| **Developer UX** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Good | ⚠️ Verbose |
| **SSR support** | ✅ Yes | ✅ Yes | ⚠️ Config needed | ⚠️ Config needed | ✅ Yes |

### Use Cases

**Tailwind CSS** - Current choice ✅
```typescript
// Why we chose Tailwind:
// 1. Utility-first (fast development)
// 2. No runtime overhead
// 3. Built-in responsive design
// 4. Easy to purge unused styles

<div className="flex items-center gap-4 p-4 bg-white rounded-lg shadow">
  <Image src="/logo.png" className="w-12 h-12" />
  <h2 className="text-lg font-semibold">Course Title</h2>
</div>
```

**CSS Modules** - For component-specific styles
```css
/* CourseCard.module.css */
.card {
  display: flex;
  padding: 1rem;
}
```

**Styled Components** - Not recommended unless:
- Need runtime theming
- Component library development

## Testing Frameworks

### Comparison Matrix

| Criteria | Vitest | Jest | Playwright | Cypress |
|----------|--------|------|------------|---------|
| **Speed** | ✅ Very fast | ⚠️ Slower | ✅ Fast | ⚠️ Slower |
| **Vite support** | ✅ Native | ❌ Config needed | N/A | N/A |
| **TypeScript** | ✅ Native | ⚠️ Config needed | ✅ Good | ✅ Good |
| **Watch mode** | ✅ Excellent | ✅ Good | ❌ No | ⚠️ Limited |
| **E2E testing** | ❌ No | ❌ No | ✅ Excellent | ✅ Good |
| **Parallel tests** | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Limited |

### Use Cases

**Vitest** - For unit/integration tests
```typescript
// Why we chose Vitest:
// 1. Vite-native (no config)
// 2. Fast (ESM + HMR)
// 3. Jest-compatible API

import { describe, it, expect } from 'vitest';

describe('createCourse', () => {
  it('should create course with valid input', async () => {
    const result = await createCourse({ title: 'Test' });
    expect(result).toHaveProperty('id');
  });
});
```

**Playwright** - For E2E tests
```typescript
// Why we chose Playwright:
// 1. Multiple browser support
// 2. Parallel execution
// 3. Auto-waiting

import { test, expect } from '@playwright/test';

test('create course flow', async ({ page }) => {
  await page.goto('/courses');
  await page.click('button:text("New Course")');
  await page.fill('input[name="title"]', 'Test Course');
  await page.click('button:text("Create")');
  await expect(page.locator('h1')).toHaveText('Test Course');
});
```

## Deployment Platforms

### Comparison Matrix

| Criteria | Vercel | Netlify | AWS | Railway | Fly.io |
|----------|--------|---------|-----|---------|--------|
| **Next.js optimization** | ✅ Native | ✅ Good | ⚠️ Manual | ✅ Good | ✅ Good |
| **Edge functions** | ✅ Yes | ✅ Yes | ✅ Lambda@Edge | ⚠️ Limited | ✅ Yes |
| **Database hosting** | ❌ No | ❌ No | ✅ RDS | ✅ Postgres | ✅ Postgres |
| **Cost (hobby)** | Free | Free | Pay-as-go | Free tier | Free tier |
| **Automatic SSL** | ✅ Yes | ✅ Yes | ⚠️ ACM | ✅ Yes | ✅ Yes |
| **Preview deployments** | ✅ Excellent | ✅ Good | ⚠️ Manual | ✅ Good | ✅ Good |

### Use Cases

**Vercel** - For Next.js frontend
```bash
# Why Vercel:
# 1. Native Next.js support
# 2. Edge functions
# 3. Preview deployments
# 4. Automatic optimization

vercel --prod
```

**Railway** - For Node.js backend
```bash
# Why Railway:
# 1. Simple deployment
# 2. Postgres hosting
# 3. Environment variables
# 4. Good free tier

railway up
```

**Supabase** - For database + auth
```bash
# Why Supabase:
# 1. Managed Postgres
# 2. Built-in auth
# 3. Real-time subscriptions
# 4. RLS (Row Level Security)
```

## Caching Strategies

### Comparison Matrix

| Strategy | Use Case | Invalidation | Complexity |
|----------|----------|--------------|------------|
| **Redis** | Session, rate limiting | TTL + manual | Medium |
| **CDN** | Static assets | Cache-Control headers | Low |
| **React Query** | API responses | Time-based + manual | Low |
| **Next.js ISR** | Static pages | Revalidate interval | Medium |
| **Service Worker** | Offline support | Version-based | High |

### Decision Tree

```
What are you caching?
│
├─ API responses → React Query (5-10 min stale time)
│
├─ Static assets (images, CSS) → CDN + long-lived headers
│
├─ Session data → Redis (30 min TTL)
│
├─ Rate limiting → Redis (1-60 min TTL)
│
└─ Static pages → Next.js ISR (60s revalidate)
```

## Authentication Strategies

### Comparison Matrix

| Solution | Implementation | Security | Flexibility |
|----------|---------------|----------|-------------|
| **Supabase Auth** | Managed | ✅ Excellent | ⚠️ Limited |
| **NextAuth.js** | Self-hosted | ✅ Good | ✅ Excellent |
| **Auth0** | Managed | ✅ Excellent | ✅ Good |
| **Clerk** | Managed | ✅ Excellent | ⚠️ Limited |
| **Custom JWT** | Self-hosted | ⚠️ Complex | ✅ Full control |

### Use Cases

**Supabase Auth** - Current choice ✅
```typescript
// Why Supabase Auth:
// 1. Integrated with database (RLS)
// 2. Social providers built-in
// 3. Row-level security
// 4. Email/password + OAuth

const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password',
});

// RLS automatically filters based on auth.uid()
const { data } = await supabase
  .from('courses')
  .select('*'); // Only returns user's accessible courses
```

## Performance Metrics Targets

### Frontend (Web Vitals)

| Metric | Target | Threshold |
|--------|--------|-----------|
| **FCP** (First Contentful Paint) | < 1.8s | < 3s |
| **LCP** (Largest Contentful Paint) | < 2.5s | < 4s |
| **FID** (First Input Delay) | < 100ms | < 300ms |
| **CLS** (Cumulative Layout Shift) | < 0.1 | < 0.25 |
| **TTFB** (Time to First Byte) | < 600ms | < 1.8s |

### Backend (API)

| Metric | Target | Threshold |
|--------|--------|-----------|
| **Response time** (p95) | < 200ms | < 500ms |
| **Database query time** (avg) | < 50ms | < 100ms |
| **Cache hit rate** | > 80% | > 60% |
| **Error rate** | < 0.1% | < 1% |
| **Availability** | > 99.9% | > 99% |

### Database

| Metric | Target | Action |
|--------|--------|--------|
| **Query time > 100ms** | 0 queries | Add index |
| **Connection pool** | < 80% used | Scale up |
| **Disk usage** | < 70% | Archive old data |
| **Replication lag** | < 1s | Investigate |

## Troubleshooting Guide

### Common Issues

#### Issue: Slow API responses

**Diagnosis:**
```bash
# 1. Check database query performance
EXPLAIN ANALYZE SELECT * FROM courses WHERE organization_id = 'uuid';

# 2. Check for N+1 queries
# Enable query logging in Supabase

# 3. Check Redis cache hit rate
redis-cli INFO stats | grep hit_rate
```

**Solutions:**
```sql
-- Add index
CREATE INDEX idx_courses_org_id ON courses(organization_id);

-- Use joins instead of N+1
SELECT courses.*, lessons.*
FROM courses
LEFT JOIN lessons ON lessons.course_id = courses.id;
```

#### Issue: High memory usage (frontend)

**Diagnosis:**
```typescript
// Chrome DevTools -> Memory tab
// Take heap snapshot, look for detached DOM nodes

// React DevTools -> Profiler
// Identify components with high render time
```

**Solutions:**
```typescript
// 1. Memoize expensive computations
const value = useMemo(() => expensiveCalc(data), [data]);

// 2. Use pagination/virtualization
import { FixedSizeList } from 'react-window';

// 3. Clean up subscriptions
useEffect(() => {
  const subscription = observable.subscribe();
  return () => subscription.unsubscribe();
}, []);
```

#### Issue: Type errors after database migration

**Diagnosis:**
```bash
# Database types out of sync
pnpm type-check
```

**Solution:**
```bash
# Regenerate types from database
pnpm supabase gen types typescript --project-id PROJECT_REF \
  > packages/shared-types/src/database.types.ts

# Rebuild packages
pnpm type-check
```

## Conclusion

Technology decisions should be based on:

1. **Project requirements** - Current and future needs
2. **Team expertise** - Learning curve vs productivity
3. **Ecosystem** - Tooling, community, documentation
4. **Performance** - Bundle size, runtime overhead
5. **Maintainability** - Long-term support, upgrade path

Current stack rationale:
- **PostgreSQL (Supabase)**: Multi-tenant RLS, ACID, type-safe
- **tRPC**: End-to-end type safety, zero codegen
- **Zustand + Immer**: Minimal boilerplate, excellent DX
- **Zod**: Type inference, tRPC integration
- **Tailwind**: Fast development, zero runtime
- **pnpm**: Monorepo support, fast installs
- **Vitest**: Vite-native, fast tests
- **Vercel**: Next.js optimization, edge functions
