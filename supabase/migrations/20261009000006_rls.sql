-- Row level security. The service role bypasses RLS (workers / Edge Functions).

-- Nothing for anon, ever.
revoke all on all tables in schema public from anon;
alter default privileges in schema public revoke all on tables from anon;

-- Extra SECURITY DEFINER helpers (viewers cannot read the tables these consult).
create function public.report_published(p_client uuid, p_month date)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.reports r
    where r.client_id = p_client and r.period_month = p_month and r.status = 'published'
  )
$$;

create function public.action_item_client(p_action_item uuid)
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select client_id from public.action_items where id = p_action_item
$$;

revoke execute on function public.report_published(uuid, date), public.action_item_client(uuid) from public, anon;
grant  execute on function public.report_published(uuid, date), public.action_item_client(uuid) to authenticated, service_role;

-- Enable RLS + internal read / admin write on every table -----------------------
do $$
declare t text;
begin
  foreach t in array array[
    'clients','client_sources','competitors','tracked_keywords','geo_prompts',
    'metric_definitions','client_metrics','metric_values','page_performance',
    'keyword_rankings','geo_prompt_results','activity_types','sheet_registry',
    'sheet_mappings','activities','action_items','action_evaluations','insights',
    'reports','ingestion_runs','app_users'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format($p$create policy "internal read" on public.%I for select to authenticated
      using ((select public.current_app_role()) in ('internal_admin','internal_editor'))$p$, t);
    execute format($p$create policy "admin write" on public.%I for all to authenticated
      using ((select public.current_app_role()) = 'internal_admin')
      with check ((select public.current_app_role()) = 'internal_admin')$p$, t);
  end loop;
end $$;

-- Editors ------------------------------------------------------------------------
create policy "editor insert" on public.insights for insert to authenticated
  with check ((select public.current_app_role()) = 'internal_editor');
create policy "editor update" on public.insights for update to authenticated
  using ((select public.current_app_role()) = 'internal_editor')
  with check ((select public.current_app_role()) = 'internal_editor');

create policy "editor insert" on public.action_items for insert to authenticated
  with check ((select public.current_app_role()) = 'internal_editor');
create policy "editor update" on public.action_items for update to authenticated
  using ((select public.current_app_role()) = 'internal_editor')
  with check ((select public.current_app_role()) = 'internal_editor');

create policy "editor insert" on public.action_evaluations for insert to authenticated
  with check ((select public.current_app_role()) = 'internal_editor');
create policy "editor update" on public.action_evaluations for update to authenticated
  using ((select public.current_app_role()) = 'internal_editor')
  with check ((select public.current_app_role()) = 'internal_editor');

create policy "editor update" on public.activities for update to authenticated
  using ((select public.current_app_role()) = 'internal_editor')
  with check ((select public.current_app_role()) = 'internal_editor');

create policy "editor update" on public.reports for update to authenticated
  using ((select public.current_app_role()) = 'internal_editor')
  with check ((select public.current_app_role()) = 'internal_editor');

-- RLS cannot restrict columns, so editors are limited by trigger.
create function public.restrict_editor_columns()
returns trigger
language plpgsql
set search_path = ''
as $$
declare allowed text[] := array(select unnest(tg_argv)) || array['updated_at'];
begin
  if public.current_app_role() = 'internal_editor'
     and (to_jsonb(new) - allowed) is distinct from (to_jsonb(old) - allowed) then
    raise exception 'internal_editor may only modify % on %', tg_argv, tg_table_name;
  end if;
  return new;
end;
$$;

create trigger a_restrict_editor_columns before update on public.activities
  for each row execute function public.restrict_editor_columns('needs_review', 'reviewed_by', 'reviewed_at', 'period_month' /* generated; NULL in BEFORE triggers */);
create trigger a_restrict_editor_columns before update on public.reports
  for each row execute function public.restrict_editor_columns('status');

-- Everyone signed in: own app_users row; metric catalog -------------------------
create policy "own row" on public.app_users for select to authenticated
  using (user_id = (select auth.uid()));
create policy "catalog read" on public.metric_definitions for select to authenticated
  using (true);

-- Client viewers: own client only ------------------------------------------------
create policy "viewer own client" on public.clients for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer' and id = (select public.current_client_id()));

create policy "viewer own client" on public.client_metrics for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer' and client_id = (select public.current_client_id()));

-- Values and raw detail: own client AND the month's report is published.
create policy "viewer published" on public.metric_values for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and public.report_published(client_id, period_month));
create policy "viewer published" on public.page_performance for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and public.report_published(client_id, period_month));
create policy "viewer published" on public.keyword_rankings for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and public.report_published(client_id, period_month));
create policy "viewer published" on public.geo_prompt_results for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and public.report_published(client_id, period_month));

create policy "viewer published" on public.reports for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and status = 'published');

create policy "viewer external published" on public.insights for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and client_id = (select public.current_client_id())
         and audience = 'external'
         and status = 'published');

create policy "viewer approved" on public.action_evaluations for select to authenticated
  using ((select public.current_app_role()) = 'client_viewer'
         and approved
         and public.action_item_client(action_item_id) = (select public.current_client_id()));

-- No viewer policy exists on: client_sources, competitors, tracked_keywords,
-- geo_prompts, activity_types, sheet_registry, sheet_mappings, activities,
-- action_items, ingestion_runs, app_users (others' rows). => denied by default.
-- metric_value_conflicts additionally filters on role inside the view.

grant select on public.metric_values_final, public.metric_values_trend, public.metric_value_conflicts to authenticated;
