-- ════════════════════════════════════════════════════════════
--  004 — işgäriň görnüşi (1-nji / 2-nji)
--
--  Bronda diňe 2-nji görnüşdäki işgärler saýlanyp bilinýär.
--  Direktor bolsa görnüşine garamazdan bronda görkezilmeýär —
--  ol barlag programmada (ReservationEmployeePicker) edilýär.
--
--  Ulanylyşy:
--    psql -U postgres -d billiard -f db/migrations/004_employee_type.sql
-- ════════════════════════════════════════════════════════════

-- Bar bolan işgärlere 'type1' berilýär — olar bronda görünmez.
-- Gerekli işgärleri programmadan 2-nji görnüşe geçirmeli.
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS employee_type TEXT NOT NULL DEFAULT 'type1'
    CHECK (employee_type IN ('type1', 'type2'));

-- Bronda işgär saýlananda görnüş boýunça süzgüç işleýär
CREATE INDEX IF NOT EXISTS employees_type_idx
    ON employees (employee_type);
