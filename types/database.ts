export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      action_evaluations: {
        Row: {
          action_item_id: string
          approved: boolean
          approved_by: string | null
          created_at: string
          evaluated_month: string
          executed_count: number | null
          execution_status: Database["public"]["Enums"]["execution_status"]
          id: string
          metric_actual: number | null
          metric_baseline: number | null
          narrative: string | null
          net_lift_pct: number | null
          site_trend_pct: number | null
          updated_at: string
          verdict: Database["public"]["Enums"]["verdict"] | null
        }
        Insert: {
          action_item_id: string
          approved?: boolean
          approved_by?: string | null
          created_at?: string
          evaluated_month: string
          executed_count?: number | null
          execution_status: Database["public"]["Enums"]["execution_status"]
          id?: string
          metric_actual?: number | null
          metric_baseline?: number | null
          narrative?: string | null
          net_lift_pct?: number | null
          site_trend_pct?: number | null
          updated_at?: string
          verdict?: Database["public"]["Enums"]["verdict"] | null
        }
        Update: {
          action_item_id?: string
          approved?: boolean
          approved_by?: string | null
          created_at?: string
          evaluated_month?: string
          executed_count?: number | null
          execution_status?: Database["public"]["Enums"]["execution_status"]
          id?: string
          metric_actual?: number | null
          metric_baseline?: number | null
          narrative?: string | null
          net_lift_pct?: number | null
          site_trend_pct?: number | null
          updated_at?: string
          verdict?: Database["public"]["Enums"]["verdict"] | null
        }
        Relationships: [
          {
            foreignKeyName: "action_evaluations_action_item_id_fkey"
            columns: ["action_item_id"]
            isOneToOne: false
            referencedRelation: "action_items"
            referencedColumns: ["id"]
          },
        ]
      }
      action_items: {
        Row: {
          baseline_value: number | null
          carried_from_id: string | null
          client_id: string
          code: string
          created_at: string
          due_date: string | null
          hypothesis: string | null
          id: string
          owner: string | null
          planned_activity_type: string | null
          planned_for_month: string
          planned_quantity: number | null
          status: Database["public"]["Enums"]["action_status"]
          tab: Database["public"]["Enums"]["tab"]
          target_keywords: string[]
          target_metric_id: string | null
          target_urls: string[]
          target_value: number | null
          title: string
          updated_at: string
        }
        Insert: {
          baseline_value?: number | null
          carried_from_id?: string | null
          client_id: string
          code: string
          created_at?: string
          due_date?: string | null
          hypothesis?: string | null
          id?: string
          owner?: string | null
          planned_activity_type?: string | null
          planned_for_month: string
          planned_quantity?: number | null
          status?: Database["public"]["Enums"]["action_status"]
          tab: Database["public"]["Enums"]["tab"]
          target_keywords?: string[]
          target_metric_id?: string | null
          target_urls?: string[]
          target_value?: number | null
          title: string
          updated_at?: string
        }
        Update: {
          baseline_value?: number | null
          carried_from_id?: string | null
          client_id?: string
          code?: string
          created_at?: string
          due_date?: string | null
          hypothesis?: string | null
          id?: string
          owner?: string | null
          planned_activity_type?: string | null
          planned_for_month?: string
          planned_quantity?: number | null
          status?: Database["public"]["Enums"]["action_status"]
          tab?: Database["public"]["Enums"]["tab"]
          target_keywords?: string[]
          target_metric_id?: string | null
          target_urls?: string[]
          target_value?: number | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "action_items_carried_from_id_fkey"
            columns: ["carried_from_id"]
            isOneToOne: false
            referencedRelation: "action_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "action_items_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "action_items_planned_activity_type_fkey"
            columns: ["planned_activity_type"]
            isOneToOne: false
            referencedRelation: "activity_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "action_items_target_metric_id_fkey"
            columns: ["target_metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      activities: {
        Row: {
          action_item_id: string | null
          activity_date: string
          activity_type: string
          client_id: string
          created_at: string
          id: string
          mapping_confidence: number | null
          needs_review: boolean
          period_month: string | null
          quantity: number
          raw_payload: Json | null
          reviewed_at: string | null
          reviewed_by: string | null
          sheet_registry_id: string
          source_row_key: string
          tab: Database["public"]["Enums"]["tab"]
          updated_at: string
          url: string | null
        }
        Insert: {
          action_item_id?: string | null
          activity_date: string
          activity_type: string
          client_id: string
          created_at?: string
          id?: string
          mapping_confidence?: number | null
          needs_review?: boolean
          period_month?: string | null
          quantity?: number
          raw_payload?: Json | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          sheet_registry_id: string
          source_row_key: string
          tab: Database["public"]["Enums"]["tab"]
          updated_at?: string
          url?: string | null
        }
        Update: {
          action_item_id?: string | null
          activity_date?: string
          activity_type?: string
          client_id?: string
          created_at?: string
          id?: string
          mapping_confidence?: number | null
          needs_review?: boolean
          period_month?: string | null
          quantity?: number
          raw_payload?: Json | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          sheet_registry_id?: string
          source_row_key?: string
          tab?: Database["public"]["Enums"]["tab"]
          updated_at?: string
          url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activities_action_item_id_fkey"
            columns: ["action_item_id"]
            isOneToOne: false
            referencedRelation: "action_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_activity_type_fkey"
            columns: ["activity_type"]
            isOneToOne: false
            referencedRelation: "activity_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_sheet_registry_id_fkey"
            columns: ["sheet_registry_id"]
            isOneToOne: false
            referencedRelation: "sheet_registry"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_types: {
        Row: {
          created_at: string
          id: string
          label: string
          maps_to_metric_id: string
          tab: Database["public"]["Enums"]["tab"]
          updated_at: string
        }
        Insert: {
          created_at?: string
          id: string
          label: string
          maps_to_metric_id: string
          tab: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          label?: string
          maps_to_metric_id?: string
          tab?: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "activity_types_maps_to_metric_id_fkey"
            columns: ["maps_to_metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      app_users: {
        Row: {
          client_id: string | null
          created_at: string
          role: Database["public"]["Enums"]["app_role"]
          updated_at: string
          user_id: string
        }
        Insert: {
          client_id?: string | null
          created_at?: string
          role: Database["public"]["Enums"]["app_role"]
          updated_at?: string
          user_id: string
        }
        Update: {
          client_id?: string | null
          created_at?: string
          role?: Database["public"]["Enums"]["app_role"]
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "app_users_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      client_metrics: {
        Row: {
          client_id: string
          created_at: string
          disabled_reason: string | null
          enabled: boolean
          metric_id: string
          updated_at: string
        }
        Insert: {
          client_id: string
          created_at?: string
          disabled_reason?: string | null
          enabled?: boolean
          metric_id: string
          updated_at?: string
        }
        Update: {
          client_id?: string
          created_at?: string
          disabled_reason?: string | null
          enabled?: boolean
          metric_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "client_metrics_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "client_metrics_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      client_sources: {
        Row: {
          access_status: Database["public"]["Enums"]["access_status"]
          auth_account: string | null
          client_id: string
          created_at: string
          id: string
          ingestion_path: Database["public"]["Enums"]["ingestion_path"] | null
          last_success_at: string | null
          notes: string | null
          property_identifier: string | null
          source: Database["public"]["Enums"]["source_system"]
          updated_at: string
        }
        Insert: {
          access_status: Database["public"]["Enums"]["access_status"]
          auth_account?: string | null
          client_id: string
          created_at?: string
          id?: string
          ingestion_path?: Database["public"]["Enums"]["ingestion_path"] | null
          last_success_at?: string | null
          notes?: string | null
          property_identifier?: string | null
          source: Database["public"]["Enums"]["source_system"]
          updated_at?: string
        }
        Update: {
          access_status?: Database["public"]["Enums"]["access_status"]
          auth_account?: string | null
          client_id?: string
          created_at?: string
          id?: string
          ingestion_path?: Database["public"]["Enums"]["ingestion_path"] | null
          last_success_at?: string | null
          notes?: string | null
          property_identifier?: string | null
          source?: Database["public"]["Enums"]["source_system"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "client_sources_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      clients: {
        Row: {
          active: boolean
          brand_regex: string | null
          created_at: string
          display_name: string
          domain: string
          id: string
          language: string
          market: string
          path_prefix: string | null
          slug: string
          tier: Database["public"]["Enums"]["client_tier"]
          updated_at: string
        }
        Insert: {
          active?: boolean
          brand_regex?: string | null
          created_at?: string
          display_name: string
          domain: string
          id?: string
          language?: string
          market?: string
          path_prefix?: string | null
          slug: string
          tier: Database["public"]["Enums"]["client_tier"]
          updated_at?: string
        }
        Update: {
          active?: boolean
          brand_regex?: string | null
          created_at?: string
          display_name?: string
          domain?: string
          id?: string
          language?: string
          market?: string
          path_prefix?: string | null
          slug?: string
          tier?: Database["public"]["Enums"]["client_tier"]
          updated_at?: string
        }
        Relationships: []
      }
      competitors: {
        Row: {
          active: boolean
          brand_name: string | null
          client_id: string
          created_at: string
          domain: string
          id: string
          updated_at: string
        }
        Insert: {
          active?: boolean
          brand_name?: string | null
          client_id: string
          created_at?: string
          domain: string
          id?: string
          updated_at?: string
        }
        Update: {
          active?: boolean
          brand_name?: string | null
          client_id?: string
          created_at?: string
          domain?: string
          id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "competitors_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      geo_prompt_results: {
        Row: {
          brand_mentioned: boolean
          cited_domains: Json
          client_id: string
          competitors_mentioned: Json
          created_at: string
          domain_cited: boolean
          id: string
          llm: string
          mention_position: number | null
          period_month: string
          prompt_id: string
          raw_response_ref: string | null
          updated_at: string
        }
        Insert: {
          brand_mentioned?: boolean
          cited_domains?: Json
          client_id: string
          competitors_mentioned?: Json
          created_at?: string
          domain_cited?: boolean
          id?: string
          llm: string
          mention_position?: number | null
          period_month: string
          prompt_id: string
          raw_response_ref?: string | null
          updated_at?: string
        }
        Update: {
          brand_mentioned?: boolean
          cited_domains?: Json
          client_id?: string
          competitors_mentioned?: Json
          created_at?: string
          domain_cited?: boolean
          id?: string
          llm?: string
          mention_position?: number | null
          period_month?: string
          prompt_id?: string
          raw_response_ref?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "geo_prompt_results_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geo_prompt_results_prompt_id_fkey"
            columns: ["prompt_id"]
            isOneToOne: false
            referencedRelation: "geo_prompts"
            referencedColumns: ["id"]
          },
        ]
      }
      geo_prompts: {
        Row: {
          active: boolean
          client_id: string
          created_at: string
          id: string
          intent: string | null
          panel_version: number
          prompt: string
          updated_at: string
        }
        Insert: {
          active?: boolean
          client_id: string
          created_at?: string
          id?: string
          intent?: string | null
          panel_version?: number
          prompt: string
          updated_at?: string
        }
        Update: {
          active?: boolean
          client_id?: string
          created_at?: string
          id?: string
          intent?: string | null
          panel_version?: number
          prompt?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "geo_prompts_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      ingestion_runs: {
        Row: {
          client_id: string | null
          created_at: string
          error: string | null
          finished_at: string | null
          id: string
          period_month: string
          rows_written: number
          source: Database["public"]["Enums"]["source_system"]
          started_at: string
          status: Database["public"]["Enums"]["run_status"]
          updated_at: string
        }
        Insert: {
          client_id?: string | null
          created_at?: string
          error?: string | null
          finished_at?: string | null
          id?: string
          period_month: string
          rows_written?: number
          source: Database["public"]["Enums"]["source_system"]
          started_at?: string
          status?: Database["public"]["Enums"]["run_status"]
          updated_at?: string
        }
        Update: {
          client_id?: string | null
          created_at?: string
          error?: string | null
          finished_at?: string | null
          id?: string
          period_month?: string
          rows_written?: number
          source?: Database["public"]["Enums"]["source_system"]
          started_at?: string
          status?: Database["public"]["Enums"]["run_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "ingestion_runs_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      insights: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          audience: Database["public"]["Enums"]["audience"]
          body: string
          client_id: string
          created_at: string
          generated_by: string
          id: string
          metric_type: Database["public"]["Enums"]["metric_type"] | null
          period_month: string
          status: Database["public"]["Enums"]["workflow_status"]
          supporting_metric_ids: string[]
          tab: Database["public"]["Enums"]["tab"]
          updated_at: string
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          audience: Database["public"]["Enums"]["audience"]
          body: string
          client_id: string
          created_at?: string
          generated_by: string
          id?: string
          metric_type?: Database["public"]["Enums"]["metric_type"] | null
          period_month: string
          status?: Database["public"]["Enums"]["workflow_status"]
          supporting_metric_ids?: string[]
          tab: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          audience?: Database["public"]["Enums"]["audience"]
          body?: string
          client_id?: string
          created_at?: string
          generated_by?: string
          id?: string
          metric_type?: Database["public"]["Enums"]["metric_type"] | null
          period_month?: string
          status?: Database["public"]["Enums"]["workflow_status"]
          supporting_metric_ids?: string[]
          tab?: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "insights_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      keyword_rankings: {
        Row: {
          ai_mode_cites_client: boolean
          aio_cites_client: boolean
          client_id: string
          client_in_paa: boolean
          created_at: string
          has_ai_overview: boolean
          has_featured_snippet: boolean
          id: string
          keyword_id: string
          owns_featured_snippet: boolean
          paa_present: boolean
          period_month: string
          position: number | null
          ranking_url: string | null
          updated_at: string
        }
        Insert: {
          ai_mode_cites_client?: boolean
          aio_cites_client?: boolean
          client_id: string
          client_in_paa?: boolean
          created_at?: string
          has_ai_overview?: boolean
          has_featured_snippet?: boolean
          id?: string
          keyword_id: string
          owns_featured_snippet?: boolean
          paa_present?: boolean
          period_month: string
          position?: number | null
          ranking_url?: string | null
          updated_at?: string
        }
        Update: {
          ai_mode_cites_client?: boolean
          aio_cites_client?: boolean
          client_id?: string
          client_in_paa?: boolean
          created_at?: string
          has_ai_overview?: boolean
          has_featured_snippet?: boolean
          id?: string
          keyword_id?: string
          owns_featured_snippet?: boolean
          paa_present?: boolean
          period_month?: string
          position?: number | null
          ranking_url?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "keyword_rankings_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "keyword_rankings_keyword_id_fkey"
            columns: ["keyword_id"]
            isOneToOne: false
            referencedRelation: "tracked_keywords"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_definitions: {
        Row: {
          aggregation: Database["public"]["Enums"]["aggregation"]
          created_at: string
          definition: string
          display_order: number
          fallback_sources: Database["public"]["Enums"]["source_system"][]
          higher_is_better: boolean
          id: string
          is_core: boolean
          manual_eligible: boolean
          metric_type: Database["public"]["Enums"]["metric_type"]
          name: string
          primary_source: Database["public"]["Enums"]["source_system"]
          requires: Database["public"]["Enums"]["source_system"][]
          supports_segments: boolean
          tab: Database["public"]["Enums"]["tab"]
          unit: Database["public"]["Enums"]["unit"]
          updated_at: string
        }
        Insert: {
          aggregation: Database["public"]["Enums"]["aggregation"]
          created_at?: string
          definition: string
          display_order?: number
          fallback_sources?: Database["public"]["Enums"]["source_system"][]
          higher_is_better?: boolean
          id: string
          is_core?: boolean
          manual_eligible?: boolean
          metric_type: Database["public"]["Enums"]["metric_type"]
          name: string
          primary_source: Database["public"]["Enums"]["source_system"]
          requires?: Database["public"]["Enums"]["source_system"][]
          supports_segments?: boolean
          tab: Database["public"]["Enums"]["tab"]
          unit: Database["public"]["Enums"]["unit"]
          updated_at?: string
        }
        Update: {
          aggregation?: Database["public"]["Enums"]["aggregation"]
          created_at?: string
          definition?: string
          display_order?: number
          fallback_sources?: Database["public"]["Enums"]["source_system"][]
          higher_is_better?: boolean
          id?: string
          is_core?: boolean
          manual_eligible?: boolean
          metric_type?: Database["public"]["Enums"]["metric_type"]
          name?: string
          primary_source?: Database["public"]["Enums"]["source_system"]
          requires?: Database["public"]["Enums"]["source_system"][]
          supports_segments?: boolean
          tab?: Database["public"]["Enums"]["tab"]
          unit?: Database["public"]["Enums"]["unit"]
          updated_at?: string
        }
        Relationships: []
      }
      metric_values: {
        Row: {
          client_id: string
          created_at: string
          entered_by: string | null
          evidence_link: string | null
          id: string
          ingested_at: string
          ingestion_path: Database["public"]["Enums"]["ingestion_path"]
          metric_id: string
          period_month: string
          run_id: string | null
          segment: string
          source: Database["public"]["Enums"]["source_system"]
          updated_at: string
          value: number
        }
        Insert: {
          client_id: string
          created_at?: string
          entered_by?: string | null
          evidence_link?: string | null
          id?: string
          ingested_at?: string
          ingestion_path: Database["public"]["Enums"]["ingestion_path"]
          metric_id: string
          period_month: string
          run_id?: string | null
          segment?: string
          source: Database["public"]["Enums"]["source_system"]
          updated_at?: string
          value: number
        }
        Update: {
          client_id?: string
          created_at?: string
          entered_by?: string | null
          evidence_link?: string | null
          id?: string
          ingested_at?: string
          ingestion_path?: Database["public"]["Enums"]["ingestion_path"]
          metric_id?: string
          period_month?: string
          run_id?: string | null
          segment?: string
          source?: Database["public"]["Enums"]["source_system"]
          updated_at?: string
          value?: number
        }
        Relationships: [
          {
            foreignKeyName: "metric_values_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_values_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_values_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "ingestion_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      page_performance: {
        Row: {
          avg_position: number | null
          clicks: number | null
          client_id: string
          created_at: string
          ctr: number | null
          id: string
          impressions: number | null
          period_month: string
          source: Database["public"]["Enums"]["source_system"]
          updated_at: string
          url: string
        }
        Insert: {
          avg_position?: number | null
          clicks?: number | null
          client_id: string
          created_at?: string
          ctr?: number | null
          id?: string
          impressions?: number | null
          period_month: string
          source?: Database["public"]["Enums"]["source_system"]
          updated_at?: string
          url: string
        }
        Update: {
          avg_position?: number | null
          clicks?: number | null
          client_id?: string
          created_at?: string
          ctr?: number | null
          id?: string
          impressions?: number | null
          period_month?: string
          source?: Database["public"]["Enums"]["source_system"]
          updated_at?: string
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "page_performance_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      reports: {
        Row: {
          client_id: string
          completeness_pct: number | null
          created_at: string
          id: string
          pdf_url: string | null
          period_month: string
          published_at: string | null
          status: Database["public"]["Enums"]["workflow_status"]
          updated_at: string
        }
        Insert: {
          client_id: string
          completeness_pct?: number | null
          created_at?: string
          id?: string
          pdf_url?: string | null
          period_month: string
          published_at?: string | null
          status?: Database["public"]["Enums"]["workflow_status"]
          updated_at?: string
        }
        Update: {
          client_id?: string
          completeness_pct?: number | null
          created_at?: string
          id?: string
          pdf_url?: string | null
          period_month?: string
          published_at?: string | null
          status?: Database["public"]["Enums"]["workflow_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reports_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      sheet_mappings: {
        Row: {
          column_map: Json
          created_at: string
          default_tab: Database["public"]["Enums"]["tab"] | null
          id: string
          sheet_registry_id: string
          updated_at: string
          value_map: Json
          version: number
        }
        Insert: {
          column_map?: Json
          created_at?: string
          default_tab?: Database["public"]["Enums"]["tab"] | null
          id?: string
          sheet_registry_id: string
          updated_at?: string
          value_map?: Json
          version?: number
        }
        Update: {
          column_map?: Json
          created_at?: string
          default_tab?: Database["public"]["Enums"]["tab"] | null
          id?: string
          sheet_registry_id?: string
          updated_at?: string
          value_map?: Json
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "sheet_mappings_sheet_registry_id_fkey"
            columns: ["sheet_registry_id"]
            isOneToOne: false
            referencedRelation: "sheet_registry"
            referencedColumns: ["id"]
          },
        ]
      }
      sheet_registry: {
        Row: {
          active: boolean
          client_id: string | null
          created_at: string
          google_sheet_id: string
          id: string
          last_synced_at: string | null
          sheet_type: string
          token_hash: string | null
          updated_at: string
        }
        Insert: {
          active?: boolean
          client_id?: string | null
          created_at?: string
          google_sheet_id: string
          id?: string
          last_synced_at?: string | null
          sheet_type: string
          token_hash?: string | null
          updated_at?: string
        }
        Update: {
          active?: boolean
          client_id?: string | null
          created_at?: string
          google_sheet_id?: string
          id?: string
          last_synced_at?: string | null
          sheet_type?: string
          token_hash?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sheet_registry_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      tracked_keywords: {
        Row: {
          active: boolean
          added_month: string | null
          client_id: string
          created_at: string
          id: string
          is_question: boolean
          keyword: string
          priority: number | null
          tab: Database["public"]["Enums"]["tab"]
          updated_at: string
        }
        Insert: {
          active?: boolean
          added_month?: string | null
          client_id: string
          created_at?: string
          id?: string
          is_question?: boolean
          keyword: string
          priority?: number | null
          tab?: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Update: {
          active?: boolean
          added_month?: string | null
          client_id?: string
          created_at?: string
          id?: string
          is_question?: boolean
          keyword?: string
          priority?: number | null
          tab?: Database["public"]["Enums"]["tab"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tracked_keywords_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      metric_value_conflicts: {
        Row: {
          client_id: string | null
          diff_ratio: number | null
          ingestion_paths:
            | Database["public"]["Enums"]["ingestion_path"][]
            | null
          max_value: number | null
          metric_id: string | null
          min_value: number | null
          period_month: string | null
          segment: string | null
          values_by_path: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "metric_values_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_values_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_values_final: {
        Row: {
          client_id: string | null
          entered_by: string | null
          evidence_link: string | null
          ingested_at: string | null
          ingestion_path: Database["public"]["Enums"]["ingestion_path"] | null
          metric_id: string | null
          period_month: string | null
          segment: string | null
          source: Database["public"]["Enums"]["source_system"] | null
          value: number | null
        }
        Relationships: [
          {
            foreignKeyName: "metric_values_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_values_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_values_trend: {
        Row: {
          client_id: string | null
          entered_by: string | null
          evidence_link: string | null
          ingested_at: string | null
          ingestion_path: Database["public"]["Enums"]["ingestion_path"] | null
          metric_id: string | null
          mom_pct: number | null
          period_month: string | null
          prev_month_value: number | null
          segment: string | null
          source: Database["public"]["Enums"]["source_system"] | null
          value: number | null
          yoy_pct: number | null
          yoy_value: number | null
        }
        Relationships: [
          {
            foreignKeyName: "metric_values_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_values_metric_id_fkey"
            columns: ["metric_id"]
            isOneToOne: false
            referencedRelation: "metric_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      action_item_client: { Args: { p_action_item: string }; Returns: string }
      current_app_role: {
        Args: never
        Returns: Database["public"]["Enums"]["app_role"]
      }
      current_client_id: { Args: never; Returns: string }
      report_published: {
        Args: { p_client: string; p_month: string }
        Returns: boolean
      }
    }
    Enums: {
      access_status: "active" | "pending" | "none"
      action_status:
        | "planned"
        | "in_progress"
        | "done"
        | "partial"
        | "not_done"
        | "dropped"
      aggregation: "sum" | "avg" | "latest" | "p75" | "median"
      app_role: "internal_admin" | "internal_editor" | "client_viewer"
      audience: "internal" | "external"
      client_tier: "full" | "partial" | "external_only"
      execution_status: "done" | "partial" | "not_done"
      ingestion_path: "api" | "manual_sheet" | "input_sheet" | "scheduled_csv"
      metric_type: "input" | "output"
      run_status: "running" | "success" | "partial" | "failed"
      source_system:
        | "gsc"
        | "ga4"
        | "adobe"
        | "dataforseo"
        | "crux"
        | "semrush"
        | "manual_sheet"
        | "input_sheet"
        | "openai"
      tab: "seo" | "aeo" | "geo"
      unit:
        | "count"
        | "percent"
        | "ratio"
        | "position"
        | "ms"
        | "seconds"
        | "currency_inr"
        | "score"
      verdict: "scale" | "continue" | "pivot" | "drop" | "execution_gap"
      workflow_status: "draft" | "in_review" | "approved" | "published"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      access_status: ["active", "pending", "none"],
      action_status: [
        "planned",
        "in_progress",
        "done",
        "partial",
        "not_done",
        "dropped",
      ],
      aggregation: ["sum", "avg", "latest", "p75", "median"],
      app_role: ["internal_admin", "internal_editor", "client_viewer"],
      audience: ["internal", "external"],
      client_tier: ["full", "partial", "external_only"],
      execution_status: ["done", "partial", "not_done"],
      ingestion_path: ["api", "manual_sheet", "input_sheet", "scheduled_csv"],
      metric_type: ["input", "output"],
      run_status: ["running", "success", "partial", "failed"],
      source_system: [
        "gsc",
        "ga4",
        "adobe",
        "dataforseo",
        "crux",
        "semrush",
        "manual_sheet",
        "input_sheet",
        "openai",
      ],
      tab: ["seo", "aeo", "geo"],
      unit: [
        "count",
        "percent",
        "ratio",
        "position",
        "ms",
        "seconds",
        "currency_inr",
        "score",
      ],
      verdict: ["scale", "continue", "pivot", "drop", "execution_gap"],
      workflow_status: ["draft", "in_review", "approved", "published"],
    },
  },
} as const
