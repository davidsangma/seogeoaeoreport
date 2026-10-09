-- Activities (input side), actions, insights, reports.

create table public.activity_types (
  id                text primary key,
  tab               public.tab not null,
  maps_to_metric_id text not null references public.metric_definitions(id),
  label             text not null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table public.sheet_registry (
  id             uuid primary key default gen_random_uuid(),
  google_sheet_id text not null unique,
  sheet_type     text not null check (sheet_type in ('input', 'output')),
  client_id      uuid references public.clients(id) on delete cascade,
  token_hash     text,  -- hash only, never the raw token
  active         boolean not null default true,
  last_synced_at timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table public.sheet_mappings (
  id                uuid primary key default gen_random_uuid(),
  sheet_registry_id uuid not null references public.sheet_registry(id) on delete cascade,
  column_map        jsonb not null default '{}',
  value_map         jsonb not null default '{}',  -- raw text -> activity_type id
  default_tab       public.tab,
  version           int not null default 1,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (sheet_registry_id, version)
);

create table public.action_items (
  id                    uuid primary key default gen_random_uuid(),
  code                  text not null unique check (code ~ '^ACT-[a-z0-9-]+-[0-9]{6}-[0-9]{2}$'),  -- ACT-{client_slug}-{YYYYMM}-{nn}
  client_id             uuid not null references public.clients(id) on delete cascade,
  tab                   public.tab not null,
  planned_for_month     date not null check (extract(day from planned_for_month) = 1),
  title                 text not null,
  hypothesis            text,
  planned_activity_type text references public.activity_types(id),
  planned_quantity      int,
  target_metric_id      text references public.metric_definitions(id),
  target_urls           text[] not null default '{}',
  target_keywords       text[] not null default '{}',
  baseline_value        numeric,
  target_value          numeric,
  owner                 text,
  due_date              date,
  status                public.action_status not null default 'planned',
  carried_from_id       uuid references public.action_items(id) on delete set null,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create table public.activities (
  id                 uuid primary key default gen_random_uuid(),
  client_id          uuid not null references public.clients(id) on delete cascade,
  activity_date      date not null,
  -- generated so (client_id, period_month) indexing works like the other tables
  period_month       date generated always as (activity_date - (extract(day from activity_date)::int - 1)) stored,
  tab                public.tab not null,
  activity_type      text not null references public.activity_types(id),
  url                text,
  quantity           int not null default 1,
  action_item_id     uuid references public.action_items(id) on delete set null,
  sheet_registry_id  uuid not null references public.sheet_registry(id) on delete cascade,
  source_row_key     text not null,
  raw_payload        jsonb,
  mapping_confidence numeric check (mapping_confidence between 0 and 1),
  needs_review       boolean not null default false,
  reviewed_by        uuid references auth.users(id) on delete set null,
  reviewed_at        timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (sheet_registry_id, source_row_key)
);

create table public.action_evaluations (
  id               uuid primary key default gen_random_uuid(),
  action_item_id   uuid not null references public.action_items(id) on delete cascade,
  evaluated_month  date not null check (extract(day from evaluated_month) = 1),
  execution_status public.execution_status not null,
  executed_count   int,
  metric_baseline  numeric,
  metric_actual    numeric,
  site_trend_pct   numeric,
  net_lift_pct     numeric,
  verdict          public.verdict,
  narrative        text,
  approved         boolean not null default false,
  approved_by      uuid references auth.users(id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (action_item_id, evaluated_month)
);

create table public.insights (
  id                    uuid primary key default gen_random_uuid(),
  client_id             uuid not null references public.clients(id) on delete cascade,
  period_month          date not null check (extract(day from period_month) = 1),
  tab                   public.tab not null,
  metric_type           public.metric_type,
  audience              public.audience not null,
  body                  text not null,
  supporting_metric_ids text[] not null default '{}',
  generated_by          text not null check (generated_by in ('llm', 'human')),
  status                public.workflow_status not null default 'draft',
  approved_by           uuid references auth.users(id) on delete set null,
  approved_at           timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create table public.reports (
  id               uuid primary key default gen_random_uuid(),
  client_id        uuid not null references public.clients(id) on delete cascade,
  period_month     date not null check (extract(day from period_month) = 1),
  status           public.workflow_status not null default 'draft',
  completeness_pct numeric check (completeness_pct between 0 and 100),
  published_at     timestamptz,
  pdf_url          text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (client_id, period_month)
);
