/* MATERIALIZED VIEW */

CREATE MATERIALIZED VIEW EVERY_BBL_MV 
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 6/20/2012 12:15:12 PM (QP5 v5.163.1008.3004) */
SELECT boro,
       block,
       lot,
       bbl,
       bbl map_bbl,
       (DECODE (boro,
                '1', 'MANHATTAN ',
                '2', 'BRONX ',
                '3', 'BROOKLYN ',
                '4', 'QUEENS ',
                '5', 'STATEN ISLAND ')
        || 'Block: '
        || block
        || ' Lot: '
        || lot)
          title,
       effective_tax_year
  FROM TAX_LOT_POLYGON
UNION
SELECT boro,
       block,
       TO_NUMBER (SUBSTR (condo_billing_bbl, 7)) lot,
       o.condo_billing_bbl bbl,
       t.bbl map_bbl,
       (DECODE (boro,
                '1', 'MANHATTAN ',
                '2', 'BRONX ',
                '3', 'BROOKLYN ',
                '4', 'QUEENS ',
                '5', 'STATEN ISLAND ')
        || 'Block: '
        || block
        || ' Lot: '
        || t.lot)
          title,
       NULL effective_tax_year
  FROM TAX_LOT_POLYGON t, condo o
 WHERE condo_base_bbl = t.bbl
UNION
SELECT boro,
       block,
       unit_lot lot,
       o.unit_bbl bbl,
       t.bbl map_bbl,
       (DECODE (boro,
                '1', 'MANHATTAN ',
                '2', 'BRONX ',
                '3', 'BROOKLYN ',
                '4', 'QUEENS ',
                '5', 'STATEN ISLAND ')
        || 'Block: '
        || block
        || ' Lot: '
        || t.lot)
          title,
       o.effective_tax_year
  FROM TAX_LOT_POLYGON t, condo_units o
 WHERE condo_base_bbl = t.bbl
UNION
SELECT boro,
       block,
       o.air_rights_lot_number lot,
       o.air_rights_bbl bbl,
       t.bbl map_bbl,
       (DECODE (boro,
                '1', 'MANHATTAN ',
                '2', 'BRONX ',
                '3', 'BROOKLYN ',
                '4', 'QUEENS ',
                '5', 'STATEN ISLAND ')
        || 'Block: '
        || block
        || ' Lot: '
        || t.lot)
          title,
       o.effective_tax_year
  FROM TAX_LOT_POLYGON t, air_rights_lots o
 WHERE donating_bbl = t.bbl
UNION
SELECT boro,
       block,
       SUBTERRANEAN_LOT_NUMBER lot,
          O.APPURTENANT_BORO
       || LPAD (O.APPURTENANT_BLOCK, 5, '0')
       || LPAD (O.SUBTERRANEAN_LOT_NUMBER, 4, '0')
          bbl,
       t.bbl map_bbl,
       (DECODE (boro,
                '1', 'MANHATTAN ',
                '2', 'BRONX ',
                '3', 'BROOKLYN ',
                '4', 'QUEENS ',
                '5', 'STATEN ISLAND ')
        || 'Block: '
        || block
        || ' Lot: '
        || t.lot)
          title,
       o.effective_tax_year
  FROM TAX_LOT_POLYGON t, subterranean_lots o
 WHERE appurtenant_bbl = t.bbl;

COMMENT ON MATERIALIZED VIEW EVERY_BBL_MV IS 'snapshot table for snapshot DOF_TAXMAP.EVERY_BBL_MV';
