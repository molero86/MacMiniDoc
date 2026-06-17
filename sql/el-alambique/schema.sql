CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS el_alambique;

SET search_path TO el_alambique, public;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    base_url TEXT NOT NULL,
    rss_url TEXT,
    collection_mode TEXT NOT NULL CHECK (collection_mode IN ('rss', 'scraping', 'rss_or_scraping')),
    region TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_checked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pipeline_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scheduled_at TIMESTAMPTZ NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    scope TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('running', 'completed', 'partial_failure', 'failed')),
    sources_checked INTEGER NOT NULL DEFAULT 0 CHECK (sources_checked >= 0),
    articles_found INTEGER NOT NULL DEFAULT 0 CHECK (articles_found >= 0),
    story_clusters_detected INTEGER NOT NULL DEFAULT 0 CHECK (story_clusters_detected >= 0),
    articles_published INTEGER NOT NULL DEFAULT 0 CHECK (articles_published >= 0),
    articles_failed INTEGER NOT NULL DEFAULT 0 CHECK (articles_failed >= 0),
    error_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE raw_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipeline_run_id UUID NOT NULL REFERENCES pipeline_runs(id) ON DELETE CASCADE,
    source_id UUID NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    original_url TEXT NOT NULL UNIQUE,
    url_hash TEXT NOT NULL,
    original_title TEXT NOT NULL,
    raw_excerpt TEXT,
    raw_body TEXT NOT NULL,
    author_name TEXT,
    published_at TIMESTAMPTZ,
    collected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    language TEXT NOT NULL DEFAULT 'es',
    extraction_status TEXT NOT NULL CHECK (extraction_status IN ('collected', 'incomplete', 'failed'))
);

CREATE TABLE article_fingerprints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    raw_article_id UUID NOT NULL UNIQUE REFERENCES raw_articles(id) ON DELETE CASCADE,
    url_hash TEXT NOT NULL,
    normalized_title TEXT NOT NULL,
    title_hash TEXT NOT NULL,
    similarity_group TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE story_clusters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipeline_run_id UUID NOT NULL REFERENCES pipeline_runs(id) ON DELETE CASCADE,
    topic_hint TEXT NOT NULL,
    cluster_status TEXT NOT NULL CHECK (cluster_status IN ('new', 'update', 'duplicate', 'review', 'published')),
    canonical_region TEXT,
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE dedup_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipeline_run_id UUID NOT NULL REFERENCES pipeline_runs(id) ON DELETE CASCADE,
    raw_article_id UUID NOT NULL REFERENCES raw_articles(id) ON DELETE CASCADE,
    matched_cluster_id UUID REFERENCES story_clusters(id) ON DELETE SET NULL,
    decision TEXT NOT NULL CHECK (decision IN ('new', 'duplicate', 'update', 'review')),
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE story_cluster_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cluster_id UUID NOT NULL REFERENCES story_clusters(id) ON DELETE CASCADE,
    raw_article_id UUID NOT NULL REFERENCES raw_articles(id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    relevance_score NUMERIC(4,3) CHECK (relevance_score IS NULL OR (relevance_score >= 0 AND relevance_score <= 1)),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (cluster_id, raw_article_id)
);

CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cluster_id UUID NOT NULL UNIQUE REFERENCES story_clusters(id) ON DELETE CASCADE,
    section TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    clean_title TEXT NOT NULL,
    clean_body TEXT NOT NULL,
    short_summary TEXT NOT NULL,
    editor_notes TEXT,
    source_count INTEGER NOT NULL CHECK (source_count >= 1),
    primary_source_url TEXT,
    publication_status TEXT NOT NULL CHECK (publication_status IN ('draft', 'ready_to_publish', 'published', 'rejected')),
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE article_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    raw_article_id UUID NOT NULL REFERENCES raw_articles(id) ON DELETE RESTRICT,
    source_id UUID NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    source_name_snapshot TEXT NOT NULL,
    source_url_snapshot TEXT NOT NULL,
    used_for TEXT NOT NULL CHECK (used_for IN ('primary', 'supporting', 'context')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (article_id, raw_article_id)
);

CREATE TABLE article_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    tag TEXT NOT NULL,
    confidence NUMERIC(4,3) CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
    UNIQUE (article_id, tag)
);

CREATE TABLE publication_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('created', 'updated', 'published', 'rejected')),
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE agent_failures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipeline_run_id UUID NOT NULL REFERENCES pipeline_runs(id) ON DELETE CASCADE,
    raw_article_id UUID REFERENCES raw_articles(id) ON DELETE SET NULL,
    article_id UUID REFERENCES articles(id) ON DELETE SET NULL,
    agent_name TEXT NOT NULL CHECK (agent_name IN ('redactor_jefe', 'corresponsal', 'documentalista', 'redactor', 'jefe_de_seccion', 'maquetador')),
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    retryable BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_raw_articles_source_published
    ON raw_articles (source_id, published_at DESC);

CREATE INDEX idx_raw_articles_pipeline_run
    ON raw_articles (pipeline_run_id);

CREATE INDEX idx_story_clusters_status_last_seen
    ON story_clusters (cluster_status, last_seen_at DESC);

CREATE INDEX idx_story_clusters_region_last_seen
    ON story_clusters (canonical_region, last_seen_at DESC);

CREATE INDEX idx_dedup_events_raw_article
    ON dedup_events (raw_article_id);

CREATE INDEX idx_dedup_events_matched_cluster
    ON dedup_events (matched_cluster_id);

CREATE INDEX idx_articles_section_published
    ON articles (section, published_at DESC);

CREATE INDEX idx_articles_publication_status_published
    ON articles (publication_status, published_at DESC);

CREATE INDEX idx_article_sources_article
    ON article_sources (article_id);

CREATE INDEX idx_article_sources_source
    ON article_sources (source_id);

CREATE INDEX idx_publication_events_article_created
    ON publication_events (article_id, created_at DESC);

CREATE INDEX idx_agent_failures_pipeline_run
    ON agent_failures (pipeline_run_id);

CREATE TRIGGER trg_sources_updated_at
BEFORE UPDATE ON sources
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_story_clusters_updated_at
BEFORE UPDATE ON story_clusters
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_articles_updated_at
BEFORE UPDATE ON articles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();