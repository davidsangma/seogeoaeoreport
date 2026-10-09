-- updated_at triggers on every table, geo prompt freeze, indexes.

do $$
declare t text;
begin
  for t in
    select c.table_name
    from information_schema.columns c
    join information_schema.tables tb
      on tb.table_schema = c.table_schema and tb.table_name = c.table_name and tb.table_type = 'BASE TABLE'
    where c.table_schema = 'public' and c.column_name = 'updated_at'
  loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

create function public.geo_prompts_freeze_text()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.prompt is distinct from old.prompt then
    raise exception 'geo_prompts.prompt is frozen; deactivate this row and insert a new one';
  end if;
  return new;
end;
$$;
create trigger geo_prompts_freeze_text before update on public.geo_prompts
  for each row execute function public.geo_prompts_freeze_text();

-- Indexes ---------------------------------------------------------------------
create index metric_values_client_period_idx     on public.metric_values (client_id, period_month);
create index metric_values_metric_period_idx     on public.metric_values (metric_id, period_month);
create index page_performance_client_period_idx  on public.page_performance (client_id, period_month);
create index keyword_rankings_client_period_idx  on public.keyword_rankings (client_id, period_month);
create index geo_prompt_results_client_period_idx on public.geo_prompt_results (client_id, period_month);
create index activities_client_period_idx        on public.activities (client_id, period_month);
create index activities_needs_review_idx         on public.activities (needs_review) where needs_review;
create index action_items_client_planned_idx     on public.action_items (client_id, planned_for_month);

-- Supporting indexes (FKs / common filters)
create index insights_client_period_idx          on public.insights (client_id, period_month);
create index ingestion_runs_period_source_idx    on public.ingestion_runs (period_month, source);
create index action_evaluations_month_idx        on public.action_evaluations (evaluated_month);
create index metric_values_run_idx               on public.metric_values (run_id) where run_id is not null;
create index activities_action_item_idx          on public.activities (action_item_id) where action_item_id is not null;
