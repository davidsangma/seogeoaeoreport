-- Enums + shared helper functions.

create type public.tab              as enum ('seo', 'aeo', 'geo');
create type public.metric_type      as enum ('input', 'output');
create type public.source_system    as enum ('gsc', 'ga4', 'adobe', 'dataforseo', 'crux', 'semrush', 'manual_sheet', 'input_sheet', 'openai');
create type public.ingestion_path   as enum ('api', 'manual_sheet', 'input_sheet', 'scheduled_csv');
create type public.access_status    as enum ('active', 'pending', 'none');
create type public.client_tier      as enum ('full', 'partial', 'external_only');
create type public.unit             as enum ('count', 'percent', 'ratio', 'position', 'ms', 'seconds', 'currency_inr', 'score');
create type public.aggregation      as enum ('sum', 'avg', 'latest', 'p75', 'median');
create type public.action_status    as enum ('planned', 'in_progress', 'done', 'partial', 'not_done', 'dropped');
create type public.execution_status as enum ('done', 'partial', 'not_done');
create type public.verdict          as enum ('scale', 'continue', 'pivot', 'drop', 'execution_gap');
create type public.audience         as enum ('internal', 'external');
create type public.workflow_status  as enum ('draft', 'in_review', 'approved', 'published');
create type public.run_status       as enum ('running', 'success', 'partial', 'failed');
create type public.app_role         as enum ('internal_admin', 'internal_editor', 'client_viewer');

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
