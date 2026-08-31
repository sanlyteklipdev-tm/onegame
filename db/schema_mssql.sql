/* ============================================================
   Bilyard programmasy - Microsoft SQL Server shemasy
   PostgreSQL wersiyasynyn (db/schema.sql) gabat gelyan nusgasy.

   Ulanylysy:
     sqlcmd -S localhost -E -C -i db\schema_mssql.sql
   ============================================================ */

IF DB_ID('billiard') IS NULL
    CREATE DATABASE billiard;
GO

USE billiard;
GO

/* ---- Otaglar / Stollar -------------------------------------
   PostgreSQL      -> SQL Server
   BIGSERIAL       -> BIGINT IDENTITY(1,1)
   TEXT            -> NVARCHAR (N - turkmen harplary uchin hokman)
   NUMERIC         -> DECIMAL
   TIMESTAMPTZ     -> DATETIMEOFFSET
   now()           -> SYSDATETIMEOFFSET()
-------------------------------------------------------------- */
IF OBJECT_ID('dbo.game_tables', 'U') IS NULL
CREATE TABLE dbo.game_tables (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    name           NVARCHAR(200)  NOT NULL,
    price_per_hour DECIMAL(10, 2) NOT NULL CHECK (price_per_hour >= 0),
    max_users      INT            NULL CHECK (max_users IS NULL OR max_users > 0),
    status         NVARCHAR(20)   NOT NULL DEFAULT 'available'
                                  CHECK (status IN ('available', 'active')),
    created_at     DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT uq_game_tables_name UNIQUE (name)
);
GO

/* ---- Musderiler -------------------------------------------- */
IF OBJECT_ID('dbo.customers', 'U') IS NULL
CREATE TABLE dbo.customers (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    name                NVARCHAR(200)  NOT NULL UNIQUE,
    discount_percentage DECIMAL(5, 2)  NOT NULL DEFAULT 0
                                       CHECK (discount_percentage BETWEEN 0 AND 100),
    phone               NVARCHAR(40)   NULL,
    created_at          DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO

/* ---- Isgarler ---------------------------------------------- */
IF OBJECT_ID('dbo.employees', 'U') IS NULL
CREATE TABLE dbo.employees (
    id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    name       NVARCHAR(200)  NOT NULL UNIQUE,
    phone      NVARCHAR(40)   NULL,
    category   NCHAR(1)       NOT NULL DEFAULT 'A'
                              CHECK (category IN ('A', 'B', 'C')),
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO

/* ---- Oyuncy sessiyalary ------------------------------------ */
IF OBJECT_ID('dbo.player_sessions', 'U') IS NULL
CREATE TABLE dbo.player_sessions (
    id                   BIGINT IDENTITY(1,1) PRIMARY KEY,
    table_id             BIGINT         NOT NULL
                                        REFERENCES dbo.game_tables (id) ON DELETE CASCADE,
    player_name          NVARCHAR(200)  NOT NULL,
    session_code         NVARCHAR(40)   NOT NULL UNIQUE,
    start_time           DATETIMEOFFSET NOT NULL,
    end_time             DATETIMEOFFSET NULL,
    status               NVARCHAR(20)   NOT NULL
                                        CHECK (status IN ('active', 'finished')),
    accumulated_cost     DECIMAL(12, 2) NOT NULL DEFAULT 0,
    last_checkpoint_time DATETIMEOFFSET NOT NULL,
    total_price          DECIMAL(12, 2) NOT NULL DEFAULT 0,
    customer_id          BIGINT         NULL
                                        REFERENCES dbo.customers (id) ON DELETE SET NULL,
    discount_percentage  DECIMAL(5, 2)  NOT NULL DEFAULT 0,
    reminder_minutes     INT            NULL,
    CONSTRAINT ck_sessions_time CHECK (end_time IS NULL OR end_time >= start_time)
);
GO

CREATE INDEX ix_sessions_table_status ON dbo.player_sessions (table_id, status);
CREATE INDEX ix_sessions_start_time   ON dbo.player_sessions (start_time);
GO

/* ---- Taryh yazgylary ---------------------------------------
   Stol pozulanda taryh saklanmaly, sonun uchin FK yok.
-------------------------------------------------------------- */
IF OBJECT_ID('dbo.history_logs', 'U') IS NULL
CREATE TABLE dbo.history_logs (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    table_id            BIGINT         NOT NULL,
    table_name          NVARCHAR(200)  NOT NULL,
    session_id          BIGINT         NOT NULL,
    session_code        NVARCHAR(40)   NOT NULL,
    player_name         NVARCHAR(200)  NOT NULL,
    start_time          DATETIMEOFFSET NOT NULL,
    end_time            DATETIMEOFFSET NOT NULL,
    total_price         DECIMAL(12, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2)  NULL,
    discount_amount     DECIMAL(12, 2) NULL,
    created_at          DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO

CREATE INDEX ix_history_table_id   ON dbo.history_logs (table_id);
CREATE INDEX ix_history_start_time ON dbo.history_logs (start_time);
CREATE INDEX ix_history_created_at ON dbo.history_logs (created_at);
GO

/* ---- Bronlar ----------------------------------------------- */
IF OBJECT_ID('dbo.reservations', 'U') IS NULL
CREATE TABLE dbo.reservations (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    table_id    BIGINT         NOT NULL
                               REFERENCES dbo.game_tables (id) ON DELETE CASCADE,
    title       NVARCHAR(200)  NOT NULL,
    customer_id BIGINT         NULL REFERENCES dbo.customers (id),
    employee_id BIGINT         NULL REFERENCES dbo.employees (id),
    start_time  DATETIMEOFFSET NOT NULL,
    end_time    DATETIMEOFFSET NOT NULL,
    status      NVARCHAR(20)   NOT NULL DEFAULT 'pending'
                               CHECK (status IN ('pending', 'started')),
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT ck_reservations_time CHECK (end_time > start_time)
);
GO

CREATE INDEX ix_reservations_start_time ON dbo.reservations (start_time);
CREATE INDEX ix_reservations_table_id   ON dbo.reservations (table_id);
GO

/* ---- Bronlaryn gabat gelmegi gadagan -----------------------
   PostgreSQL-de bu EXCLUDE USING gist bilen edilyar.
   SQL Server-de beyle chaklendirme yok - trigger bilen edilyar.
-------------------------------------------------------------- */
IF OBJECT_ID('dbo.trg_reservations_no_overlap', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_reservations_no_overlap;
GO

CREATE TRIGGER dbo.trg_reservations_no_overlap
ON dbo.reservations
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.reservations AS r
          ON  r.table_id   = i.table_id
          AND r.id        <> i.id
          AND r.start_time <  i.end_time
          AND r.end_time   >  i.start_time
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Otag sol wagt aralygynda eyyam bronlanan.', 1;
    END
END
GO
