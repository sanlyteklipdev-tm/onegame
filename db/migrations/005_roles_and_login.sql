-- ════════════════════════════════════════════════════════════
--  005 — hakyky ulanyjylar we hukuklar
--
--  Her adamyň Postgres-de öz hasaby bolýar. Programma şol
--  hasap bilen birigýär, hukuklary bazanyň özi barlaýar —
--  şonuň üçin APK-nyň içinde parol saklanmaýar.
--
--  Üç topar rol:
--    sanly_worker   — diňe öz bronlary, stol başlatmak
--    sanly_manager  — kassanyň hemme işi + hasabatlar
--    sanly_admin    — hemmesi + işgärler we ulanyjylar
--
--  Işgär hasabatlary görüp bilmez: history_logs-a hukugy ýok,
--  bu programmadaky däl-de bazadaky gadaganlyk.
--
--  Ulanylyşy (administrator paroly bilen):
--    psql -U postgres -d billiard -f db/migrations/005_roles_and_login.sql
-- ════════════════════════════════════════════════════════════

-- ── 1. Topar rollar ─────────────────────────────────────────
-- Rollar tutuş klasterde bir gezek döredilýär
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sanly_worker') THEN
        CREATE ROLE sanly_worker NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sanly_manager') THEN
        CREATE ROLE sanly_manager NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sanly_admin') THEN
        CREATE ROLE sanly_admin NOLOGIN;
    END IF;
END $$;

-- ── 2. Işgär ↔ baza hasaby baglanyşygy ──────────────────────
-- Programma "men kim?" diýip şu ýerden tapýar:
--   SELECT id FROM employees WHERE lower(db_user) = lower(current_user)
ALTER TABLE employees ADD COLUMN IF NOT EXISTS db_user TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS employees_db_user_key
    ON employees (lower(db_user));

-- ── 3. Bron ýagdaýyna 'done' goşulýar ───────────────────────
-- Işgär bronу "ýerine ýetirildi" diýip belläp bilýär
ALTER TABLE reservations DROP CONSTRAINT IF EXISTS reservations_status_check;
ALTER TABLE reservations ADD CONSTRAINT reservations_status_check
    CHECK (status IN ('pending', 'started', 'done'));

-- ── 4. Shema hukugy ─────────────────────────────────────────
GRANT USAGE ON SCHEMA public TO sanly_worker, sanly_manager, sanly_admin;

-- ── 5. Işgär (sanly_worker) ─────────────────────────────────
-- Bronuň jikme-jigini görkezmek üçin okamaly maglumatlar
GRANT SELECT ON game_tables, customers, services, employees, reservations
    TO sanly_worker;

-- Diňe ýagdaýy üýtgedip bilýär — wagtyny ýa müşderisini däl
GRANT UPDATE (status) ON reservations TO sanly_worker;

-- Stol başlatmak: sessiýa açylýar we stol "işleýär" bolýar
GRANT SELECT, INSERT, UPDATE ON player_sessions TO sanly_worker;
GRANT USAGE ON SEQUENCE player_sessions_id_seq TO sanly_worker;
GRANT UPDATE (status) ON game_tables TO sanly_worker;

-- history_logs GRANT ÝOK — hasabatlar we girdeji ýapyk

-- ── 6. Menejer (sanly_manager) ──────────────────────────────
-- Kassanyň ähli işi: stollar, müşderiler, hyzmatlar, bronlar,
-- sessiýalar we hasabatlar
GRANT SELECT, INSERT, UPDATE, DELETE
    ON game_tables, customers, services, reservations,
       player_sessions, history_logs
    TO sanly_manager;

-- Işgärleri diňe görüp bilýär, üýtgedip bilmeýär
GRANT SELECT ON employees TO sanly_manager;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO sanly_manager;

-- ── 7. Administrator (sanly_admin) ──────────────────────────
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sanly_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sanly_admin;

-- ── 8. Soň dörediljek tablisalar üçin hem şol hukuklar ──────
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON TABLES TO sanly_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON SEQUENCES TO sanly_admin;
