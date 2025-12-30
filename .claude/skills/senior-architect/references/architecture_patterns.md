# Architecture Patterns

Real-world patterns from the MegaCampusAI monorepo codebase.

## Database Patterns

### Pattern 1: Soft Delete with RLS (Row Level Security)

**Description:**
Implement soft deletes using `deleted_at` timestamp instead of hard deletes. Combined with Supabase RLS for multi-tenant security.

**When to Use:**
- Multi-tenant applications (organizations, workspaces)
- Audit trail requirements
- Data recovery needs
- Compliance (GDPR right to be forgotten with delayed purge)

**Implementation:**
```sql
-- Migration: Add deleted_at column
ALTER TABLE courses ADD COLUMN deleted_at timestamptz;

-- RLS policy: Hide deleted records
CREATE POLICY "Users see only non-deleted courses"
  ON courses FOR SELECT
  USING (deleted_at IS NULL AND organization_id IN (
    SELECT organization_id FROM organization_members WHERE user_id = auth.uid()
  ));

-- Soft delete function
CREATE OR REPLACE FUNCTION soft_delete_course(course_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE courses
  SET deleted_at = NOW()
  WHERE id = course_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**TypeScript Usage:**
```typescript
// Soft delete
await supabase
  .from('courses')
  .update({ deleted_at: new Date().toISOString() })
  .eq('id', courseId);

// Query non-deleted (RLS handles this automatically)
const { data } = await supabase
  .from('courses')
  .select('*')
  .is('deleted_at', null); // Explicit filter for clarity
```

**Benefits:**
- Data recovery possible
- Audit trail maintained
- Foreign key integrity preserved
- Performance: no cascading deletes

**Trade-offs:**
- Storage overhead (deleted records remain)
- Query filters required (mitigated by RLS)
- Periodic cleanup jobs needed

### Pattern 2: Intentional Duplication for Runtime Isolation

**Description:**
Maintain separate admin clients for different runtime environments rather than forced unification.

**When to Use:**
- Different runtime environments (Node.js vs Next.js Server)
- Different configuration requirements
- Different type sources
- Historical technical debt with breaking changes

**Implementation (from codebase):**
```typescript
// packages/course-gen-platform/src/shared/supabase/admin.ts
// Node.js backend (tRPC, BullMQ)
let supabaseAdmin: SupabaseClient<Database> | null = null;

export function getSupabaseAdmin(): SupabaseClient<Database> {
  if (!supabaseAdmin) {
    const supabaseUrl = process.env.SUPABASE_URL; // Different env var
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY; // Different env var
    supabaseAdmin = createClient<Database>(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    });
  }
  return supabaseAdmin;
}
```

```typescript
// packages/web/lib/supabase-admin.ts
// Next.js Server (Components, Actions, API Routes)
export const supabaseAdmin = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // Different env var
  { auth: { persistSession: false, autoRefreshToken: false } }
);
```

**Benefits:**
- Clear runtime separation
- Independent configuration
- No shared state issues
- Easier debugging

**Trade-offs:**
- Code duplication (documented as intentional)
- Synchronized updates required
- Must document reasons in CLAUDE.md

**Anti-Pattern to Avoid:**
```typescript
// DON'T: Force unification across runtime boundaries
// This creates complex environment detection and shared state issues
```

### Pattern 3: Single Source of Truth with Re-exports

**Description:**
Centralize type definitions in shared-types package, re-export from consuming packages.

**When to Use:**
- Monorepo with shared types
- Database schema changes
- Cross-package type consistency

**Implementation:**
```typescript
// packages/shared-types/src/database.types.ts (MAIN SOURCE)
export interface Course {
  id: string;
  title: string;
  organization_id: string;
  deleted_at?: string | null;
}

// packages/web/types/database.ts (RE-EXPORT ONLY)
export * from '@megacampus/shared-types/database.types';

// packages/course-gen-platform/src/types/database.ts (RE-EXPORT ONLY)
export type { Database } from '@megacampus/shared-types';
```

**Benefits:**
- Single update point
- Type consistency
- Easier refactoring
- Clear ownership

**Trade-offs:**
- Dependency coupling (shared-types changes affect all packages)
- Build order requirements

**Anti-Pattern to Avoid:**
```typescript
// DON'T: Duplicate type definitions
// packages/web/types/database.ts
export interface Course { ... } // BAD: Copy-paste from shared-types

// DON'T: Partial re-definitions
export interface Course extends Partial<SharedCourse> { ... } // BAD: Drift risk
```

## Frontend Patterns

### Pattern 4: Zustand + Immer for Complex State

**Description:**
Use Zustand with Immer middleware for nested state updates without spread operators.

**When to Use:**
- Complex nested state (navigation stacks, multi-level data)
- Performance-critical updates
- Multiple related state changes

**Implementation (from enrichment-inspector-store.ts):**
```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface NavigationEntry {
  view: InspectorView;
  enrichmentId?: string;
}

interface State {
  history: NavigationEntry[];
  current: NavigationEntry | null;
  dirty: boolean;

  openDetail: (enrichmentId: string) => void;
  goBack: () => void;
  setDirty: (dirty: boolean) => void;
}

export const useStore = create<State>()(
  immer((set) => ({
    history: [],
    current: null,
    dirty: false,

    openDetail: (enrichmentId) =>
      set((state) => {
        // Immer allows direct mutation syntax
        if (state.current) {
          state.history.push(state.current);
        }
        state.current = { view: 'detail', enrichmentId };
      }),

    goBack: () =>
      set((state) => {
        if (state.history.length === 0) return;
        state.current = state.history.pop()!;
      }),

    setDirty: (dirty) => set((state) => { state.dirty = dirty; }),
  }))
);

// Selector hooks for granular subscriptions
export const useCurrentView = () => useStore((s) => s.current?.view ?? 'root');
export const useCanGoBack = () => useStore((s) => s.history.length > 0);
```

**Benefits:**
- Readable nested updates (no spread hell)
- Immutability guaranteed
- Performance (structural sharing)
- Type safety

**Trade-offs:**
- Extra dependency (immer)
- Slight runtime overhead
- Learning curve (draft vs actual state)

**Anti-Pattern to Avoid:**
```typescript
// DON'T: Spread operator hell
set((state) => ({
  ...state,
  history: [...state.history, state.current],
  current: { ...state.current, view: 'detail' }
})); // Hard to read, error-prone
```

### Pattern 5: Stack Navigation Pattern

**Description:**
Browser-like navigation with history stack for panel-based UIs.

**When to Use:**
- Inspector panels
- Wizards/multi-step forms
- Mobile-like navigation in desktop apps

**Implementation:**
```typescript
// State
interface NavigationEntry {
  view: 'root' | 'create' | 'detail';
  enrichmentId?: string;
  createType?: string;
}

interface State {
  history: NavigationEntry[];
  current: NavigationEntry | null;
}

// Actions
const openRoot = (id: string) =>
  set((state) => {
    state.history = []; // Clear history
    state.current = { view: 'root' };
  });

const openCreate = (type: string) =>
  set((state) => {
    if (state.current) {
      state.history.push(state.current); // Save current
    }
    state.current = { view: 'create', createType: type };
  });

const goBack = () =>
  set((state) => {
    if (state.history.length === 0) return;
    state.current = state.history.pop()!; // Pop previous
  });
```

**Benefits:**
- Familiar browser-like UX
- Back button support
- Clear state transitions
- Deep linking support

**Trade-offs:**
- Memory overhead (history stack)
- Complex state management
- Must handle edge cases (empty history)

### Pattern 6: Optimistic Updates with Rollback

**Description:**
Update UI immediately, rollback on server error.

**When to Use:**
- Real-time collaboration
- Perceived performance critical
- High-latency operations

**Implementation:**
```typescript
const deleteEnrichment = async (id: string) => {
  // Save current state
  const snapshot = store.getState().enrichments;

  // Optimistic update
  store.setState((state) => {
    state.enrichments = state.enrichments.filter(e => e.id !== id);
  });

  try {
    await api.delete(`/enrichments/${id}`);
  } catch (error) {
    // Rollback on error
    store.setState({ enrichments: snapshot });
    toast.error('Failed to delete enrichment');
  }
};
```

**Benefits:**
- Instant UI feedback
- Better perceived performance
- Improved UX

**Trade-offs:**
- Rollback complexity
- Race conditions possible
- Must handle conflicts

## API Patterns

### Pattern 7: tRPC Router Organization

**Description:**
Organize tRPC routers by domain with nested routers for admin vs user operations.

**When to Use:**
- Complex API with admin/user separation
- Multi-tenant applications
- Clear permission boundaries

**Implementation:**
```typescript
// Admin router (service role bypass RLS)
const adminOrgRouter = router({
  list: publicProcedure.query(async () => {
    const admin = getSupabaseAdmin();
    return admin.from('organizations').select('*');
  }),

  create: publicProcedure
    .input(z.object({ name: z.string() }))
    .mutation(async ({ input }) => {
      const admin = getSupabaseAdmin();
      return admin.from('organizations').insert(input);
    }),
});

// Main router composition
export const appRouter = router({
  admin: router({
    organizations: adminOrgRouter,
    courses: adminCourseRouter,
  }),
  courses: userCourseRouter,
});
```

**Benefits:**
- Clear permission separation
- Organized by domain
- Type-safe client
- Easy to test

**Trade-offs:**
- Router nesting complexity
- Type inference depth limits

### Pattern 8: Rate Limiting with Redis

**Description:**
Token bucket algorithm with Redis for API rate limiting.

**When to Use:**
- Public APIs
- AI generation endpoints (expensive operations)
- Abuse prevention

**Implementation:**
```typescript
import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_URL!,
  token: process.env.UPSTASH_REDIS_TOKEN!,
});

export async function rateLimit(identifier: string, limit = 10, window = 60) {
  const key = `rate_limit:${identifier}`;

  const multi = redis.multi();
  multi.incr(key);
  multi.expire(key, window);

  const [count] = await multi.exec<[number, number]>();

  return {
    success: count <= limit,
    remaining: Math.max(0, limit - count),
    reset: window,
  };
}

// Usage in API route
export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') ?? 'unknown';
  const { success, remaining } = await rateLimit(ip, 10, 60);

  if (!success) {
    return new Response('Rate limit exceeded', {
      status: 429,
      headers: { 'X-RateLimit-Remaining': remaining.toString() }
    });
  }

  // Process request
}
```

**Benefits:**
- Abuse prevention
- Cost control (AI APIs)
- Fair usage enforcement

**Trade-offs:**
- Redis dependency
- Network latency
- Clock skew issues

## Monorepo Patterns

### Pattern 9: Package Structure by Domain

**Description:**
Organize packages by domain/purpose, not by type.

**Current Structure:**
```
packages/
├── course-gen-platform/  # Backend (Node.js, tRPC, BullMQ)
├── web/                  # Frontend (Next.js 15)
├── shared-types/         # Shared TypeScript types
├── shared-logger/        # Shared logging utility
└── trpc-client-sdk/      # Generated tRPC client
```

**Benefits:**
- Clear boundaries
- Independent deployment
- Team ownership
- Easier onboarding

**Trade-offs:**
- Potential code duplication (intentional)
- Build order dependencies

### Pattern 10: Migration File Naming

**Description:**
Use timestamp-based migration files with descriptive names.

**Pattern:**
```
packages/course-gen-platform/supabase/migrations/
├── 20251229100000_add_course_visibility.sql
├── 20251229130000_add_share_token_index.sql
├── 20251230_01_organization_enums.sql
├── 20251230_02_organization_extensions.sql
├── 20251230_03_organization_members.sql
└── 20251230_04_organization_invitations.sql
```

**Benefits:**
- Chronological ordering
- Descriptive names
- Multi-step migrations (same day with sequence)
- Easy rollback identification

**Trade-offs:**
- Timestamp conflicts (rare)
- Must enforce naming convention

## Anti-Patterns to Avoid

### Anti-Pattern 1: God Components

**What:**
Single component with 1000+ lines handling multiple concerns.

**Why Bad:**
- Hard to test
- Poor reusability
- Difficult debugging
- Slow re-renders

**Solution:**
```typescript
// BAD: God component
function CourseEditor() {
  // 1000+ lines: toolbar, canvas, sidebar, modals, state, API calls
}

// GOOD: Composition
function CourseEditor() {
  return (
    <>
      <Toolbar />
      <Canvas />
      <Sidebar />
      <Modals />
    </>
  );
}
```

### Anti-Pattern 2: Prop Drilling

**What:**
Passing props through 5+ component levels.

**Why Bad:**
- Tight coupling
- Hard to refactor
- TypeScript noise

**Solution:**
```typescript
// BAD: Prop drilling
<Parent userId={userId}>
  <Child userId={userId}>
    <GrandChild userId={userId}>
      <GreatGrandChild userId={userId} />

// GOOD: Context or Zustand
const useUser = () => useStore((s) => s.userId);
```

### Anti-Pattern 3: Untyped API Responses

**What:**
Using `any` or `unknown` for API responses.

**Why Bad:**
- Runtime errors
- No autocomplete
- Refactoring nightmares

**Solution:**
```typescript
// BAD
const data = await fetch('/api/courses') as any;

// GOOD: tRPC (type-safe by default)
const data = await trpc.courses.list.query();

// GOOD: Zod validation
const CourseSchema = z.object({ id: z.string(), title: z.string() });
const data = CourseSchema.parse(await response.json());
```

### Anti-Pattern 4: Massive Migrations

**What:**
Single migration file with 500+ lines changing multiple tables.

**Why Bad:**
- Hard to review
- Risky to rollback
- Difficult debugging

**Solution:**
```sql
-- BAD: Single massive migration
-- 20251230_big_refactor.sql (500 lines)

-- GOOD: Sequential migrations
-- 20251230_01_organization_enums.sql
-- 20251230_02_organization_extensions.sql
-- 20251230_03_organization_members.sql
```

## Security Best Practices

### Practice 1: RLS (Row Level Security) First

Always enable RLS on tables with multi-tenant data:

```sql
-- Enable RLS
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- Policy: Users see only their organization's courses
CREATE POLICY "org_isolation"
  ON courses FOR ALL
  USING (organization_id IN (
    SELECT organization_id
    FROM organization_members
    WHERE user_id = auth.uid()
  ));
```

### Practice 2: Service Role Key Security

Never expose service role key to client:

```typescript
// BAD: Client-side
const supabase = createClient(url, SERVICE_ROLE_KEY); // Exposed!

// GOOD: Server-side only
// packages/web/lib/supabase-admin.ts (server)
export const supabaseAdmin = createClient(url, SERVICE_ROLE_KEY);

// packages/web/app/api/courses/route.ts (server)
import { supabaseAdmin } from '@/lib/supabase-admin';
```

### Practice 3: Input Validation

Use Zod schemas for all user inputs:

```typescript
// Define schema
const CreateCourseInput = z.object({
  title: z.string().min(3).max(100),
  organizationId: z.string().uuid(),
});

// Validate in API
export async function POST(req: Request) {
  const body = await req.json();
  const validated = CreateCourseInput.parse(body); // Throws on invalid

  // Safe to use validated data
  await createCourse(validated);
}
```

## Performance Considerations

### Optimization 1: React Query for Server State

```typescript
import { useQuery } from '@tanstack/react-query';

function CourseList() {
  const { data, isLoading } = useQuery({
    queryKey: ['courses'],
    queryFn: () => trpc.courses.list.query(),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}
```

**Benefits:**
- Automatic caching
- Background refetch
- Optimistic updates
- Request deduplication

### Optimization 2: Database Indexing

```sql
-- Index for foreign key lookups
CREATE INDEX idx_courses_organization_id ON courses(organization_id);

-- Composite index for filtered queries
CREATE INDEX idx_courses_org_deleted ON courses(organization_id, deleted_at)
  WHERE deleted_at IS NULL;

-- Partial index for active records
CREATE INDEX idx_active_courses ON courses(created_at)
  WHERE deleted_at IS NULL;
```

### Optimization 3: Lazy Loading

```typescript
// Code splitting
const CourseEditor = lazy(() => import('./CourseEditor'));

// Component lazy loading
<Suspense fallback={<Skeleton />}>
  <CourseEditor />
</Suspense>
```

## Tools and Resources

### Recommended Tools

- **Database:** Supabase (PostgreSQL with RLS)
- **State Management:** Zustand + Immer
- **API:** tRPC (type-safe)
- **Validation:** Zod schemas
- **Package Manager:** pnpm (monorepo)
- **Rate Limiting:** Upstash Redis

### Migration Commands

```bash
# Create new migration
pnpm supabase migration new add_feature_name

# Apply migrations locally
pnpm supabase migration up

# Apply migrations to production
pnpm supabase db push

# Generate TypeScript types
pnpm supabase gen types typescript --project-id PROJECT_REF > types.ts
```

## Conclusion

These patterns are extracted from real production code in the MegaCampusAI monorepo. They represent battle-tested solutions to common architectural challenges in modern full-stack TypeScript applications.

Key takeaways:
1. Intentional duplication can be better than forced abstraction
2. Single source of truth for types prevents drift
3. RLS provides database-level security
4. Immer simplifies complex state updates
5. Migration files should be small and sequential
