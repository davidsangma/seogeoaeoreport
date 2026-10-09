-- Config tables + metric catalog.

create table public.clients (
  id           uuid primary key default gen_random_uuid(),
  slug         text not null unique check (slug ~ '^[a-z0-9-]+$'),
  domain       text not null,
  path_prefix  text,
  display_name text not null,
  tier         public.client_tier not null,
  market       text not null default 'IN',
  language     text not null default 'en',
  brand_regex  text,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create unique index clients_domain_prefix_key on public.clients (domain, coalesce(path_prefix, ''));

create table public.client_sources (
  id                  uuid primary key default gen_random_uuid(),
  client_id           uuid not null references public.clients(id) on delete cascade,
  source              public.source_system not null,
  access_status       public.access_status not null,
  ingestion_path      public.ingestion_path,
  property_identifier text,  -- GSC property URL / GA4 property ID / Adobe report suite ID
  auth_account        text,  -- internal email holding access
  last_success_at     timestamptz,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (client_id, source),
  check (access_status <> 'active' or ingestion_path is not null)
);

create table public.competitors (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references public.clients(id) on delete cascade,
  domain     text not null,
  brand_name text,
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (client_id, domain)
);

create table public.tracked_keywords (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null references public.clients(id) on delete cascade,
  keyword     text not null,
  tab         public.tab not null default 'seo',
  is_question boolean not null default false,
  priority    int,
  active      boolean not null default true,
  added_month date check (added_month is null or extract(day from added_month) = 1),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (client_id, keyword, tab)
);

-- Panel is frozen per quarter: prompt text is immutable (enforced by trigger).
-- To change a prompt, deactivate the old row and insert a new one.
create table public.geo_prompts (
  id            uuid primary key default gen_random_uuid(),
  client_id     uuid not null references public.clients(id) on delete cascade,
  prompt        text not null,
  intent        text,
  panel_version int not null default 1,
  active        boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (client_id, panel_version, prompt)
);

create table public.metric_definitions (
  id               text primary key,
  name             text not null,
  tab              public.tab not null,
  metric_type      public.metric_type not null,
  unit             public.unit not null,
  aggregation      public.aggregation not null,
  higher_is_better boolean not null default true,
  primary_source   public.source_system not null,
  fallback_sources public.source_system[] not null default '{}',
  -- ANY-OF: the metric is available for a client if at least one listed source
  -- is 'active' in client_sources. Empty = always available (sheet-fed metrics).
  requires         public.source_system[] not null default '{}',
  manual_eligible  boolean not null default false,
  is_core          boolean not null default false,
  supports_segments boolean not null default false,
  definition       text not null,
  display_order    int not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table public.client_metrics (
  client_id       uuid not null references public.clients(id) on delete cascade,
  metric_id       text not null references public.metric_definitions(id) on delete cascade,
  enabled         boolean not null default true,
  disabled_reason text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  primary key (client_id, metric_id)
);

-- Users + role helpers (defined here because views/policies depend on them) ---

create table public.app_users (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  role       public.app_role not null,
  client_id  uuid references public.clients(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint client_viewer_needs_client check (role <> 'client_viewer' or client_id is not null)
);

-- SECURITY DEFINER so policies can read app_users without recursing into its own RLS.
create function public.current_app_role()
returns public.app_role
language sql stable security definer
set search_path = ''
as $$
  select role from public.app_users where user_id = (select auth.uid())
$$;

create function public.current_client_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select client_id from public.app_users where user_id = (select auth.uid())
$$;

revoke execute on function public.current_app_role(), public.current_client_id() from public, anon;
grant  execute on function public.current_app_role(), public.current_client_id() to authenticated, service_role;
