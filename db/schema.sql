-- ════════════════════════════════════════════════════════════
--  Bilýard programmasy — PostgreSQL shemasy
--  lib/data/models/ içindäki Isar modellerine laýyk gelýär.
--  Ulanylyşy:
--    psql -U postgres -d billiard -f db/schema.sql
-- ════════════════════════════════════════════════════════════

-- Bronlaryň wagt aralygyny gabatlaşdyrmazlyk üçin gerek
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ── Stollar (TableModel) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_tables (
    id              BIGSERIAL PRIMARY KEY,
    name            TEXT           NOT NULL,
    price_per_hour  NUMERIC(10, 2) NOT NULL CHECK (price_per_hour >= 0),
    max_users       INTEGER        CHECK (max_users IS NULL OR max_users > 0),
    status          TEXT           NOT NULL DEFAULT 'available'
                                   CHECK (status IN ('available', 'active')),
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT now()
);

-- Isar-daky @Index(unique: true, caseSensitive: false) ekwiwalenti
CREATE UNIQUE INDEX IF NOT EXISTS game_tables_name_lower_key
    ON game_tables (lower(name));

-- ── Müşderiler (CustomerModel) ──────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    id                  BIGSERIAL PRIMARY KEY,
    name                TEXT          NOT NULL UNIQUE,
    discount_percentage NUMERIC(5, 2) NOT NULL DEFAULT 0
                                      CHECK (discount_percentage BETWEEN 0 AND 100),
    phone               TEXT,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ── Işgärler (EmployeeModel) ────────────────────────────────
CREATE TABLE IF NOT EXISTS employees (
    id          BIGSERIAL PRIMARY KEY,
    name        TEXT        NOT NULL UNIQUE,
    phone       TEXT,
    category    CHAR(1)     NOT NULL DEFAULT 'A'
                            CHECK (category IN ('A', 'B', 'C')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Oýunçy sessiýalary (PlayerSessionModel) ─────────────────
CREATE TABLE IF NOT EXISTS player_sessions (
    id                   BIGSERIAL PRIMARY KEY,
    table_id             BIGINT         NOT NULL
                                        REFERENCES game_tables (id) ON DELETE CASCADE,
    player_name          TEXT           NOT NULL,
    session_code         TEXT           NOT NULL UNIQUE,
    start_time           TIMESTAMPTZ    NOT NULL,
    end_time             TIMESTAMPTZ,
    status               TEXT           NOT NULL
                                        CHECK (status IN ('active', 'finished')),
    -- Dinamiki bahalandyrma ýagdaýy
    accumulated_cost     NUMERIC(12, 2) NOT NULL DEFAULT 0,
    last_checkpoint_time TIMESTAMPTZ    NOT NULL,
    total_price          NUMERIC(12, 2) NOT NULL DEFAULT 0,
    customer_id          BIGINT         REFERENCES customers (id) ON DELETE SET NULL,
    discount_percentage  NUMERIC(5, 2)  NOT NULL DEFAULT 0,
    reminder_minutes     INTEGER,
    CHECK (end_time IS NULL OR end_time >= start_time)
);

CREATE INDEX IF NOT EXISTS player_sessions_table_status_idx
    ON player_sessions (table_id, status);
CREATE INDEX IF NOT EXISTS player_sessions_start_time_idx
    ON player_sessions (start_time);

-- ── Taryh ýazgylary (HistoryLogModel) ───────────────────────
-- Stol pozulanda taryh saklanmaly, şonuň üçin table_id-de FK ýok
-- we stolun ady aýratyn ýazylýar.
CREATE TABLE IF NOT EXISTS history_logs (
    id                  BIGSERIAL PRIMARY KEY,
    table_id            BIGINT         NOT NULL,
    table_name          TEXT           NOT NULL,
    session_id          BIGINT         NOT NULL,
    session_code        TEXT           NOT NULL,
    player_name         TEXT           NOT NULL,
    start_time          TIMESTAMPTZ    NOT NULL,
    end_time            TIMESTAMPTZ    NOT NULL,
    total_price         NUMERIC(12, 2) NOT NULL,
    discount_percentage NUMERIC(5, 2),
    discount_amount     NUMERIC(12, 2),
    created_at          TIMESTAMPTZ    NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS history_logs_table_id_idx  ON history_logs (table_id);
CREATE INDEX IF NOT EXISTS history_logs_start_time_idx ON history_logs (start_time);
CREATE INDEX IF NOT EXISTS history_logs_created_at_idx ON history_logs (created_at);

-- ── Bronlar (ReservationModel) ──────────────────────────────
CREATE TABLE IF NOT EXISTS reservations (
    id          BIGSERIAL PRIMARY KEY,
    table_id    BIGINT      NOT NULL
                            REFERENCES game_tables (id) ON DELETE CASCADE,
    title       TEXT        NOT NULL,
    customer_id BIGINT      REFERENCES customers (id) ON DELETE SET NULL,
    employee_id BIGINT      REFERENCES employees (id) ON DELETE SET NULL,
    start_time  TIMESTAMPTZ NOT NULL,
    end_time    TIMESTAMPTZ NOT NULL,
    status      TEXT        NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'started')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (end_time > start_time),
    -- Bir stolda bronlar wagt boýunça gabat gelip bilmez.
    -- Programmadaky barlagyň bazadaky kepili.
    CONSTRAINT reservations_no_overlap EXCLUDE USING gist (
        table_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    )
);

CREATE INDEX IF NOT EXISTS reservations_start_time_idx ON reservations (start_time);
CREATE INDEX IF NOT EXISTS reservations_table_id_idx   ON reservations (table_id);

-- ── Programma ulanyjysyna hukuklar ──────────────────────────
GRANT USAGE ON SCHEMA public TO billiard_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO billiard_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO billiard_app;

-- Soň goşulýan tablisalar üçin hem awtomatiki hukuk
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO billiard_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO billiard_app;
