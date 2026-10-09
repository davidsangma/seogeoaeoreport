-- Seed: clients, sources, metric catalog, activity types, client_metrics.

-- Clients ------------------------------------------------------------------------
insert into public.clients (slug, domain, path_prefix, display_name, tier) values
  ('foodiesonly',            'foodiesonly.in',                  null,      'Foodies Only',                'full'),
  ('letsboing',              'letsboing.com',                   null,      'Lets Boing',                  'full'),
  ('happytummy',             'happytummy.aashirvaad.com',       null,      'Happy Tummy (Aashirvaad)',    'full'),
  ('mykitchendiaries',       'mykitchendiaries.com',            null,      'My Kitchen Diaries',          'full'),
  ('thebar',                 'thebar.com',                      '/en-in/', 'The Bar (India)',             'partial'),
  ('aashirvaad-dairydelights','aashirvaaddairydelights.com',    null,      'Aashirvaad Dairy Delights',   'partial'),
  ('aashirvaad',             'aashirvaad.com',                  null,      'Aashirvaad',                  'external_only'),
  ('vikramtea',              'vikramtea.com',                   null,      'Vikram Tea',                  'external_only'),
  ('crompton',               'crompton.co.in',                  null,      'Crompton',                    'external_only'),
  ('usha',                   'usha.com',                        null,      'Usha',                        'external_only');

-- Client sources (property_identifier / auth_account left null on purpose) ---------
insert into public.client_sources (client_id, source, access_status, ingestion_path)
select c.id, s.source::public.source_system, s.status::public.access_status, s.path::public.ingestion_path
from (values
  ('foodiesonly',             'adobe', 'active',  'manual_sheet'),
  ('foodiesonly',             'gsc',   'active',  'api'),
  ('letsboing',               'adobe', 'active',  'manual_sheet'),
  ('letsboing',               'gsc',   'active',  'api'),
  ('happytummy',              'ga4',   'active',  'api'),
  ('happytummy',              'gsc',   'active',  'api'),
  ('mykitchendiaries',        'ga4',   'active',  'api'),
  ('mykitchendiaries',        'gsc',   'active',  'api'),
  ('thebar',                  'ga4',   'active',  'api'),
  ('thebar',                  'gsc',   'none',    null),
  ('aashirvaad-dairydelights','gsc',   'active',  'api'),
  ('aashirvaad-dairydelights','ga4',   'none',    null),
  ('aashirvaad',              'gsc',   'pending', 'api'),
  ('aashirvaad',              'ga4',   'pending', 'api'),
  ('vikramtea',               'gsc',   'pending', 'api'),
  ('vikramtea',               'ga4',   'pending', 'api'),
  ('crompton',                'gsc',   'pending', 'api'),
  ('crompton',                'ga4',   'pending', 'api'),
  ('usha',                    'gsc',   'pending', 'api'),
  ('usha',                    'ga4',   'pending', 'api')
) as s(slug, source, status, path)
join public.clients c on c.slug = s.slug;

insert into public.client_sources (client_id, source, access_status, ingestion_path)
select c.id, s.source, 'active', 'api'
from public.clients c
cross join (values ('dataforseo'::public.source_system), ('crux'::public.source_system)) as s(source);

-- Metric catalog -----------------------------------------------------------------
-- (id, name, tab, type, unit, aggregation, higher_is_better, primary, fallback, requires,
--  manual_eligible, is_core, supports_segments, definition, display_order)
insert into public.metric_definitions
  (id, name, tab, metric_type, unit, aggregation, higher_is_better, primary_source,
   fallback_sources, requires, manual_eligible, is_core, supports_segments, definition, display_order)
values
-- SEO output: analytics
('seo_organic_sessions', 'Organic sessions', 'seo', 'output', 'count', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, true, false,
 $$Organic sessions: GA4 sessions where sessionDefaultChannelGroup = 'Organic Search', or Adobe visits where Marketing Channel = 'Natural Search', for the calendar month.$$, 100),
('seo_organic_users', 'Organic users', 'seo', 'output', 'count', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, true, false,
 $$Organic users: GA4 totalUsers on sessions where sessionDefaultChannelGroup = 'Organic Search', or Adobe unique visitors where Marketing Channel = 'Natural Search', for the calendar month.$$, 110),
('seo_organic_engaged_sessions', 'Organic engaged sessions', 'seo', 'output', 'count', 'sum', true, 'ga4', '{}', '{ga4}', true, false, false,
 $$Organic engaged sessions: GA4 engagedSessions (lasting over 10 seconds, or with a key event, or with 2+ page views) where sessionDefaultChannelGroup = 'Organic Search', for the calendar month.$$, 120),
('seo_organic_conversions', 'Organic conversions', 'seo', 'output', 'count', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, true, false,
 $$Organic conversions: count of the client's configured GA4 key events (or Adobe conversion success events) on sessions from Organic Search / Natural Search, for the calendar month.$$, 130),
('seo_organic_revenue', 'Organic revenue', 'seo', 'output', 'currency_inr', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, false, false,
 $$Organic revenue: GA4 purchaseRevenue (or Adobe revenue) in INR on sessions from Organic Search / Natural Search, for the calendar month.$$, 140),
-- SEO output: GSC
('seo_gsc_clicks', 'GSC clicks', 'seo', 'output', 'count', 'sum', true, 'gsc', '{}', '{gsc}', true, true, false,
 $$GSC clicks: total Google Search Console web-search clicks for the client's property (limited to its path prefix, if any) for the calendar month.$$, 200),
('seo_gsc_impressions', 'GSC impressions', 'seo', 'output', 'count', 'sum', true, 'gsc', '{}', '{gsc}', true, true, false,
 $$GSC impressions: total Google Search Console web-search impressions for the client's property (limited to its path prefix, if any) for the calendar month.$$, 210),
('seo_gsc_ctr', 'GSC CTR', 'seo', 'output', 'percent', 'avg', true, 'gsc', '{}', '{gsc}', true, true, false,
 $$GSC CTR: total GSC clicks divided by total GSC impressions for the calendar month, as a percentage from 0 to 100 (not an average of per-query CTRs).$$, 220),
('seo_gsc_avg_position', 'GSC average position', 'seo', 'output', 'position', 'avg', false, 'gsc', '{}', '{gsc}', true, true, false,
 $$GSC average position: the impression-weighted average Google position across all queries and pages in the property for the calendar month (lower is better).$$, 230),
('seo_gsc_brand_clicks', 'GSC brand clicks', 'seo', 'output', 'count', 'sum', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$GSC brand clicks: GSC clicks from queries that match the client's brand_regex, for the calendar month.$$, 240),
('seo_gsc_nonbrand_clicks', 'GSC non-brand clicks', 'seo', 'output', 'count', 'sum', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$GSC non-brand clicks: GSC clicks from queries that do not match the client's brand_regex, for the calendar month.$$, 250),
('seo_pages_with_clicks', 'Pages with clicks', 'seo', 'output', 'count', 'latest', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$Pages with clicks: count of distinct page URLs that received at least one GSC click during the calendar month.$$, 260),
('seo_queries_with_clicks', 'Queries with clicks', 'seo', 'output', 'count', 'latest', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$Queries with clicks: count of distinct search queries that received at least one GSC click during the calendar month.$$, 270),
-- SEO output: rankings
('seo_kw_pos_1_3', 'Keywords ranking 1-3', 'seo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Keywords ranking 1-3: count of the client's active tracked keywords whose organic Google position is 1 to 3 in the month's DataForSEO SERP snapshot.$$, 300),
('seo_kw_pos_4_10', 'Keywords ranking 4-10', 'seo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Keywords ranking 4-10: count of the client's active tracked keywords whose organic Google position is 4 to 10 in the month's DataForSEO SERP snapshot.$$, 310),
('seo_kw_pos_11_20', 'Keywords ranking 11-20', 'seo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Keywords ranking 11-20: count of the client's active tracked keywords whose organic Google position is 11 to 20 in the month's DataForSEO SERP snapshot.$$, 320),
('seo_ranked_keywords_total', 'Ranked keywords (total)', 'seo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Ranked keywords total: count of the client's active tracked keywords with any organic Google position in the top 100 in the month's DataForSEO SERP snapshot.$$, 330),
-- SEO output: Core Web Vitals
('seo_cwv_lcp_p75', 'LCP (p75)', 'seo', 'output', 'ms', 'p75', false, 'crux', '{}', '{crux}', false, true, false,
 $$LCP p75: 75th-percentile Largest Contentful Paint in milliseconds from the CrUX monthly dataset for the client's origin, all form factors (lower is better).$$, 400),
('seo_cwv_inp_p75', 'INP (p75)', 'seo', 'output', 'ms', 'p75', false, 'crux', '{}', '{crux}', false, true, false,
 $$INP p75: 75th-percentile Interaction to Next Paint in milliseconds from the CrUX monthly dataset for the client's origin, all form factors (lower is better).$$, 410),
('seo_cwv_cls_p75', 'CLS (p75)', 'seo', 'output', 'score', 'p75', false, 'crux', '{}', '{crux}', false, true, false,
 $$CLS p75: 75th-percentile Cumulative Layout Shift score (unitless) from the CrUX monthly dataset for the client's origin, all form factors (lower is better).$$, 420),
-- SEO output: technical health
('seo_pages_4xx', 'Pages returning 4xx', 'seo', 'output', 'count', 'latest', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Pages returning 4xx: count of internal URLs that returned an HTTP 4xx status in the month's DataForSEO OnPage crawl (lower is better).$$, 500),
('seo_pages_5xx', 'Pages returning 5xx', 'seo', 'output', 'count', 'latest', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Pages returning 5xx: count of internal URLs that returned an HTTP 5xx status in the month's DataForSEO OnPage crawl (lower is better).$$, 510),
('seo_redirect_chains', 'Redirect chains', 'seo', 'output', 'count', 'latest', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Redirect chains: count of internal URLs whose redirect path has two or more hops before the final destination, in the month's DataForSEO OnPage crawl (lower is better).$$, 520),
('seo_titles_dup_or_missing', 'Titles duplicate or missing', 'seo', 'output', 'count', 'latest', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Titles duplicate or missing: count of crawled indexable pages with an empty title tag or a title shared with another crawled page, in the month's DataForSEO OnPage crawl (lower is better).$$, 530),
('seo_broken_internal_links', 'Broken internal links', 'seo', 'output', 'count', 'latest', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Broken internal links: count of internal links pointing to a URL that returned 4xx or 5xx in the month's DataForSEO OnPage crawl (lower is better).$$, 540),
('seo_ref_domains_new', 'New referring domains', 'seo', 'output', 'count', 'sum', true, 'dataforseo', '{}', '{dataforseo}', false, false, false,
 $$New referring domains: count of domains first seen linking to the client's site during the calendar month, per DataForSEO Backlinks.$$, 550),
('seo_ref_domains_lost', 'Lost referring domains', 'seo', 'output', 'count', 'sum', false, 'dataforseo', '{}', '{dataforseo}', false, false, false,
 $$Lost referring domains: count of domains that previously linked to the client's site and no longer do as of the end of the calendar month, per DataForSEO Backlinks (lower is better).$$, 560),
-- SEO input (input_sheet)
('seo_articles_published', 'Articles published', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Articles published: count of new articles or blog posts that went live on the client's site during the calendar month, per the team input sheet.$$, 600),
('seo_articles_refreshed', 'Articles refreshed', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Articles refreshed: count of existing articles with materially updated content that were republished during the calendar month, per the team input sheet.$$, 610),
('seo_pages_onpage_optimized', 'Pages on-page optimized', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Pages on-page optimized: count of distinct pages whose title, meta description, headings or body copy were optimized for SEO during the calendar month, per the team input sheet.$$, 620),
('seo_internal_links_added', 'Internal links added', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Internal links added: count of new contextual internal links placed on the client's site during the calendar month, per the team input sheet.$$, 630),
('seo_tech_tickets_raised', 'Tech tickets raised', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Tech tickets raised: count of technical SEO tickets raised with the client's tech team during the calendar month, per the team input sheet.$$, 640),
('seo_tech_fixes_deployed', 'Tech fixes deployed', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Tech fixes deployed: count of technical SEO tickets confirmed live on the client's site during the calendar month, per the team input sheet.$$, 650),
('seo_tech_tickets_open_30d', 'Tech tickets open > 30 days', 'seo', 'input', 'count', 'latest', false, 'input_sheet', '{}', '{}', false, false, false,
 $$Tech tickets open over 30 days: count of technical SEO tickets still not deployed more than 30 days after being raised, as of the last day of the calendar month (lower is better).$$, 660),
('seo_tech_median_days_to_fix', 'Median days to fix', 'seo', 'input', 'count', 'median', false, 'input_sheet', '{}', '{}', false, false, false,
 $$Median days to fix: median number of calendar days (stored as a count of days) from a technical SEO ticket being raised to its fix being deployed, for tickets deployed in the calendar month (lower is better).$$, 670),
('seo_backlinks_placed', 'Backlinks placed', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Backlinks placed: count of new external backlinks to the client's site secured during the calendar month, per the team input sheet.$$, 680),
('seo_guest_posts_live', 'Guest posts live', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Guest posts live: count of guest posts that went live on third-party sites linking to the client during the calendar month, per the team input sheet.$$, 690),
('seo_social_posts', 'Social posts', 'seo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, true,
 $$Social posts: count of social posts published for the client during the calendar month, per the team input sheet, segmented by platform (segment 'platform:<name>', e.g. 'platform:instagram').$$, 700),
-- AEO output
('aeo_kw_with_ai_overview', 'Keywords with AI Overview', 'aeo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Keywords with AI Overview: count of the client's active tracked keywords for which Google shows an AI Overview in the month's DataForSEO SERP snapshot.$$, 800),
('aeo_aio_citing_client', 'AI Overviews citing client', 'aeo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$AI Overviews citing client: count of tracked keywords whose Google AI Overview cites at least one URL on the client's domain in the month's DataForSEO SERP snapshot.$$, 810),
('aeo_featured_snippets_owned', 'Featured snippets owned', 'aeo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Featured snippets owned: count of tracked keywords whose Google featured snippet is sourced from the client's domain in the month's DataForSEO SERP snapshot.$$, 820),
('aeo_paa_appearances', 'People Also Ask appearances', 'aeo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$People Also Ask appearances: count of tracked keywords whose People Also Ask box includes an answer sourced from the client's domain in the month's DataForSEO SERP snapshot.$$, 830),
('aeo_ai_mode_citing_client', 'AI Mode citing client', 'aeo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$AI Mode citing client: count of tracked keywords whose Google AI Mode answer cites a URL on the client's domain in the month's DataForSEO SERP snapshot.$$, 840),
('aeo_question_query_clicks', 'Question-query clicks', 'aeo', 'output', 'count', 'sum', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$Question-query clicks: GSC clicks from queries that begin with a question word (who, what, when, where, why, how, which, can, does, is, are, should) for the calendar month.$$, 850),
('aeo_question_query_ctr', 'Question-query CTR', 'aeo', 'output', 'percent', 'avg', true, 'gsc', '{}', '{gsc}', false, true, false,
 $$Question-query CTR: clicks divided by impressions, as a percentage from 0 to 100, for GSC queries that begin with a question word, for the calendar month.$$, 860),
-- AEO input
('aeo_pages_schema_added', 'Pages with schema added', 'aeo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Pages with schema added: count of distinct pages where new structured data (e.g. FAQPage, HowTo, Article JSON-LD) went live during the calendar month, per the team input sheet.$$, 900),
('aeo_qa_blocks_added', 'Q&A blocks added', 'aeo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Q&A blocks added: count of question-and-answer content blocks added to pages during the calendar month, per the team input sheet.$$, 910),
('aeo_schema_errors_fixed', 'Schema errors fixed', 'aeo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Schema errors fixed: count of structured-data errors (as flagged in Search Console or a validator) resolved on the live site during the calendar month, per the team input sheet.$$, 920),
-- GEO output
('geo_prompts_brand_mentioned', 'Prompts mentioning brand', 'geo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, true,
 $$Prompts mentioning brand: count of prompts in the client's active GEO prompt panel whose LLM response mentions the client's brand, per LLM (segment 'llm:<name>') and across any LLM (segment 'all'), for the calendar month.$$, 1000),
('geo_prompts_domain_cited', 'Prompts citing domain', 'geo', 'output', 'count', 'latest', true, 'dataforseo', '{}', '{dataforseo}', false, true, true,
 $$Prompts citing domain: count of prompts in the client's active GEO prompt panel whose LLM response cites a URL on the client's domain, per LLM (segment 'llm:<name>') and across any LLM (segment 'all'), for the calendar month.$$, 1010),
('geo_mention_share', 'Brand mention share', 'geo', 'output', 'percent', 'avg', true, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Brand mention share: percentage (0 to 100) of prompt-by-LLM responses in the calendar month that mention the client's brand, out of all responses collected.$$, 1020),
('geo_avg_mention_position', 'Avg brand mention position', 'geo', 'output', 'position', 'avg', false, 'dataforseo', '{}', '{dataforseo}', false, true, false,
 $$Average brand mention position: average rank (1 = first brand named) of the client's brand among all brands named in responses that mention it, for the calendar month (lower is better).$$, 1030),
('geo_ai_referral_sessions', 'AI referral sessions', 'geo', 'output', 'count', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, true, false,
 $$AI referral sessions: sessions whose source matches chatgpt.com|perplexity.ai|gemini.google.com|copilot.microsoft.com|claude.ai, for the calendar month.$$, 1040),
('geo_ai_referral_conversions', 'AI referral conversions', 'geo', 'output', 'count', 'sum', true, 'ga4', '{adobe}', '{ga4,adobe}', true, true, false,
 $$AI referral conversions: count of the client's configured key events (GA4) or conversion success events (Adobe) on sessions whose source matches chatgpt.com|perplexity.ai|gemini.google.com|copilot.microsoft.com|claude.ai, for the calendar month.$$, 1050),
('geo_ai_crawler_hits', 'AI crawler hits', 'geo', 'output', 'count', 'sum', true, 'manual_sheet', '{}', '{}', true, false, false,
 $$AI crawler hits: count of requests in the client's server or CDN logs from GPTBot, OAI-SearchBot, ClaudeBot, PerplexityBot or Google-Extended for the calendar month, entered manually.$$, 1060),
-- GEO input
('geo_comparison_pages_published', 'Comparison pages published', 'geo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Comparison pages published: count of 'X vs Y' or 'best X' comparison pages that went live on the client's site during the calendar month, per the team input sheet.$$, 1100),
('geo_third_party_placements', 'Third-party placements', 'geo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Third-party placements: count of new listings or mentions of the client secured on third-party sites that LLMs commonly cite (e.g. review sites, directories, forums) during the calendar month, per the team input sheet.$$, 1110),
('geo_pr_mentions', 'PR mentions', 'geo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$PR mentions: count of earned press or media articles mentioning the client's brand that were published during the calendar month, per the team input sheet.$$, 1120),
('geo_org_product_schema_added', 'Org/Product schema added', 'geo', 'input', 'count', 'sum', true, 'input_sheet', '{}', '{}', false, false, false,
 $$Org/Product schema added: count of pages where new Organization or Product structured data went live during the calendar month, per the team input sheet.$$, 1130);

-- Activity types -----------------------------------------------------------------
insert into public.activity_types (id, tab, maps_to_metric_id, label) values
  ('article_published',         'seo', 'seo_articles_published',         'Article published'),
  ('article_refreshed',         'seo', 'seo_articles_refreshed',         'Article refreshed'),
  ('onpage_optimized',          'seo', 'seo_pages_onpage_optimized',     'Page on-page optimized'),
  ('internal_links_added',      'seo', 'seo_internal_links_added',       'Internal links added'),
  ('tech_ticket_raised',        'seo', 'seo_tech_tickets_raised',        'Tech ticket raised'),
  ('tech_fix_deployed',         'seo', 'seo_tech_fixes_deployed',        'Tech fix deployed'),
  ('backlink_placed',           'seo', 'seo_backlinks_placed',           'Backlink placed'),
  ('guest_post_live',           'seo', 'seo_guest_posts_live',           'Guest post live'),
  ('social_post',               'seo', 'seo_social_posts',               'Social post'),
  ('schema_added',              'aeo', 'aeo_pages_schema_added',         'Schema added'),
  ('qa_block_added',            'aeo', 'aeo_qa_blocks_added',            'Q&A block added'),
  ('schema_error_fixed',        'aeo', 'aeo_schema_errors_fixed',        'Schema error fixed'),
  ('comparison_page_published', 'geo', 'geo_comparison_pages_published', 'Comparison page published'),
  ('third_party_placement',     'geo', 'geo_third_party_placements',     'Third-party placement'),
  ('pr_mention',                'geo', 'geo_pr_mentions',                'PR mention');

-- client_metrics: enable everything, then disable where no required source is active.
-- `requires` is any-of, and an empty array means always available.
insert into public.client_metrics (client_id, metric_id)
select c.id, m.id from public.clients c cross join public.metric_definitions m;

update public.client_metrics cm
set enabled = false,
    disabled_reason = (
      select case
        when exists (
          select 1 from public.client_sources s
          where s.client_id = cm.client_id and s.source = any (m.requires) and s.access_status = 'pending'
        ) then 'pending ' || (select string_agg(upper(r::text), '/') from unnest(m.requires) r) || ' access'
        else 'no ' || (select string_agg(upper(r::text), '/') from unnest(m.requires) r) || ' access'
      end
    )
from public.metric_definitions m
where m.id = cm.metric_id
  and cardinality(m.requires) > 0
  and not exists (
    select 1 from public.client_sources s
    where s.client_id = cm.client_id and s.source = any (m.requires) and s.access_status = 'active'
  );
