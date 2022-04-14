/* VIEWS */

CREATE OR REPLACE FORCE VIEW AIR_RIGHT
(
   BBL,
   BORO,
   BLOCK,
   AIR_LOT,
   EFFECTIVE_TAX_YEAR
)
AS
   SELECT e.bbl,
          e.boro,
          e.block,
          o.air_rights_lot_number,
          o.effective_tax_year
     FROM every_bbl_mv e, air_rights_lots o
    WHERE e.map_bbl = o.donating_bbl
   UNION
   SELECT donating_bbl bbl,
          donating_boro boro,
          donating_block block,
          air_rights_lot_number,
          effective_tax_year
     FROM air_rights_lots;

CREATE OR REPLACE FORCE VIEW AIR_RIGHT_LOOKUP
(
   BBL,
   AIR_KEY,
   AIR_RIGHTS_LOT_NUMBER
)
AS
   SELECT DONATING_BBL,
             donating_boro
          || LPAD (donating_block, 5, 0)
          || LPAD (air_rights_lot_number, 4, 0)
             AIR_KEY,
          air_rights_lot_number
     FROM air_rights_lots
    WHERE donating_BBL != '0000000000';

CREATE OR REPLACE FORCE VIEW CONDO_UNIT
(
   BBL,
   BORO,
   BLOCK,
   UNIT_LOT,
   CONDO_NUMBER,
   UNIT_DESIGNATION,
   EFFECTIVE_TAX_YEAR
)
AS
   SELECT e.bbl,
          e.boro,
          e.block,
          o.unit_lot,
          o.condo_number,
          o.unit_designation,
          o.effective_tax_year
     FROM every_bbl_mv e, condo_units o
    WHERE e.map_bbl = o.condo_base_bbl
   UNION
   SELECT condo_base_bbl bbl,
          condo_base_boro boro,
          condo_base_block block,
          unit_lot,
          condo_number,
          unit_designation,
          effective_tax_year
     FROM condo_units;

CREATE OR REPLACE FORCE VIEW CONDOMINIUM
(
   BBL,
   CONDO_KEY,
   CONDO_NUMBER,
   CONDO_NAME,
   BILLING_LOT
)
AS
   SELECT "CONDO_BILLING_BBL",
          "CONDO_KEY",
          "CONDO_NUMBER",
          "CONDO_NAME",
          "BILLING_LOT"
     FROM (SELECT condo_billing_bbl,
                  condo_key,
                  condo_number,
                  condo_name,
                  SUBSTR (condo_billing_bbl, 7) billing_lot
             FROM condo
           UNION
           SELECT condo_base_bbl,
                  condo_key,
                  condo_number,
                  condo_name,
                  SUBSTR (condo_billing_bbl, 7) billing_lot
             FROM condo)
    WHERE CONDO_BILLING_BBL != '0000000000';

CREATE OR REPLACE FORCE VIEW SUBTERRANEAN
(
   BBL,
   BORO,
   BLOCK,
   SUBTERRANEAN_LOT,
   EFFECTIVE_TAX_YEAR
)
AS
   SELECT e.bbl,
          e.boro,
          e.block,
          o.SUBTERRANEAN_LOT_number,
          o.effective_tax_year
     FROM every_bbl_mv e, SUBTERRANEAN_LOTS o
    WHERE e.map_bbl = o.APPURTENANT_BBL
   UNION
   SELECT APPURTENANT_bbl bbl,
          APPURTENANT_boro boro,
          APPURTENANT_block block,
          SUBTERRANEAN_LOT_number,
          effective_tax_year
     FROM SUBTERRANEAN_LOTS;

CREATE OR REPLACE FORCE VIEW SUBTERRANEAN_LOOKUP
(
   BBL,
   SUB_KEY,
   SUBTERRANEAN_LOT_NUMBER
)
AS
   SELECT appurtenant_BBL,
             appurtenant_boro
          || LPAD (appurtenant_block, 5, 0)
          || LPAD (subterranean_lot_number, 4, 0)
             SUB_KEY,
          subterranean_lot_number
     FROM subterranean_lots
    WHERE appurtenant_BBL != '0000000000';

CREATE OR REPLACE FORCE VIEW V_BORO_BLOCK_CHANGES
(
   BORO_BLOCK,
   CHANGE_DATE,
   SHAPE
)
AS
   (SELECT u.boro_block, u.change_date, tb.shape
      FROM (SELECT DISTINCT
                   SUBSTR (a.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_air_rights a, dab_wizard_transaction w
             WHERE a.trans_num = w.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (t.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_boundary_line b,
                   dab_wizard_transaction w,
                   dab_tax_lots t
             WHERE b.trans_num = w.trans_num AND b.trans_num = t.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (c.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_condo_conversion c, dab_wizard_transaction w
             WHERE c.trans_num = w.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (c.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_condo_units c, dab_wizard_transaction w
             WHERE c.trans_num = w.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (r.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_reuc r, dab_wizard_transaction w
             WHERE r.trans_num = w.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (s.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_subterranean_rights s, dab_wizard_transaction w
             WHERE s.trans_num = w.trans_num
            UNION
            SELECT DISTINCT
                   SUBSTR (t.bbl, 0, 6) AS boro_block,
                   w.change_date AS change_date
              FROM dab_tax_lots t, dab_wizard_transaction w
             WHERE t.trans_num = w.trans_num) u,
           tax_block tb
     WHERE u.boro_block = tb.boro_block(+));

INSERT INTO USER_SDO_GEOM_METADATA SELECT 'V_BORO_BLOCK_CHANGES', 'SHAPE', DIMINFO, SRID FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'BOROUGH_POINT';

CREATE OR REPLACE FORCE VIEW V_CONDO_RANGE
(
   SHAPE,
   MIN,
   MAX,
   RANGE_LABEL
)
AS
   SELECT t.shape,
          u.MIN,
          u.MAX,
          TRIM (u.MIN) || ' - ' || TRIM (u.MAX) range_label
     FROM tax_lot_point t,
          (  SELECT condo_base_bbl bbl,
                    MIN (TRIM (unit_lot)) MIN,
                    MAX (TRIM (unit_lot)) MAX
               FROM condo_units
           GROUP BY condo_base_bbl) u
    WHERE t.bbl = u.bbl;

INSERT INTO USER_SDO_GEOM_METADATA SELECT 'V_CONDO_RANGE', 'SHAPE', DIMINFO, SRID FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'BOROUGH_POINT';
    
CREATE OR REPLACE FORCE VIEW V_LOT_FACE_SMALL
(
   SHAPE,
   BBL,
   TITLE,
   LENGTH,
   LENGTH_LABEL
)
AS
   SELECT shape,
          bbl,
          DECODE (boro,
                  '1', 'MANHATTAN ',
                  '2', 'BRONX ',
                  '3', 'BROOKLYN ',
                  '4', 'QUEENS ',
                  '5', 'STATEN ISLAND ')
          || 'Block: '
          || block
          || ' Lot: '
          || lot,
          LENGTH,
          TRIM (
             DECODE (approx_length_flag, 1, '+/-', '')
             || DECODE (
                   LENGTH (TO_CHAR (LENGTH)) || '.' || INSTR (LENGTH, '.'),
                   '1.0', TO_CHAR (LENGTH),
                   '4.2', TO_CHAR (LENGTH, '9.99'),
                   '2.1', TO_CHAR (LENGTH, '0.9'),
                   '3.1', TO_CHAR (LENGTH, '0.99'),
                   '3.2', TO_CHAR (LENGTH, '0.9')))
          || ' ft'
     FROM LOT_FACE_POINT
    WHERE LENGTH < 5 AND LENGTH > 0;

INSERT INTO USER_SDO_GEOM_METADATA SELECT 'V_LOT_FACE_SMALL', 'SHAPE', DIMINFO, SRID FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'BOROUGH_POINT';

CREATE OR REPLACE FORCE VIEW V_TAX_LOT_POINT
(
   SHAPE,
   BBL,
   LOT,
   CONDO_FLAG,
   ALL_FLAGS,
   OTHER_LABEL,
   LABEL_COUNT,
   AREA
)
AS
   SELECT shape,
          l.bbl,
          l.lot,
          l.condo_flag,
             NVL (l.air_rights_flag, '')
          || NVL (l.condo_flag, '')
          || NVL (l.reuc_flag, '')
          || NVL (l.subterranean_flag, ''),
          TRIM (
             CHR (13) FROM TRIM (
                              CHR (10) FROM TRIM (
                                               CHR (13) FROM REPLACE (
                                                                REPLACE (
                                                                   TRIM (
                                                                      NVL (
                                                                         l.reuc_flag,
                                                                         ' '))
                                                                   || '      '
                                                                   || CHR (
                                                                         13)
                                                                   || CHR (
                                                                         10)
                                                                   || a.label
                                                                   || CHR (
                                                                         13)
                                                                   || CHR (
                                                                         10)
                                                                   || c.label
                                                                   || CHR (
                                                                         13)
                                                                   || CHR (
                                                                         10)
                                                                   || s.label,
                                                                   CHR (13)
                                                                   || CHR (
                                                                         10)
                                                                   || CHR (
                                                                         13)
                                                                   || CHR (
                                                                         10),
                                                                   CHR (13)
                                                                   || CHR (
                                                                         10)),
                                                                   CHR (13)
                                                                || CHR (10)
                                                                || CHR (13)
                                                                || CHR (10),
                                                                CHR (13)
                                                                || CHR (10))))),
            NVL (a.COUNT, 0)
          + NVL (c.COUNT, 0)
          + NVL (s.COUNT, 0)
          + NVL (LENGTH (l.reuc_flag), 0),
          l.LOT_AREA
     FROM tax_lot_point l,
          condo_label c,
          air_label a,
          sub_label s
    WHERE l.bbl = a.bbl(+) AND l.bbl = c.bbl(+) AND l.bbl = s.bbl(+);

INSERT INTO USER_SDO_GEOM_METADATA SELECT 'V_TAX_LOT_POINT', 'SHAPE', DIMINFO, SRID FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'BOROUGH_POINT';
