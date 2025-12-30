# System Design Workflows

Step-by-step workflows for common system design tasks in the MegaCampusAI monorepo.

## Workflow 1: New Feature Development

End-to-end workflow for adding a new feature to the platform.

### Phase 1: Requirements Analysis

**Steps:**
1. Gather requirements from stakeholders
2. Document user stories
3. Identify affected systems
4. Define success criteria

**Output:**
- Requirements document
- User stories
- Acceptance criteria

### Phase 2: Design

**Steps:**
1. Create architecture diagram
2. Define database schema
3. Design API contracts (tRPC routes)
4. Plan state management strategy
5. Identify shared types needed

**Output:**
```typescript
// Example: Enrichment feature design

// 1. Database schema (migration)
CREATE TABLE enrichments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id uuid REFERENCES lessons(id) ON DELETE CASCADE,
  type enrichment_type NOT NULL,
  status enrichment_status DEFAULT 'draft',
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

// 2. Shared types
// packages/shared-types/src/enrichment.ts
export interface Enrichment {
  id: string;
  lessonId: string;
  type: EnrichmentType;
  status: EnrichmentStatus;
  metadata: EnrichmentMetadata;
}

// 3. tRPC router
// packages/course-gen-platform/src/server/routers/enrichments.ts
export const enrichmentsRouter = router({
  list: publicProcedure
    .input(z.object({ lessonId: z.string() }))
    .query(async ({ input }) => { ... }),

  create: publicProcedure
    .input(CreateEnrichmentSchema)
    .mutation(async ({ input }) => { ... }),
});

// 4. State management
// packages/web/stores/enrichment-store.ts
export const useEnrichmentStore = create<State>()(immer(...));
```

### Phase 3: Implementation

**Steps:**
1. Create feature branch
2. Implement database migration
3. Add shared types to `packages/shared-types`
4. Implement backend (tRPC routes)
5. Implement frontend (components + state)
6. Add tests

**Order of implementation:**
```bash
# 1. Shared types first (dependency for both backend and frontend)
packages/shared-types/src/enrichment.ts

# 2. Database migration
packages/course-gen-platform/supabase/migrations/YYYYMMDD_add_enrichments.sql

# 3. Backend implementation
packages/course-gen-platform/src/server/routers/enrichments.ts
packages/course-gen-platform/src/stages/stage7-enrichments/

# 4. Frontend implementation
packages/web/components/enrichment/
packages/web/app/api/enrichments/
packages/web/stores/enrichment-store.ts
```

### Phase 4: Testing

**Steps:**
1. Unit tests (backend logic)
2. Integration tests (API routes)
3. E2E tests (user flows)
4. Manual testing

**Test coverage targets:**
- Backend: 80%+ coverage
- Frontend: Critical paths only
- E2E: Happy path + error cases

### Phase 5: Deployment

**Steps:**
1. Run type-check: `pnpm type-check`
2. Run build: `pnpm build`
3. Apply migrations: `pnpm supabase db push`
4. Deploy backend (course-gen-platform)
5. Deploy frontend (web)
6. Monitor logs and metrics

**Rollback plan:**
```bash
# If deployment fails
1. Revert database migration
2. Rollback application deployment
3. Clear Redis cache if needed
4. Notify team
```

## Workflow 2: Database Schema Changes

Safe workflow for modifying database schema in production.

### Phase 1: Planning

**Checklist:**
- [ ] Identify affected tables
- [ ] Check for foreign key constraints
- [ ] Plan for data migration
- [ ] Estimate downtime (if any)
- [ ] Prepare rollback strategy

### Phase 2: Migration Development

**Pattern: Additive changes (safe):**
```sql
-- ✅ SAFE: Add new column with default
ALTER TABLE courses ADD COLUMN visibility text DEFAULT 'private';

-- ✅ SAFE: Add new table
CREATE TABLE course_shares (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  share_token text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- ✅ SAFE: Add index
CREATE INDEX idx_courses_organization ON courses(organization_id);
```

**Pattern: Breaking changes (risky):**
```sql
-- ⚠️ RISKY: Rename column (breaks existing queries)
-- Better approach: Add new column, migrate data, deprecate old column

-- Step 1: Add new column
ALTER TABLE courses ADD COLUMN new_name text;

-- Step 2: Backfill data
UPDATE courses SET new_name = old_name;

-- Step 3: Update application code to use new_name

-- Step 4: (Later) Drop old column
ALTER TABLE courses DROP COLUMN old_name;
```

**Pattern: Data migrations:**
```sql
-- Migrate enum values
DO $$
DECLARE
  course_record RECORD;
BEGIN
  FOR course_record IN SELECT id, old_status FROM courses LOOP
    UPDATE courses
    SET new_status = CASE
      WHEN old_status = 'active' THEN 'published'
      WHEN old_status = 'inactive' THEN 'draft'
      ELSE 'archived'
    END
    WHERE id = course_record.id;
  END LOOP;
END $$;
```

### Phase 3: Testing

**Local testing:**
```bash
# 1. Start local Supabase
pnpm supabase start

# 2. Apply migration
pnpm supabase migration up

# 3. Test migration
# - Verify schema changes
# - Check data integrity
# - Run application locally

# 4. Rollback test
pnpm supabase db reset
```

**Staging testing:**
```bash
# 1. Apply to staging
pnpm supabase db push --db-url $STAGING_DB_URL

# 2. Run E2E tests
pnpm test:e2e

# 3. Manual QA
```

### Phase 4: Production Deployment

**Pre-deployment:**
```bash
# 1. Backup database (if critical change)
pg_dump -h $PROD_HOST -U $PROD_USER -d $PROD_DB > backup.sql

# 2. Announce maintenance window (if needed)
```

**Deployment:**
```bash
# 1. Apply migration
pnpm supabase db push --db-url $PROD_DB_URL

# 2. Monitor for errors
tail -f /var/log/postgres/postgresql.log

# 3. Verify schema
psql -h $PROD_HOST -U $PROD_USER -d $PROD_DB -c "\d+ table_name"

# 4. Check application logs
```

**Post-deployment:**
```bash
# 1. Run smoke tests
curl -X GET https://api.example.com/health

# 2. Monitor metrics
# - Query performance
# - Error rates
# - Response times

# 3. Generate updated TypeScript types
pnpm supabase gen types typescript --project-id PROJECT_REF > database.types.ts
```

## Workflow 3: Performance Optimization

Systematic approach to identifying and fixing performance issues.

### Phase 1: Profiling

**Frontend profiling:**
```typescript
// React DevTools Profiler
import { Profiler } from 'react';

<Profiler id="CourseList" onRender={onRenderCallback}>
  <CourseList />
</Profiler>

// Browser Performance API
performance.mark('start-render');
renderComponent();
performance.mark('end-render');
performance.measure('render-time', 'start-render', 'end-render');

// Lighthouse audit
npx lighthouse https://app.example.com --view
```

**Backend profiling:**
```bash
# Database query performance
EXPLAIN ANALYZE SELECT * FROM courses WHERE organization_id = 'uuid';

# Node.js profiling
node --inspect packages/course-gen-platform/dist/server.js

# Chrome DevTools -> chrome://inspect
```

### Phase 2: Identify Bottlenecks

**Common bottlenecks:**

1. **N+1 queries:**
```typescript
// ❌ BAD: N+1 queries
const courses = await db.from('courses').select('*');
for (const course of courses) {
  const lessons = await db.from('lessons').select('*').eq('course_id', course.id);
}

// ✅ GOOD: Single query with join
const coursesWithLessons = await db
  .from('courses')
  .select('*, lessons(*)')
  .eq('organization_id', orgId);
```

2. **Missing indexes:**
```sql
-- Find slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Add index
CREATE INDEX idx_lessons_course_id ON lessons(course_id);
```

3. **Large bundle size:**
```bash
# Analyze bundle
pnpm next build
pnpm @next/bundle-analyzer

# Fix: Code splitting
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

4. **Unnecessary re-renders:**
```typescript
// ❌ BAD: Re-renders on every state change
const { allState } = useStore();

// ✅ GOOD: Granular selectors
const courseName = useStore((s) => s.course.name);
```

### Phase 3: Implement Fixes

**Database optimizations:**
```sql
-- 1. Add indexes
CREATE INDEX CONCURRENTLY idx_courses_org_id ON courses(organization_id);

-- 2. Optimize queries
-- Before: Full table scan
SELECT * FROM courses WHERE deleted_at IS NULL;

-- After: Index-only scan
CREATE INDEX idx_active_courses ON courses(id) WHERE deleted_at IS NULL;

-- 3. Materialized views for complex aggregations
CREATE MATERIALIZED VIEW course_stats AS
SELECT
  organization_id,
  COUNT(*) as total_courses,
  SUM(lesson_count) as total_lessons
FROM courses
WHERE deleted_at IS NULL
GROUP BY organization_id;

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY course_stats;
```

**Frontend optimizations:**
```typescript
// 1. Memoization
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(data);
}, [data]);

// 2. Virtualization (react-window)
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={600}
  itemCount={courses.length}
  itemSize={80}
>
  {({ index, style }) => (
    <CourseItem course={courses[index]} style={style} />
  )}
</FixedSizeList>

// 3. Image optimization
import Image from 'next/image';

<Image
  src="/course-image.jpg"
  width={400}
  height={300}
  placeholder="blur"
  loading="lazy"
/>
```

**Backend optimizations:**
```typescript
// 1. Caching with Redis
const cached = await redis.get(`course:${courseId}`);
if (cached) return JSON.parse(cached);

const course = await db.from('courses').select('*').eq('id', courseId).single();
await redis.set(`course:${courseId}`, JSON.stringify(course), { ex: 300 });

// 2. Batch operations
// Before: N individual inserts
for (const lesson of lessons) {
  await db.from('lessons').insert(lesson);
}

// After: Single batch insert
await db.from('lessons').insert(lessons);

// 3. Pagination
const { data, count } = await db
  .from('courses')
  .select('*', { count: 'exact' })
  .range(offset, offset + limit - 1);
```

### Phase 4: Measure Results

**Metrics to track:**
```typescript
// 1. Frontend metrics
const metrics = {
  FCP: 'First Contentful Paint',
  LCP: 'Largest Contentful Paint',
  FID: 'First Input Delay',
  CLS: 'Cumulative Layout Shift',
  TTFB: 'Time to First Byte',
};

// 2. Backend metrics
const dbMetrics = {
  queryTime: 'Average query execution time',
  throughput: 'Queries per second',
  cacheHitRate: 'Redis cache hit rate',
};

// 3. Set targets
const targets = {
  FCP: '< 1.8s',
  LCP: '< 2.5s',
  FID: '< 100ms',
  queryTime: '< 50ms',
  cacheHitRate: '> 80%',
};
```

## Workflow 4: Adding API Endpoints

Workflow for adding new tRPC routes.

### Step 1: Define Input Schema

```typescript
// packages/shared-types/src/schemas/course.ts
import { z } from 'zod';

export const CreateCourseSchema = z.object({
  title: z.string().min(3).max(100),
  description: z.string().optional(),
  organizationId: z.string().uuid(),
  visibility: z.enum(['private', 'organization', 'public']).default('private'),
});

export type CreateCourseInput = z.infer<typeof CreateCourseSchema>;
```

### Step 2: Implement Router

```typescript
// packages/course-gen-platform/src/server/routers/courses.ts
import { router, publicProcedure } from '../trpc';
import { CreateCourseSchema } from '@megacampus/shared-types';
import { getSupabaseAdmin } from '../../shared/supabase/admin';

export const coursesRouter = router({
  list: publicProcedure
    .input(z.object({
      organizationId: z.string().uuid(),
      limit: z.number().min(1).max(100).default(10),
      offset: z.number().min(0).default(0),
    }))
    .query(async ({ input }) => {
      const admin = getSupabaseAdmin();

      const { data, error, count } = await admin
        .from('courses')
        .select('*', { count: 'exact' })
        .eq('organization_id', input.organizationId)
        .is('deleted_at', null)
        .range(input.offset, input.offset + input.limit - 1);

      if (error) throw new Error(error.message);

      return { courses: data, total: count };
    }),

  create: publicProcedure
    .input(CreateCourseSchema)
    .mutation(async ({ input }) => {
      const admin = getSupabaseAdmin();

      const { data, error } = await admin
        .from('courses')
        .insert({
          title: input.title,
          description: input.description,
          organization_id: input.organizationId,
          visibility: input.visibility,
        })
        .select()
        .single();

      if (error) throw new Error(error.message);

      return data;
    }),
});
```

### Step 3: Add to App Router

```typescript
// packages/course-gen-platform/src/server/routers/_app.ts
import { coursesRouter } from './courses';

export const appRouter = router({
  courses: coursesRouter,
  // ... other routers
});

export type AppRouter = typeof appRouter;
```

### Step 4: Use in Frontend

```typescript
// packages/web/app/courses/page.tsx
'use client';

import { trpc } from '@/lib/trpc';

export default function CoursesPage() {
  const { data, isLoading } = trpc.courses.list.useQuery({
    organizationId: 'org-uuid',
    limit: 10,
    offset: 0,
  });

  if (isLoading) return <Skeleton />;

  return (
    <div>
      {data?.courses.map(course => (
        <CourseCard key={course.id} course={course} />
      ))}
    </div>
  );
}
```

### Step 5: Testing

```typescript
// packages/course-gen-platform/tests/routers/courses.test.ts
import { describe, it, expect } from 'vitest';
import { appRouter } from '../../src/server/routers/_app';

describe('coursesRouter', () => {
  it('should create course', async () => {
    const caller = appRouter.createCaller({});

    const result = await caller.courses.create({
      title: 'Test Course',
      organizationId: 'org-uuid',
      visibility: 'private',
    });

    expect(result).toHaveProperty('id');
    expect(result.title).toBe('Test Course');
  });

  it('should validate input', async () => {
    const caller = appRouter.createCaller({});

    await expect(
      caller.courses.create({ title: 'AB' }) // Too short
    ).rejects.toThrow();
  });
});
```

## Workflow 5: Monorepo Dependency Management

Managing dependencies across packages.

### Adding Dependencies

```bash
# Add to specific package
pnpm --filter web add react-query
pnpm --filter course-gen-platform add bullmq

# Add to all packages
pnpm -r add lodash

# Add to root (devDependencies)
pnpm add -D -w prettier
```

### Internal Dependencies

```json
// packages/web/package.json
{
  "dependencies": {
    "@megacampus/shared-types": "workspace:*",
    "@megacampus/trpc-client-sdk": "workspace:*"
  }
}
```

### Dependency Updates

```bash
# Check outdated
pnpm outdated

# Update all
pnpm update --latest

# Update specific package
pnpm --filter web update react@latest
```

## Workflow 6: Error Handling

Consistent error handling across the stack.

### Backend Error Handling

```typescript
// Custom error classes
class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// tRPC error handling
import { TRPCError } from '@trpc/server';

export const coursesRouter = router({
  get: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ input }) => {
      const { data, error } = await admin
        .from('courses')
        .select('*')
        .eq('id', input.id)
        .single();

      if (error) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Course not found',
        });
      }

      return data;
    }),
});
```

### Frontend Error Handling

```typescript
// Error boundary
'use client';

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// Toast notifications
import { toast } from 'sonner';

const createCourse = trpc.courses.create.useMutation({
  onSuccess: () => {
    toast.success('Course created successfully');
  },
  onError: (error) => {
    toast.error(error.message || 'Failed to create course');
  },
});
```

## Conclusion

These workflows provide systematic approaches to common development tasks. Key principles:

1. **Plan before implementing** - Design docs, architecture diagrams
2. **Safety first** - Rollback plans, staging tests, gradual rollouts
3. **Measure everything** - Profiling, metrics, monitoring
4. **Consistent patterns** - Follow established conventions
5. **Type safety** - Zod schemas, tRPC, shared types
