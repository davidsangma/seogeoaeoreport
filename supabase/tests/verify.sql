-- Verification suite. Run against a migrated database as a superuser (postgres):
--   psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/verify.sql
-- Everything runs inside one transaction that is rolled back, so no data is left behind.
-- Any failed check raises an exception and aborts the script.

begin;

-- 1. Seed counts ------------------------------------------------------------------
do $$
declare n int;
begin
  select count(*) into n from public.clients;
  if n <> 10 then raise exception 'FAIL expected 10 clients, got %', n; end if;

  select count(*) into n from public.metric_definitions;
  if n <> 59 then raise exception 'FAIL expected 59 metrics, got %', n; end if;

  select count(*) into n from public.activity_types;
  if n <> 15 then raise exception 'FAIL expected 15 activity types, got %', n; end if;

  select count(*) into n from public.client_metrics;
  if n <> 10 * 59 then raise exception 'FAIL expected 590 client_metrics, got %', n; end if;

  -- every table has RLS enabled
  select count(*) into n from pg_tables t
    join pg_class c on c.relname = t.tablename and c.relnamespace = 'public'::regnamespace
    where t.schemaname = 'public' and not c.relrowsecurity;
  if n <> 0 then raise exception 'FAIL % public tables without RLS', n; end if;

  raise notice 'PASS seed counts + RLS enabled';
end $$;

-- 2. external_only clients: no GSC / analytics metrics enabled ----------------------
do $$
declare n int;
begin
  select count(*) into n
  from public.client_metrics cm
  join public.clients c on c.id = cm.client_id
  join public.metric_definitions m on m.id = cm.metric_id
  where c.tier = 'external_only' and cm.enabled
    and (m.primary_source in ('gsc','ga4','adobe')
         or m.requires && array['gsc','ga4','adobe']::public.source_system[]);
  if n <> 0 then raise exception 'FAIL external_only clients have % GSC/analytics metrics enabled', n; end if;

  -- and every disabled metric carries a reason
  select count(*) into n from public.client_metrics where not enabled and disabled_reason is null;
  if n <> 0 then raise exception 'FAIL % disabled metrics without a reason', n; end if;

  -- thebar: GA4 on, GSC off; dairydelights: GSC on, analytics off
  if not (select enabled from public.client_metrics cm join public.clients c on c.id = cm.client_id
          where c.slug = 'thebar' and cm.metric_id = 'seo_organic_sessions') then
    raise exception 'FAIL thebar should have seo_organic_sessions enabled'; end if;
  if (select enabled from public.client_metrics cm join public.clients c on c.id = cm.client_id
      where c.slug = 'thebar' and cm.metric_id = 'seo_gsc_clicks') then
    raise exception 'FAIL thebar should not have seo_gsc_clicks enabled'; end if;
  if (select enabled from public.client_metrics cm join public.clients c on c.id = cm.client_id
      where c.slug = 'aashirvaad-dairydelights' and cm.metric_id = 'seo_organic_sessions') then
    raise exception 'FAIL dairydelights should not have seo_organic_sessions enabled'; end if;
  -- Adobe-via-manual-sheet clients keep analytics metrics
  if not (select enabled from public.client_metrics cm join public.clients c on c.id = cm.client_id
          where c.slug = 'foodiesonly' and cm.metric_id = 'seo_organic_sessions') then
    raise exception 'FAIL foodiesonly should have seo_organic_sessions enabled (Adobe)'; end if;
  raise notice 'PASS client_metrics enablement';
end $$;

-- 3. Constraints --------------------------------------------------------------------
do $$
declare cid uuid := (select id from public.clients where slug = 'usha');
begin
  begin
    insert into public.reports (client_id, period_month) values (cid, '2026-01-15');
    raise exception 'FAIL mid-month period_month was accepted';
  exception when check_violation then
    raise notice 'PASS period_month CHECK rejects mid-month date';
  end;

  begin
    insert into public.metric_values (client_id, metric_id, period_month, value, source, ingestion_path)
    values (cid, 'geo_ai_crawler_hits', '2026-01-01', 5, 'manual_sheet', 'manual_sheet');
    raise exception 'FAIL manual_sheet row without evidence_link was accepted';
  exception when check_violation then
    raise notice 'PASS manual_sheet requires evidence_link';
  end;

  begin
    insert into public.app_users (user_id, role) values (gen_random_uuid(), 'client_viewer');
    raise exception 'FAIL client_viewer without client_id was accepted';
  exception when check_violation or foreign_key_violation then
    raise notice 'PASS client_viewer requires client_id';
  end;
end $$;

-- 4. Fixtures (as superuser) ---------------------------------------------------------
insert into auth.users (id, email) values
  ('aaaaaaaa-0000-0000-0000-00000000000a', 'viewer-a@test.invalid'),
  ('bbbbbbbb-0000-0000-0000-00000000000b', 'viewer-b@test.invalid'),
  ('cccccccc-0000-0000-0000-00000000000c', 'editor@test.invalid'),
  ('dddddddd-0000-0000-0000-00000000000d', 'admin@test.invalid');

insert into public.app_users (user_id, role, client_id) values
  ('aaaaaaaa-0000-0000-0000-00000000000a', 'client_viewer',  (select id from public.clients where slug = 'foodiesonly')),
  ('bbbbbbbb-0000-0000-0000-00000000000b', 'client_viewer',  (select id from public.clients where slug = 'letsboing')),
  ('cccccccc-0000-0000-0000-00000000000c', 'internal_editor', null),
  ('dddddddd-0000-0000-0000-00000000000d', 'internal_admin',  null);

create temp table fx on commit drop as
select (select id from public.clients where slug = 'foodiesonly') as a,
       (select id from public.clients where slug = 'letsboing')   as b;
grant select on fx to public;

insert into public.reports (client_id, period_month, status) values
  ((select a from fx), '2026-01-01', 'published'),
  ((select a from fx), '2026-02-01', 'draft'),
  ((select b from fx), '2026-01-01', 'published');

insert into public.metric_values (client_id, metric_id, period_month, value, source, ingestion_path, evidence_link) values
  ((select a from fx), 'seo_gsc_clicks', '2026-01-01', 100, 'gsc', 'api', null),
  ((select a from fx), 'seo_gsc_clicks', '2026-01-01', 120, 'manual_sheet', 'manual_sheet', 'https://example.invalid/evidence'),
  ((select a from fx), 'seo_gsc_clicks', '2026-02-01', 200, 'gsc', 'api', null),
  ((select b from fx), 'seo_gsc_clicks', '2026-01-01', 300, 'gsc', 'api', null);

insert into public.insights (client_id, period_month, tab, audience, body, generated_by, status) values
  ((select a from fx), '2026-01-01', 'seo', 'internal', 'internal published', 'human', 'published'),
  ((select a from fx), '2026-01-01', 'seo', 'external', 'external draft',     'human', 'draft'),
  ((select a from fx), '2026-01-01', 'seo', 'external', 'external published', 'human', 'published'),
  ((select b from fx), '2026-01-01', 'seo', 'external', 'B external published', 'human', 'published');

insert into public.action_items (code, client_id, tab, planned_for_month, title) values
  ('ACT-foodiesonly-202601-01', (select a from fx), 'seo', '2026-01-01', 'A item 1'),
  ('ACT-foodiesonly-202601-02', (select a from fx), 'seo', '2026-01-01', 'A item 2'),
  ('ACT-letsboing-202601-01',   (select b from fx), 'seo', '2026-01-01', 'B item 1');
insert into public.action_evaluations (action_item_id, evaluated_month, execution_status, approved)
select id, '2026-02-01', 'done', code in ('ACT-foodiesonly-202601-01', 'ACT-letsboing-202601-01')
from public.action_items;

insert into public.sheet_registry (id, google_sheet_id, sheet_type, client_id)
values ('eeeeeeee-0000-0000-0000-00000000000e', 'sheet-a', 'input', (select a from fx));
insert into public.activities (client_id, activity_date, tab, activity_type, sheet_registry_id, source_row_key, raw_payload)
values ((select a from fx), '2026-01-20', 'seo', 'article_published', 'eeeeeeee-0000-0000-0000-00000000000e', 'r1', '{"x":1}');
insert into public.ingestion_runs (period_month, source, status) values ('2026-01-01', 'gsc', 'success');

-- 5. Precedence + conflicts + trend (superuser) --------------------------------------
do $$
declare v numeric; p public.ingestion_path; n int;
begin
  select value, ingestion_path into v, p from public.metric_values_final
   where client_id = (select a from fx) and metric_id = 'seo_gsc_clicks' and period_month = '2026-01-01';
  if v <> 100 or p <> 'api' then raise exception 'FAIL precedence: got % via %', v, p; end if;

  select count(*) into n from public.metric_values_final where client_id = (select a from fx);
  if n <> 2 then raise exception 'FAIL expected 2 final rows for client A, got %', n; end if;

  select count(*) into n from public.metric_value_conflicts;
  -- no role context as superuser => view hides rows; checked properly as admin below
  raise notice 'PASS precedence (api beats manual_sheet)';
end $$;

-- 6. Role simulation ---------------------------------------------------------------------
create temp table results (persona text, check_name text, got bigint) on commit drop;
grant all on results to public;

-- helper: run the same counts as the current role
create function pg_temp.snapshot(persona text) returns void language plpgsql as $$
begin
  insert into results select persona, 'clients',            count(*) from public.clients;
  insert into results select persona, 'metric_values',      count(*) from public.metric_values;
  insert into results select persona, 'metric_values_final',count(*) from public.metric_values_final;
  insert into results select persona, 'conflicts',          count(*) from public.metric_value_conflicts;
  insert into results select persona, 'trend',              count(*) from public.metric_values_trend;
  insert into results select persona, 'reports',            count(*) from public.reports;
  insert into results select persona, 'insights',           count(*) from public.insights;
  insert into results select persona, 'internal_insights',  count(*) from public.insights where audience = 'internal';
  insert into results select persona, 'evaluations',        count(*) from public.action_evaluations;
  insert into results select persona, 'action_items',       count(*) from public.action_items;
  insert into results select persona, 'activities',         count(*) from public.activities;
  insert into results select persona, 'sheet_registry',     count(*) from public.sheet_registry;
  insert into results select persona, 'ingestion_runs',     count(*) from public.ingestion_runs;
  insert into results select persona, 'client_sources',     count(*) from public.client_sources;
  insert into results select persona, 'client_metrics',     count(*) from public.client_metrics;
  insert into results select persona, 'app_users',          count(*) from public.app_users;
end $$;
grant execute on function pg_temp.snapshot(text) to public;

-- viewer A
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-0000-0000-00000000000a', true);
set local role authenticated;
select pg_temp.snapshot('viewer_a');
reset role;

-- viewer B
select set_config('request.jwt.claims', '{"sub":"bbbbbbbb-0000-0000-0000-00000000000b","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-0000-0000-00000000000b', true);
set local role authenticated;
select pg_temp.snapshot('viewer_b');
reset role;

-- editor
select set_config('request.jwt.claims', '{"sub":"cccccccc-0000-0000-0000-00000000000c","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'cccccccc-0000-0000-0000-00000000000c', true);
set local role authenticated;
select pg_temp.snapshot('editor');
reset role;

-- admin
select set_config('request.jwt.claims', '{"sub":"dddddddd-0000-0000-0000-00000000000d","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'dddddddd-0000-0000-0000-00000000000d', true);
set local role authenticated;
select pg_temp.snapshot('admin');
reset role;

do $$
declare
  r record;
  expected jsonb := '{
    "viewer_a": {"clients":1,"metric_values":2,"metric_values_final":1,"conflicts":0,"trend":1,"reports":1,
                 "insights":1,"internal_insights":0,"evaluations":1,"action_items":0,"activities":0,
                 "sheet_registry":0,"ingestion_runs":0,"client_sources":0,"client_metrics":59,"app_users":1},
    "viewer_b": {"clients":1,"metric_values":1,"metric_values_final":1,"conflicts":0,"trend":1,"reports":1,
                 "insights":1,"internal_insights":0,"evaluations":1,"action_items":0,"activities":0,
                 "sheet_registry":0,"ingestion_runs":0,"client_sources":0,"client_metrics":59,"app_users":1},
    "editor":   {"clients":10,"metric_values":4,"conflicts":1,"reports":3,"insights":4,"evaluations":3,
                 "action_items":3,"activities":1,"sheet_registry":1,"ingestion_runs":1,"app_users":4},
    "admin":    {"clients":10,"metric_values":4,"conflicts":1,"reports":3,"insights":4,"evaluations":3,
                 "action_items":3,"activities":1,"sheet_registry":1,"ingestion_runs":1,"app_users":4}
  }';
  want bigint;
begin
  for r in select * from results loop
    want := (expected -> r.persona ->> r.check_name)::bigint;
    if want is not null and want <> r.got then
      raise exception 'FAIL % % : expected %, got %', r.persona, r.check_name, want, r.got;
    end if;
  end loop;
  raise notice 'PASS role visibility (viewer A/B isolation, no internal insights, no activities/sheets/runs/conflicts)';
end $$;

-- 7. Editor write limits + anon lockout -------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"cccccccc-0000-0000-0000-00000000000c","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'cccccccc-0000-0000-0000-00000000000c', true);
set local role authenticated;
do $$
declare n int;
begin
  update public.activities set needs_review = true;
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'FAIL editor could not update activities.needs_review'; end if;

  begin
    update public.activities set quantity = 99;
    raise exception 'FAIL editor changed activities.quantity';
  exception when raise_exception then
    if sqlerrm like 'FAIL%' then raise; end if;
  end;

  update public.reports set status = 'in_review' where period_month = '2026-02-01';
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'FAIL editor could not update reports.status'; end if;

  begin
    update public.reports set pdf_url = 'x';
    raise exception 'FAIL editor changed reports.pdf_url';
  exception when raise_exception then
    if sqlerrm like 'FAIL%' then raise; end if;
  end;

  begin
    insert into public.clients (slug, domain, display_name, tier) values ('x', 'x.invalid', 'x', 'full');
    raise exception 'FAIL editor inserted a client';
  exception when insufficient_privilege then null;
  end;
  raise notice 'PASS editor write limits';
end $$;
reset role;

-- viewers cannot write
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-0000-0000-00000000000a', true);
set local role authenticated;
do $$
declare n int;
begin
  update public.reports set status = 'published';
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'FAIL viewer updated % reports', n; end if;
  raise notice 'PASS viewer cannot write';
end $$;
reset role;

set local role anon;
do $$
begin
  begin
    perform count(*) from public.clients;
    raise exception 'FAIL anon can read clients';
  exception when insufficient_privilege then
    raise notice 'PASS anon locked out';
  end;
end $$;
reset role;

-- 8. geo_prompts text is frozen ------------------------------------------------------------
do $$
declare pid uuid;
begin
  insert into public.geo_prompts (client_id, prompt) values ((select a from fx), 'best sweets') returning id into pid;
  begin
    update public.geo_prompts set prompt = 'changed' where id = pid;
    raise exception 'FAIL prompt text was updated';
  exception when raise_exception then
    if sqlerrm like 'FAIL%' then raise; end if;
  end;
  update public.geo_prompts set active = false where id = pid;
  raise notice 'PASS geo_prompts text frozen, deactivation allowed';
end $$;

-- 9. Trend window math -----------------------------------------------------------------------------
insert into public.metric_values (client_id, metric_id, period_month, value, source, ingestion_path) values
  ((select b from fx), 'seo_gsc_clicks', '2025-01-01', 150, 'gsc', 'api'),
  ((select b from fx), 'seo_gsc_clicks', '2025-12-01', 200, 'gsc', 'api');
do $$
declare r record;
begin
  select * into r from public.metric_values_trend
   where client_id = (select b from fx) and period_month = '2026-01-01';
  if r.prev_month_value <> 200 or round(r.mom_pct, 2) <> 50.00
     or r.yoy_value <> 150 or round(r.yoy_pct, 2) <> 100.00 then
    raise exception 'FAIL trend: prev=% mom=% yoy=% yoy_pct=%', r.prev_month_value, r.mom_pct, r.yoy_value, r.yoy_pct;
  end if;
  raise notice 'PASS trend MoM/YoY';
end $$;

rollback;
