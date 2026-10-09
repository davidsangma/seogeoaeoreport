-- Ingestion runs, metric values, raw detail tables, and the value views.

create table public.ingestion_runs (
  id            uuid primary key default gen_random_uuid(),
  period_month  date not null check (extract(day from period_month) = 1),
  source        public.source_system not null,
  client_id     uuid references public.clients(id) on delete cascade,
  status        public.run_status not null default 'running',
  started_at    timestamptz not null default now(),
  finished_at   timestamptz,
  rows_written  int not null default 0,
  error         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table public.metric_values (
  id             uuid primary key default gen_random_uuid(),
  client_id      uuid not null references public.clients(id) on delete cascade,
  metric_id      text not null references public.metric_definitions(id),
  period_month   date not null check (extract(day from period_month) = 1),
  segment        text not null default 'all',  -- e.g. 'llm:chatgpt', 'platform:instagram'
  value          numeric not null,
  source         public.source_system not null,
  ingestion_path public.ingestion_path not null,
  evidence_link  text,
  entered_by     text,
  run_id         uuid references public.ingestion_runs(id) on delete set null,
  ingested_at    timestamptz not null default now(),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (client_id, metric_id, period_month, segment, ingestion_path),
  constraint manual_sheet_requires_evidence
    check (ingestion_path <> 'manual_sheet' or evidence_link is not null)
);

-- Precedence: api > scheduled_csv > manual_sheet > input_sheet.
-- security_invoker so RLS of the querying user applies to the underlying table.
create view public.metric_values_final
with (security_invoker = true) as
select distinct on (client_id, metric_id, period_month, segment)
  client_id, metric_id, period_month, segment, value, source,
  ingestion_path, evidence_link, entered_by, ingested_at
from public.metric_values
order by client_id, metric_id, period_month, segment,
  case ingestion_path
    when 'api'           then 1
    when 'scheduled_csv' then 2
    when 'manual_sheet'  then 3
    when 'input_sheet'   then 4
  end;

-- Internal-only: returns nothing for client viewers even though they may read metric_values.
create view public.metric_value_conflicts
with (security_invoker = true) as
select
  client_id, metric_id, period_month, segment,
  array_agg(ingestion_path order by ingestion_path) as ingestion_paths,
  jsonb_object_agg(ingestion_path, value)           as values_by_path,
  min(value) as min_value,
  max(value) as max_value,
  (max(value) - min(value)) / nullif(greatest(abs(max(value)), abs(min(value))), 0) as diff_ratio
from public.metric_values
where public.current_app_role() in ('internal_admin', 'internal_editor')
group by client_id, metric_id, period_month, segment
having count(distinct ingestion_path) > 1
   and (max(value) - min(value)) / nullif(greatest(abs(max(value)), abs(min(value))), 0) > 0.02;

-- Final values + MoM / YoY. RANGE frames over the calendar month, so gaps in the
-- series yield NULL rather than comparing against the wrong month.
create view public.metric_values_trend
with (security_invoker = true) as
with w as (
  select
    f.*,
    first_value(value) over prev_m as prev_month_value,
    first_value(value) over prev_y as yoy_value
  from public.metric_values_final f
  window
    prev_m as (partition by client_id, metric_id, segment order by period_month
               range between interval '1 month' preceding and interval '1 month' preceding),
    prev_y as (partition by client_id, metric_id, segment order by period_month
               range between interval '12 months' preceding and interval '12 months' preceding)
)
select
  w.*,
  (value - prev_month_value) / nullif(prev_month_value, 0) * 100 as mom_pct,
  (value - yoy_value)        / nullif(yoy_value, 0)        * 100 as yoy_pct
from w;

-- Raw detail tables ----------------------------------------------------------

create table public.page_performance (
  id           uuid primary key default gen_random_uuid(),
  client_id    uuid not null references public.clients(id) on delete cascade,
  period_month date not null check (extract(day from period_month) = 1),
  url          text not null,
  clicks       numeric,
  impressions  numeric,
  ctr          numeric,
  avg_position numeric,
  source       public.source_system not null default 'gsc',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (client_id, period_month, url)
);

create table public.keyword_rankings (
  id                    uuid primary key default gen_random_uuid(),
  client_id             uuid not null references public.clients(id) on delete cascade,
  keyword_id            uuid not null references public.tracked_keywords(id) on delete cascade,
  period_month          date not null check (extract(day from period_month) = 1),
  "position"            int,
  ranking_url           text,
  has_ai_overview       boolean not null default false,
  aio_cites_client      boolean not null default false,
  has_featured_snippet  boolean not null default false,
  owns_featured_snippet boolean not null default false,
  paa_present           boolean not null default false,
  client_in_paa         boolean not null default false,
  ai_mode_cites_client  boolean not null default false,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (keyword_id, period_month)
);

create table public.geo_prompt_results (
  id                    uuid primary key default gen_random_uuid(),
  client_id             uuid not null references public.clients(id) on delete cascade,
  prompt_id             uuid not null references public.geo_prompts(id) on delete cascade,
  llm                   text not null,
  period_month          date not null check (extract(day from period_month) = 1),
  brand_mentioned       boolean not null default false,
  mention_position      int,
  domain_cited          boolean not null default false,
  competitors_mentioned jsonb not null default '[]',
  cited_domains         jsonb not null default '[]',
  raw_response_ref      text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (prompt_id, llm, period_month)
);
