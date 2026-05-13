-- DBATDP-1 / AC3: Runnable regression checks for sócio consult (NF/EX) and inclusion.
-- Execute in UAT after applying DB2/socios-ddl.sql and loading COBOL programs.
-- Adjust schema qualifier if your environment uses one.

-- Fixture RG examples (must not collide with production data in UAT).
-- 999000001 = use for "existing" lookup tests after seeding.
-- 999000099 = use for "absent" lookup tests when not inserted.
SELECT COUNT(*) AS CNT_EXIST
FROM SOCIO
WHERE NUMB_SOCIO_PRINCIPAL = 999000001;

-- AC3 / lookup: no record (NF path) — expect 0 rows for a disposable RG
SELECT COUNT(*) AS CNT_ABSENT
FROM SOCIO
WHERE NUMB_SOCIO_PRINCIPAL = 999000099;

-- AC3 / inclusion sanity: parent + 12 child rows after successful insert
-- (Run only when driven by STFSCC00I or equivalent; then assert counts.)
SELECT S.NUMB_SOCIO_PRINCIPAL,
       (SELECT COUNT(*)
          FROM SOCIO_PAGAMENTO P
         WHERE P.NUMB_SOCIO_PRINCIPAL = S.NUMB_SOCIO_PRINCIPAL) AS PAG_ROWS
FROM SOCIO S
WHERE S.NUMB_SOCIO_PRINCIPAL = 999000001;

-- Expected after full insert: PAG_ROWS = 12 for each new sócio.
