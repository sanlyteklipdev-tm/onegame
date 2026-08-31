-- ════════════════════════════════════════════════════════════
--  001 — ýazgynyň haýsy enjamdan goşulandygyny bellemek
--
--  Sütün NULL kabul edýär: öň bar bolan ýazgylarda enjam belli däl,
--  olar boş galýar we degilmeýär.
--
--  Ulanylyşy:
--    psql -U postgres -d billiard -f db/migrations/001_device_name.sql
-- ════════════════════════════════════════════════════════════

ALTER TABLE game_tables     ADD COLUMN IF NOT EXISTS device_name TEXT;
ALTER TABLE customers       ADD COLUMN IF NOT EXISTS device_name TEXT;
ALTER TABLE employees       ADD COLUMN IF NOT EXISTS device_name TEXT;
ALTER TABLE player_sessions ADD COLUMN IF NOT EXISTS device_name TEXT;
ALTER TABLE history_logs    ADD COLUMN IF NOT EXISTS device_name TEXT;
ALTER TABLE reservations    ADD COLUMN IF NOT EXISTS device_name TEXT;

-- Enjam boýunça süzgüç üçin
CREATE INDEX IF NOT EXISTS game_tables_device_idx     ON game_tables (device_name);
CREATE INDEX IF NOT EXISTS customers_device_idx       ON customers (device_name);
CREATE INDEX IF NOT EXISTS employees_device_idx       ON employees (device_name);
CREATE INDEX IF NOT EXISTS player_sessions_device_idx ON player_sessions (device_name);
CREATE INDEX IF NOT EXISTS history_logs_device_idx    ON history_logs (device_name);
CREATE INDEX IF NOT EXISTS reservations_device_idx    ON reservations (device_name);
