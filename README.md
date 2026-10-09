# Reporting Tool: database

Supabase (Postgres 17) backend for monthly SEO / AEO / GEO client reporting. A Next.js dashboard reads from it. This repo currently contains **only** the database: migrations, seed, RLS and tests.

## Workflow

- All schema changes are versioned migrations in `supabase/migrations/`. Never edit the remote database by hand.
- Secrets live only in `.env` (git-ignored). Copy `.env.example` and fill it in.
- Tooling: `npx supabase ...` (project-local CLI). Linked project ref is in `.env`.
- Apply: `npx supabase db push` (dry run first with `--dry-run`).
- Verify: run `supabase/tests/verify.sql` as a superuser; it runs in one transaction and rolls back.
- Types: `npx supabase gen types typescript --linked > types/database.ts`.

| Migration | Contents |
|---|---|
| `…01_enums_and_helpers` | enums, `set_updated_at()` |
| `…02_config_and_catalog` | clients, sources, competitors, keywords, prompts, metric catalog, `app_users`, `current_app_role()` |
| `…03_values_and_views` | `ingestion_runs`, `metric_values`, 3 views, raw detail tables |
| `…04_activities_actions_reports` | activity types, sheets, activities, actions, evaluations, insights, reports |
| `…05_triggers_and_indexes` | `updated_at` triggers, GEO prompt freeze, indexes |
| `…06_rls` | RLS on every table, policies, editor column limits |
| `…07_seed` | 10 clients, sources, 59 metrics, 15 activity types, `client_metrics` |

## Tables

Every table has `created_at` / `updated_at` (trigger-maintained). `period_month` is always the 1st of a month (CHECK). Only aggregates are stored; no user-level or customer PII.

| Table | Purpose | Written by |
|---|---|---|
| `clients` | Client config: domain, optional `path_prefix`, tier, market, `brand_regex` | Admin / migrations |
| `client_sources` | Per client + source: access status, ingestion path, property ID, auth account | Admin |
| `competitors` | Competitor domains per client | Admin |
| `tracked_keywords` | Keywords tracked per client (SEO/AEO) | Admin |
| `geo_prompts` | Frozen GEO prompt panel. Text is immutable; deactivate and insert to change | Admin |
| `metric_definitions` | Metric catalog: unit, aggregation, sources, human-readable `definition` | Migrations |
| `client_metrics` | Which metrics are enabled per client, with `disabled_reason` | Migrations / Admin |
| `metric_values` | One value per client, metric, month, segment and ingestion path | All three paths (below) |
| `page_performance` | Per-URL GSC data (raw) | GSC worker |
| `keyword_rankings` | Per keyword and month SERP / AIO / snippet / PAA flags (raw) | DataForSEO worker |
| `geo_prompt_results` | Per prompt, LLM and month results (raw) | DataForSEO / LLM worker |
| `activity_types` | Lookup: activity → the input metric it feeds | Migrations |
| `sheet_registry` | Registered Google Sheets (input / output), token **hash** only | Admin |
| `sheet_mappings` | Column and value mapping per input sheet, versioned | Admin |
| `activities` | Normalised rows from input sheets, with `raw_payload` and review flags | Input-sheet Apps Script |
| `action_items` | Planned actions (`ACT-{slug}-{YYYYMM}-{nn}`) | Editors |
| `action_evaluations` | Monthly evaluation, verdict and approval per action | Editors / evaluation job |
| `insights` | Narrative insights (internal or external) with workflow status | LLM job / Editors |
| `reports` | One per client and month: status, completeness, PDF | Service role / Editors (status) |
| `ingestion_runs` | Audit trail of worker runs | Workers |
| `app_users` | Maps `auth.users` → role (+ client for viewers) | Admin |

Views (all `security_invoker`, so the caller's RLS applies): `metric_values_final`, `metric_value_conflicts` (internal only), `metric_values_trend` (MoM / YoY).

## How each ingestion path writes

| Path | Writer | Target | Notes |
|---|---|---|---|
| `api` | Python workers (GSC, GA4, DataForSEO, CrUX), service role | `metric_values` (`ingestion_path='api'`) plus `page_performance`, `keyword_rankings`, `geo_prompt_results`; logs to `ingestion_runs` and sets `run_id` | Upsert on `(client_id, metric_id, period_month, segment, ingestion_path)` |
| `manual_sheet` | Apps Script pushing the standardised output sheet | `metric_values` (`ingestion_path='manual_sheet'`) | `evidence_link` is **required** (CHECK); set `entered_by` |
| `input_sheet` | Apps Script pushing messy team sheets via `sheet_registry` / `sheet_mappings` | `activities` (idempotent on `(sheet_registry_id, source_row_key)`); low-confidence rows get `needs_review`. Monthly roll-ups are written to `metric_values` (`ingestion_path='input_sheet'`) via `activity_types.maps_to_metric_id` | Raw text is kept in `raw_payload` |
| `scheduled_csv` | Scheduled CSV import | `metric_values` (`ingestion_path='scheduled_csv'`) | |

## Precedence rule

When more than one path supplies the same `(client, metric, month, segment)`, `metric_values_final` picks one row:

**`api` > `scheduled_csv` > `manual_sheet` > `input_sheet`**

The chosen `ingestion_path` and `evidence_link` are exposed. Rows from other paths are kept; `metric_value_conflicts` lists any key where paths disagree by more than 2% (internal users only).

## Access (RLS)

RLS is on for every table; `anon` has no access. The service role bypasses RLS (workers, Edge Functions).

- `internal_admin`: read and write everything.
- `internal_editor`: read everything; write `insights`, `action_items`, `action_evaluations`, `activities.needs_review` (+ `reviewed_by/at`) and `reports.status`. Column limits are enforced by trigger.
- `client_viewer`: only their own `client_id`, and only:
  - `reports` with `status = 'published'`;
  - `metric_values` and raw detail rows for months whose report is published;
  - `insights` with `audience = 'external'` and `status = 'published'`;
  - `action_evaluations` with `approved = true`.

  Never `activities`, `raw_payload`, `sheet_*`, `ingestion_runs`, `metric_value_conflicts`, or internal insights.

Helpers: `current_app_role()`, `current_client_id()`, `report_published()`, `action_item_client()`.

## Metric availability

`metric_definitions.requires` is **any-of**: a metric is enabled for a client if at least one listed source is `active` in `client_sources`. An empty array means always available (sheet-fed metrics). The seed disables everything else with a `disabled_reason`.
