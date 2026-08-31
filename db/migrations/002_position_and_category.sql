-- ════════════════════════════════════════════════════════════
--  002 — işgärlerde kategoriýa ýerine wezipe,
--        müşderilerde kategoriýa (A/B/C)
--
--  ÜNS: bar bolan işgärler pozulýar — kategoriýany wezipä
--  öwrüp bolmaýar, olar dürli zatlar.
--
--  Ulanylyşy:
--    psql -U postgres -d billiard -f db/migrations/002_position_and_category.sql
-- ════════════════════════════════════════════════════════════

-- Bronlarda işgäre salgylanma bar — öň ony boşatmaly
UPDATE reservations SET employee_id = NULL;
DELETE FROM employees;

ALTER TABLE employees DROP COLUMN IF EXISTS category;

-- `position` SQL-de aýratyn manyly söz, şonuň üçin `job_position`
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS job_position TEXT NOT NULL DEFAULT 'manager';

ALTER TABLE employees DROP CONSTRAINT IF EXISTS employees_job_position_check;
ALTER TABLE employees
    ADD CONSTRAINT employees_job_position_check
    CHECK (job_position IN ('manager', 'cashier', 'operator', 'director'));

-- Müşderilere kategoriýa
ALTER TABLE customers
    ADD COLUMN IF NOT EXISTS category CHAR(1) NOT NULL DEFAULT 'A';

ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_category_check;
ALTER TABLE customers
    ADD CONSTRAINT customers_category_check
    CHECK (category IN ('A', 'B', 'C'));
