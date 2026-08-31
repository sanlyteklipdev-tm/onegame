-- ════════════════════════════════════════════════════════════
--  003 — hyzmatlar (services) we bronda hyzmat saýlamak
--
--  Ulanylyşy:
--    psql -U postgres -d billiard -f db/migrations/003_services.sql
-- ════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS services (
    id          BIGSERIAL PRIMARY KEY,
    name        TEXT           NOT NULL,
    price       NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT now(),
    device_name TEXT
);

-- Isar-daky @Index(unique: true, caseSensitive: false) ekwiwalenti
CREATE UNIQUE INDEX IF NOT EXISTS services_name_lower_key
    ON services (lower(name));

-- Bronda hyzmat. Köne bronlarda boş — şonuň üçin NULL kabul edýär.
-- Hyzmat pozulsa bron ýitmeli däl, diňe salgylanma boşaýar.
ALTER TABLE reservations
    ADD COLUMN IF NOT EXISTS service_id BIGINT
    REFERENCES services (id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS reservations_service_id_idx
    ON reservations (service_id);
