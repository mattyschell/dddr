CREATE OR REPLACE PACKAGE PKG_ALTERATION_BOOK
IS
   TYPE curSearchResults
   IS
   REF CURSOR;

   TYPE curDetails
   IS
   REF CURSOR;


   PROCEDURE PROC_GET_BOROS(
     outResults OUT curDetails
   );

   PROCEDURE PROC_GET_BORO_BLOCK(
        inBorough IN VARCHAR,
        inBlock IN VARCHAR,
         inSection IN VARCHAR,
      inVolume IN VARCHAR,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
     outResults OUT curDetails
   );

      PROCEDURE PROC_GET_BORO_VOLUME(
        inSection IN VARCHAR,
        inVolume IN VARCHAR,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
     outResults OUT curDetails
   );
     PROCEDURE PROC_GET_MAP_INSET(
      inSection IN varchar,
     outResults OUT curDetails
   );
      PROCEDURE PROC_GET_MAP_LIBRARY_PDF(
      inParentId IN varchar,
      inChildId IN varchar,
     outResults OUT curDetails
   );
     PROCEDURE PROC_GET_MAP_INSET_PDF(
     inSection IN varchar,
     outResults OUT curDetails
   );


   PROCEDURE PROC_DETAILS_AIR_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_BOUNDARY_LINE(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_CONDO(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_CONDO_UNIT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_REUC(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_SUB_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_TAX_LOT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   );




    PROCEDURE PROC_SEARCH_AIR_RIGHTS(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inAirRightsNum IN NUMBER,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOROUGH_BLOCK(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_SORT(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inChangeType IN VARCHAR,
        inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_LOT(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inLot IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_BOUNDARY_LINE(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inLineType IN VARCHAR,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_CONDO(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inCondoNum IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_REUC(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inREUCIdent IN VARCHAR,
        inChangeType IN VARCHAR,  inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

    PROCEDURE PROC_SEARCH_SUB_RIGHTS(
        inDateType IN VARCHAR,
        inStartDate IN VARCHAR,
        inEndDate IN VARCHAR,
        inToday IN NUMBER,
        inLastDays IN NUMBER,
        inLastYears IN NUMBER,
        inBorough IN NUMBER,
        inBlock IN NUMBER,
        inSubNum IN NUMBER,
        inChangeType IN VARCHAR,
          inSortColumn in varchar,
        inSortOrder in varchar,
        outResults OUT curSearchResults
    );

   PROCEDURE PROC_GET_HAB_LIST(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inSection IN VARCHAR,
      inVolume IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_GET_HAB_PDF(
      inParentId IN VARCHAR,
      outResults OUT curDetails
   );
   
END;

----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY PKG_ALTERATION_BOOK
IS
   PROCEDURE PROC_GET_BOROS(
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT CODE,
         DESCRIPTION
      FROM DAB_DOMAINS
      ORDER BY CODE;
   END;
   PROCEDURE PROC_GET_BORO_BLOCK(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inSection IN VARCHAR,
      inVolume IN VARCHAR,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curDetails
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN
      strSQL :=
      'SELECT t.TRANS_NUM,
    t.BLOCK,t.SECTION,t.VOLUME,    t.EFFECTIVE_DATE,
    t.END_DATE,    t.CURRENT_FLAG,    t.ID,
    d.description "Borough"
    FROM  MAP_LIBRARY t ,dab_domains d
           WHERE t.borough = d.code';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.block = ' || inBlock ;
      END IF;
      IF inSection IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.section = ' || inSection ;
      END IF;
      IF inVolume IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.volume = ' || inVolume ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType = 'Y'
         THEN
            strSQL := strSQL || ' and t.CURRENT_FLAG = ''' || inChangeType || '''' ;
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.EFFECTIVE_DATE desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_GET_BORO_VOLUME(
      inSection IN VARCHAR,
      inVolume IN VARCHAR,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curDetails
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN
      strSQL :=
      'SELECT t.TRANS_NUM,
    t.BLOCK,t.SECTION,t.VOLUME,    t.EFFECTIVE_DATE,
    t.END_DATE,    t.CURRENT_FLAG,    t.ID,
    d.description "Borough"
    FROM  MAP_LIBRARY t ,dab_domains d
           WHERE t.borough = d.code';
      IF inSection IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.section = ' || inSection ;
      END IF;
      IF inVolume IS NOT NULL
      THEN
         strSQL := strSQL || ' and t.volumne = ' || inVolume ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType = 'Y'
         THEN
            strSQL := strSQL || ' and t.CURRENT_FLAG = ''' || inChangeType || '''' ;
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.EFFECTIVE_DATE desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_GET_MAP_INSET(
      inSection IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT ID,
         SEQ
      FROM MAP_INSET_LIBRARY
      WHERE ID = inSection
      ORDER BY SEQ;
   END;
   PROCEDURE PROC_GET_MAP_LIBRARY_PDF(
      inParentId IN VARCHAR,
      inChildId IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      IF inChildId IS NULL
      THEN
         OPEN outResults FOR
         SELECT map
         FROM MAP_LIBRARY p
         WHERE p.ID = inParentId;
      ELSE
         OPEN outResults FOR
         SELECT map
         FROM MAP_INSET_LIBRARY p
         WHERE p.ID = inParentId
         AND (p.SEQ = inChildId
         OR inChildId IS NULL);
      END IF;
   END;
   PROCEDURE PROC_GET_MAP_INSET_PDF(
      inSection IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT map
      FROM MAP_INSET_LIBRARY
      WHERE ID = inSection;
   END;
   PROCEDURE PROC_DETAILS_AIR_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         a.block "Block",
         TO_NUMBER(SUBSTR(a.bbl, 7, 4)) "Lot",
         ac.action_definition "Air Rights Action",
         ad.type_definition "Air Rights Type",
         a.AIR_RIGHTS_NUM "Rights Number"
      --ac1.action_definition "Lot Action"
      FROM dab_air_rights a, dab_air_rights_definition ad, dab_action_definition ac, dab_domains d
      --, dab_action_definition ac1  ,dab_tax_lots l
      WHERE a.air_rights_type = ad.type_code
      AND a.air_rights_action = ac.action_code
      -- AND l.lot_action = ac1.action_code
      AND a.borough = d.code
      AND a.trans_num = inTransNum
      ORDER BY a.borough, a.block, TO_NUMBER(SUBSTR(a.bbl, 7, 4));
   END;
   PROCEDURE PROC_DETAILS_BOUNDARY_LINE(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         l.block "Block",
         l.lot "Lot",
         ac.action_definition "Boundary Line Action",
         b.boundary_type "Boundary Line Type",
         b.action_details "Boundary Line Details"
      FROM dab_boundary_line b, dab_tax_lots l, dab_action_definition ac, dab_domains d
      WHERE b.trans_num = l.trans_num
      AND l.borough = d.code
      AND b.boundary_action = ac.action_code
      AND b.trans_num = inTransNum
      ORDER BY d.description, l.block, l.lot;
   END;
   PROCEDURE PROC_DETAILS_CONDO(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         TO_NUMBER(SUBSTR(c.bbl, 2, 5)) "Block",
         TO_NUMBER(SUBSTR(c.bbl, 7, 4)) "Lot",
         c.condo_num "Condo Number",
         ac.action_definition "Condo Action"
      FROM dab_condo_conversion c, dab_action_definition ac, dab_domains d
      WHERE c.condo_borough = d.code
      AND c.condo_action = ac.action_code
      AND c.trans_num = inTransNum
      ORDER BY d.description, TO_NUMBER(SUBSTR(c.bbl, 2, 5)), TO_NUMBER(SUBSTR( c.bbl, 7, 4));
   END;
   PROCEDURE PROC_DETAILS_CONDO_UNIT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         cu.unit_block "Block",
         cu.unit_lot "Condo Unit",
         SUBSTR(cu.condo_key, 2) "Condo Number",
         ac.action_definition "Condo Unit Action",
         TO_NUMBER(SUBSTR(cu.BASE_BBL_CONDO_KEY, 7, 4)) "Lot"
      FROM dab_condo_units cu, dab_action_definition ac, dab_domains d
      WHERE cu.unit_action = ac.action_code
      AND cu.unit_borough = d.code
      AND cu.trans_num = inTransNum
      ORDER BY d.description, cu.unit_block, cu.unit_lot;
   END;
   PROCEDURE PROC_DETAILS_REUC(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         TO_NUMBER(SUBSTR(r.bbl, 2, 5)) "Block",
         TO_NUMBER(SUBSTR(r.bbl, 7, 4)) "Lot",
         ac.action_definition "REUC Action",
         r.reuc_ident
      FROM dab_reuc r, dab_action_definition ac, dab_domains d
      WHERE r.reuc_action = ac.action_code
      AND SUBSTR(r.bbl, 1, 1) = d.code
      AND r.trans_num = inTransNum
      ORDER BY d.description, TO_NUMBER(SUBSTR(r.bbl, 2, 5)), TO_NUMBER(SUBSTR( r.bbl, 7, 4));
   END;
   PROCEDURE PROC_DETAILS_SUB_RIGHTS(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         s.block "Block",
         TO_NUMBER(SUBSTR(s.bbl, 7, 4)) "Lot",
         ac.action_definition "Subterranean Rights Action",
         s.SUB_RIGHTS_NUM "Rights Number"
      FROM dab_subterranean_rights s, dab_action_definition ac, dab_domains d
      WHERE s.sub_rights_action = ac.action_code
      AND s.borough = d.code
      AND s.trans_num = inTransNum
      ORDER BY d.description, s.block, TO_NUMBER(SUBSTR(s.bbl, 7, 4));
   END;
   PROCEDURE PROC_DETAILS_TAX_LOT(
      inTransNum IN NUMBER,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT d.description "Borough",
         l.block "Block",
         l.lot "Lot",
         ac.action_definition "Lot Action"
      FROM dab_tax_lots l, dab_action_definition ac, dab_domains d
      WHERE l.lot_action = ac.action_code
      AND l.borough = d.code
      AND l.trans_num = inTransNum
      ORDER BY d.description, l.block, l.lot;
   END;
   PROCEDURE PROC_SEARCH_AIR_RIGHTS(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inAirRightsNum IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN

      --TO_NUMBER(SUBSTR(a.bbl, 7, 4)) "Lot",
      strSQL :=
      '  SELECT t.wizard_name "Change Type",
             ac.action_definition "Air Rights Action"    ,
             l.LOT "Lot",
            ad.type_definition "Air Rights Type",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num ,

         ac1.action_definition "Lot Action"
         FROM dab_wizard_transaction t, dab_air_rights a,
         dab_air_rights_definition ad, dab_action_definition ac ,dab_action_definition ac1,  dab_tax_lots l
         WHERE t.trans_num = a.trans_num
          AND t.trans_num = l.trans_num
         AND a.air_rights_type = ad.type_code
         AND a.air_rights_action = ac.action_code
           AND l.lot_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and a.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and a.block = ' || inBlock ;
      END IF;
      IF inAirRightsNum IS NOT NULL
      THEN
     strSQL := strSQL || ' and a.air_rights_num = ' || inAirRightsNum ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_SORT(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
   BEGIN
      IF inToday = 1
      THEN
         OPEN outResults FOR
         SELECT t.wizard_name "Change Type",
            ac1.action_definition "Lot Action",
            l.lot "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM dab_wizard_transaction t, dab_tax_lots l, dab_action_definition ac1
         WHERE t.trans_num = l.trans_num
         AND l.lot_action = ac1.action_code
         AND (l.borough = inBorough
         OR inBorough = 0)
         AND (l.block = inBlock
         OR inBlock = 0)
         AND (LOWER(t.wizard_name) = LOWER(inChangeType)
         OR inChangeType = 'All Changes')
         ORDER BY t.change_date DESC;
      ELSIF inLastDays > 0
      THEN
         OPEN outResults FOR
         SELECT t.wizard_name "Change Type",
            ac.action_definition "Lot Action",
            l.lot "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM dab_wizard_transaction t, dab_tax_lots l, dab_action_definition ac
         WHERE t.trans_num = l.trans_num
         AND l.lot_action = ac.action_code
         AND t.change_date >= TO_DATE(TO_CHAR(SYSDATE, 'MM/DD/YYYY'), 'MM/DD/YYYY') - inLastDays
         AND t.change_date < TO_DATE(TO_CHAR(SYSDATE, 'MM/DD/YYYY'), 'MM/DD/YYYY') + 1
         AND (l.borough = inBorough
         OR inBorough = 0)
         AND (l.block = inBlock
         OR inBlock = 0)
         AND (LOWER(t.wizard_name) = LOWER(inChangeType)
         OR inChangeType = 'All Changes')
         ORDER BY t.change_date DESC;
      ELSIF inLastYears > 0
      THEN
         OPEN outResults FOR
         SELECT t.wizard_name "Change Type",
            ac.action_definition "Lot Action",
            l.lot "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM dab_wizard_transaction t, dab_tax_lots l, dab_action_definition ac
         WHERE t.trans_num = l.trans_num
         AND l.lot_action = ac.action_code
         AND t.change_date >= ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'MM/DD/YYYY'), 'MM/DD/YYYY'), ( - 12 * inLastYears))
         AND t.change_date < TO_DATE(TO_CHAR(SYSDATE, 'MM/DD/YYYY'), 'MM/DD/YYYY') + 1
         AND (l.borough = inBorough
         OR inBorough = 0)
         AND (l.block = inBlock
         OR inBlock = 0)
         AND (LOWER(t.wizard_name) = LOWER(inChangeType)
         OR inChangeType = 'All Changes')
         ORDER BY t.change_date DESC;
      ELSE
         OPEN outResults FOR
         SELECT t.wizard_name "Change Type",
            ac.action_definition "Lot Action",
            l.lot "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM dab_wizard_transaction t, dab_tax_lots l, dab_action_definition ac
         WHERE t.trans_num = l.trans_num
         AND l.lot_action = ac.action_code
         AND (t.change_date >= TO_DATE(inStartDate, 'MM/DD/YYYY')
         OR inStartDate IS NULL)
         AND (t.change_date <= TO_DATE(inEndDate, 'MM/DD/YYYY')
         OR inEndDate IS NULL)
         AND (l.borough = inBorough
         OR inBorough = 0)
         AND (l.block = inBlock
         OR inBlock = 0)
         AND (LOWER(t.wizard_name ) = LOWER(inChangeType)
         OR inChangeType = 'All Changes')
         ORDER BY t.change_date DESC;
      END IF;
   END;
   PROCEDURE PROC_SEARCH_BOROUGH_BLOCK(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN
      strSQL :=
      'select  t.wizard_name "Change Type", ac1.action_definition "Lot Action", l.lot "Lot",
                        t.auth_for_change "Auth for Change", t.change_date "Change Date", t.trans_num
                from    dab_wizard_transaction t, dab_tax_lots l, dab_action_definition ac1
                where   t.trans_num = l.trans_num
                and     l.lot_action = ac1.action_code ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.block = ' || inBlock ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc' ;
      OPEN outResults FOR strSQL;
   END;
PROCEDURE PROC_SEARCH_BOROUGH_BLOCK_LOT
(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inLot IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(6000);

   BEGIN
      strSQL :=
      'SELECT t.wizard_name "Change Type",
            ac1.action_definition "Lot Action",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM DAB_WIZARD_TRANSACTION t, DAB_TAX_LOTS l, DAB_ACTION_DEFINITION
         ac1
         WHERE t.trans_num = l.trans_num
         AND l.lot_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.block = ' || inBlock ;
      END IF;
      IF inLot IS NOT NULL
      THEN
     strSQL := strSQL || ' and l.lot = ' || inLot ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      --TO SEARCH ON CONDO_UNIT
      strSQL := strSQL || ' UNION SELECT t.wizard_name "Change Type",
            ac1.action_definition "Lot Action",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num
         FROM DAB_WIZARD_TRANSACTION t, DAB_CONDO_UNITS l, DAB_ACTION_DEFINITION
         ac1
         WHERE t.trans_num = l.trans_num
         AND l.unit_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.UNIT_BOROUGH = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.UNIT_BLOCK = ' || inBlock ;
      END IF;
      IF inLot IS NOT NULL
      THEN
     strSQL := strSQL || ' and l.UNIT_LOT = ' || inLot ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' 4 DESC' ;

    OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_SEARCH_BOUNDARY_LINE(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inLineType IN VARCHAR,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN
      strSQL :=
      ' SELECT t.wizard_name "Change Type",
            l.lot "Lot",
            ac.action_definition "Boundary Line Action",
            b.boundary_type "Boundary Line Type",
            b.action_details "Boundary Line Details",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num ,ac1.action_definition "Lot Action"
         FROM dab_wizard_transaction t, dab_boundary_line b, dab_tax_lots l,  dab_action_definition ac1,
         dab_action_definition ac
         WHERE t.trans_num = b.trans_num
         AND t.trans_num = l.trans_num
         AND b.boundary_action = ac.action_code
           AND l.lot_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and l.block = ' || inBlock ;
      END IF;
      IF inLineType IS NOT NULL
      THEN
         strSQL := strSQL || ' and b.boundary_type = ''' || inLineType ||'''' ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name )= lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_SEARCH_CONDO(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inCondoNum IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN

      --TO_NUMBER(SUBSTR(c.bbl, 7, 4)) "Lot",
      strSQL :=
      '  SELECT t.wizard_name "Change Type",
            ac.action_definition "Condo Action",
             l.LOT "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num ,
             ac1.action_definition "Lot Action"

         FROM dab_wizard_transaction t, dab_condo_conversion c,
         dab_action_definition ac , dab_action_definition ac1,  dab_tax_lots l
         WHERE t.trans_num = c.trans_num
          AND t.trans_num = l.trans_num
         AND c.condo_action = ac.action_code
           AND l.lot_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and c.condo_borough = ' || inBorough ;
      END IF;
      IF inCondoNum IS NOT NULL
      THEN
         strSQL := strSQL || ' and c.condo_num = ' || inCondoNum ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_SEARCH_REUC(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inREUCIdent IN VARCHAR,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN

      --TO_NUMBER(SUBSTR(r.bbl, 2, 5)) "Block",
      --TO_NUMBER(SUBSTR(r.bbl, 7, 4)) "Lot",
      strSQL :=
      '  SELECT t.wizard_name "Change Type",
            ac.action_definition "REUC Action",
            d.description "Borough",
            l.BLOCK "Block",
            l.LOT "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num ,
              ac1.action_definition "Lot Action"
         FROM dab_wizard_transaction t, dab_reuc r, dab_action_definition ac,
         dab_domains d , dab_action_definition ac1,   dab_tax_lots l
         WHERE t.trans_num = r.trans_num
          AND t.trans_num = l.trans_num
         AND r.reuc_action = ac.action_code
         AND SUBSTR(r.bbl, 1, 1) = d.code
           AND l.lot_action = ac1.action_code   ';
      IF inREUCIdent IS NOT NULL
      THEN
         strSQL := strSQL || ' and lower(r.reuc_ident) = lower(''' || inREUCIdent || ''')' ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name) = lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc' ;
      OPEN outResults FOR strSQL;
   END;
   PROCEDURE PROC_SEARCH_SUB_RIGHTS(
      inDateType IN VARCHAR,
      inStartDate IN VARCHAR,
      inEndDate IN VARCHAR,
      inToday IN NUMBER,
      inLastDays IN NUMBER,
      inLastYears IN NUMBER,
      inBorough IN NUMBER,
      inBlock IN NUMBER,
      inSubNum IN NUMBER,
      inChangeType IN VARCHAR,
      inSortColumn IN VARCHAR,
      inSortOrder IN VARCHAR,
      outResults OUT curSearchResults
   )
   IS
      strSQL VARCHAR2(4000);
   BEGIN

      --TO_NUMBER(SUBSTR(s.bbl, 7, 4)) "Lot",
      strSQL :=
      '  SELECT t.wizard_name "Change Type",
            ac.action_definition "Subterranean Rights Action",
            l.LOT "Lot",
            t.auth_for_change "Auth for Change",
            t.change_date "Change Date",
            t.trans_num ,  ac1.action_definition "Lot Action"
         FROM dab_wizard_transaction t, dab_subterranean_rights s,
         dab_action_definition ac , dab_action_definition ac1,   dab_tax_lots l
         WHERE t.trans_num = s.trans_num
          AND t.trans_num = l.trans_num
         AND s.sub_rights_action = ac.action_code
           AND l.lot_action = ac1.action_code  ';
      IF inBorough IS NOT NULL
      THEN
         strSQL := strSQL || ' and s.borough = ' || inBorough ;
      END IF;
      IF inBlock IS NOT NULL
      THEN
         strSQL := strSQL || ' and s.block = ' || inBlock ;
      END IF;
      IF inSubNum IS NOT NULL
      THEN
        strSQL := strSQL || ' and s.sub_rights_num = ' || inSubNum ;
      END IF;
      IF inChangeType IS NOT NULL
      THEN
         IF inChangeType <> 'All Changes'
         THEN
            strSQL := strSQL || ' and lower(t.wizard_name )= lower(''' || inChangeType || ''')' ;
         END IF;
      END IF;
      IF inToday = 1
      THEN
         strSQL := strSQL || '';
      ELSIF inLastDays > 0
      THEN
         strSQL := strSQL || ' and  t.change_date >= to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') -' ||
         inLastDays || 'and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSIF inLastYears > 0
      THEN
         strSQL := strSQL||
         ' and t.change_date >= add_months(to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY''), (-12 * ' ||
         inLastYears || ')) and  t.change_date < to_date(to_char(sysdate, ''MM/DD/YYYY''), ''MM/DD/YYYY'') + 1' ;
      ELSE
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date >= to_date(''' || inStartDate || ''',''mm/dd/yyyy'')';
         END IF;
         IF inStartDate IS NOT NULL
         THEN
            strSQL := strSQL || ' and  t.change_date <= to_date(''' || inEndDate || ''',''mm/dd/yyyy'')';
         END IF;
      END IF;
      strSQL := strSQL || ' order by ' ;
      IF inSortColumn IS NOT NULL
      THEN
         strSQL := strSQL || inSortColumn || ' ' || inSortOrder || ' ,' ;
      END IF;
      strSQL := strSQL || ' t.change_date desc ';
      OPEN outResults FOR strSQL;
   END;

   -- New proc for HAB
   PROCEDURE PROC_GET_HAB_LIST(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inSection IN VARCHAR,
      inVolume IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      IF inBlock IS NULL
      THEN
         OPEN outResults FOR
         SELECT id, DECODE(borough, 1, 'Manhattan', 2, 'Bronx', 3, 'Brooklyn', 4, 'Queens', 5, 'Staten Island', '?') borough, book, start_year, end_year, section, volume, page
         FROM hab
         WHERE borough = inBorough
         AND section = inSection
         AND volume = inVolume
         ORDER BY start_year DESC, end_year DESC, page ASC;
      ELSE
         OPEN outResults FOR
            SELECT id, DECODE(borough, 1, 'Manhattan', 2, 'Bronx', 3, 'Brooklyn', 4, 'Queens', 5, 'Staten Island', '?') borough, book, start_year, end_year, section, volume, page
            FROM hab 
            WHERE section = (SELECT DISTINCT section_number 
            FROM tax_block_polygon 
            WHERE block = inBlock  AND boro = inBorough) AND 
            volume = (SELECT DISTINCT volume_number 
            FROM tax_block_polygon 
            WHERE block = inBlock  AND boro = inBorough)
            AND borough = inBorough
            ORDER BY start_year DESC, end_year DESC, page ASC;
      END IF;
   END;

   -- New proc for HAB
   PROCEDURE PROC_GET_HAB_PDF(
      inParentId IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN   
         OPEN outResults FOR
         SELECT pdf
         FROM hab p
         WHERE p.id = inParentId;
   END;

END;

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_DTM_REPORTS AS

TYPE t_cursor IS REF CURSOR;

PROCEDURE Zero_Section_Volume
 (
    d_cursor OUT t_cursor
 );

PROCEDURE Map_Library
 (
    d_cursor OUT t_cursor
 );

PROCEDURE DAB_Transaction_Weekly
 (
    d_cursor OUT t_cursor
 );

END PKG_DTM_REPORTS;


----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY PKG_DTM_REPORTS AS

PROCEDURE Zero_Section_Volume   
 (
    d_cursor OUT t_cursor
 )
 IS
       v_err_msg          Varchar(300);

BEGIN
 
Open d_cursor For

SELECT borough as "Borough",block as "Block"
FROM map_library
WHERE section = 0 and volume = 0
order by borough;
            
       EXCEPTION
            When Others Then
                v_err_msg := substr(sqlerrm,1,200);

                Open d_cursor For
                Select 'Check Zero_Section_Volume for errors. ' || v_err_msg from dual;

END Zero_Section_Volume;

PROCEDURE Map_Library   
 (
    d_cursor OUT t_cursor
 )
 IS
       v_err_msg          Varchar(300);

BEGIN
 
Open d_cursor For

select dtl.borough as "Borough",dtl.block as "Block",max(effective_date) as "Effective Date",DWT.user_id as "User ID",DWT.auth_for_change as "Authority For Change", 'NEEDS NEW MAP' as "Status"
from dab_tax_lots dtl, dab_wizard_transaction dwt, map_library ml
where dtl.trans_num = dwt.trans_num
and DTL.BOROUGH = ML.BOROUGH and dtl.block = ml.block
and current_flag is null
and sign(change_date - effective_date) = 1
group by dtl.borough,dtl.block, dwt.user_id, dwt.auth_for_change
order by dtl.borough, dtl.block;
            
       EXCEPTION
            When Others Then
                v_err_msg := substr(sqlerrm,1,200);

                Open d_cursor For
                Select 'Check Map_Library for errors. ' || v_err_msg from dual;

END Map_Library;

PROCEDURE DAB_Transaction_Weekly
 (
    d_cursor OUT t_cursor
 )
 IS
       v_err_msg          Varchar(300);

BEGIN
-- <Toad_265642831_1> *** DO NOT REMOVE THE AUTO DEBUGGER START/END TAGS
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_1} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_1}[--- 1 ---]');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_1} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_1}[1] v_err_msg = ' || v_err_msg);
-- </Toad_265642831_1>

 
Open d_cursor For

SELECT DWT.TRANS_NUM "Transaction",TO_CHAR(DWT.CHANGE_DATE, 'MM/DD/YYYY') "Date", UPPER(DWT.USER_ID) "Cartographer",DD.DESCRIPTION "Borough",DTL.BLOCK "Block",DTL.LOT "Lot",DAD.ACTION_DEFINITION "Action",DWT.AUTH_FOR_CHANGE "Authority for Change"
FROM DAB_WIZARD_TRANSACTION DWT, DAB_TAX_LOTS DTL, DAB_ACTION_DEFINITION DAD, DAB_DOMAINS DD
WHERE DWT.TRANS_NUM = DTL.TRANS_NUM  AND DTL.LOT_ACTION = DAD.ACTION_CODE AND  DWT.WIZARD_NAME = 'Digital Alteration Book Wizard'
AND DTL.BOROUGH = DD.CODE AND TRUNC(DWT.CHANGE_DATE) BETWEEN TRUNC(SYSDATE - 7) AND TRUNC(SYSDATE - 1)
AND UPPER(DWT.USER_ID) IN (SELECT UNIQUE(UPPER(USER_ID)) FROM DAB_WIZARD_TRANSACTION) ORDER BY DWT.TRANS_NUM
;
            
       EXCEPTION
            When Others Then
                v_err_msg := substr(sqlerrm,1,200);
-- <Toad_265642831_2> *** DO NOT REMOVE THE AUTO DEBUGGER START/END TAGS
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_2} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_2}[--- 2 ---]');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_2} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_2}[2] v_err_msg = ' || v_err_msg);
-- </Toad_265642831_2>


                Open d_cursor For
                Select 'Check DAB_Transaction_Weekly for errors. ' || v_err_msg from dual;
-- <Toad_265642831_3> *** DO NOT REMOVE THE AUTO DEBUGGER START/END TAGS
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_3} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_3}[--- 3 ---]');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_3} ');
DBMS_OUTPUT.PUT_LINE('{Toad_265642831_3}[3] v_err_msg = ' || v_err_msg);
-- </Toad_265642831_3>


END DAB_Transaction_Weekly;

END PKG_DTM_REPORTS;

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_MAP_DISPLAY
IS
   TYPE curDetails
   IS
   REF CURSOR;


   PROCEDURE PROC_DETAILS_CONDO(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   );
   PROCEDURE PROC_DETAILS_CONDO_UNIT(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_AIR_RIGHT(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_REUC(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_SUB_RIGHTS(
       inTrans IN VARCHAR,
      outResults OUT curDetails
   );

   PROCEDURE PROC_DETAILS_BBLS(
      inBBLS IN VARCHAR,
      outResults OUT curDetails
   );


    PROCEDURE PROC_SEARCH_REUC_Ident(
        inREUCIdent IN VARCHAR,
        outResults OUT curDetails
    );

    PROCEDURE PROC_SEARCH_AIR_SUB_RIGHTS(
        inBorough IN VARCHAR,
        inBlock IN VARCHAR,
        inAirSubRights IN VARCHAR,
        outResults OUT curDetails
    );


    PROCEDURE PROC_SEARCH_CONDO(
        inBorough IN VARCHAR,
        inCondo VARCHAR,
        outResults OUT curDetails
    );
 PROCEDURE PROC_SEARCH_BOROUGH_LOT(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inLot IN VARCHAR,
      outResults OUT curDetails
   );
     PROCEDURE PROC_SEARCH_BBL(
      inLot IN VARCHAR,
      outResults OUT curDetails
   );
PROCEDURE PROC_SEARCH_ACRIS_LOT(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inLot IN VARCHAR,
      outResults OUT curDetails
   );
     PROCEDURE PROC_SEARCH_ACRIS_BBL(
      inLot IN VARCHAR,
      outResults OUT curDetails
   );
END;


----------------------------------------------------------------------

-- empty body for PKG_MAP_DISPLAY in production!!
-- got this from staging

CREATE OR REPLACE PACKAGE BODY DOF_TAXMAP.PKG_MAP_DISPLAY
IS
   PROCEDURE PROC_DETAILS_CONDO(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT DISTINCT c.CONDO_NAME,
         c.CONDO_NUMBER,
         t.EFFECTIVE_TAX_YEAR,
         DECODE(a.AIR_RIGHTS_BBL, NULL, '', SUBSTR(a.AIR_RIGHTS_BBL, 7)) air_right_condo,
         DECODE(c.condo_billing_bbl, NULL, '', SUBSTR(c.condo_billing_bbl, 7)) condo_billing_lot,
         DECODE(t.BBL, NULL, c.CONDO_BASE_BBL, t.BBL) bbl,
         c.CONDO_BASE_BBL_KEY
      FROM CONDO c, AIR_RIGHTS_CONDOS a, tax_lot_polygon t
      WHERE c.CONDO_KEY = a.CONDO_KEY (+)
      AND c.condo_base_bbl = a.condo_base_bbl (+)
      AND c.CONDO_BASE_BBL = t.BBL (+)
      AND c.CONDO_BASE_BBL = inTrans
      ORDER BY condo_number, condo_billing_lot;
   END;
   PROCEDURE PROC_DETAILS_CONDO_UNIT(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT DISTINCT f.UNIT_DESIGNATION,
         f.EFFECTIVE_TAX_YEAR,
         f.UNIT_LOT,
         f.UNIT_BLOCK,
         f.CONDO_BASE_BBL,
         f.CONDO_NUMBER,
         ('borough='|| f.CONDO_BORO || '&block=' || f.CONDO_BASE_BLOCK || '&lot=' || f.UNIT_LOT) ACRIS
      FROM CONDO_UNITS f
      WHERE f.CONDO_BASE_BBL_KEY = inTrans
      ORDER BY condo_number, unit_lot, unit_block;
   END;
   PROCEDURE PROC_DETAILS_AIR_RIGHT(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT SUBSTR(air_rights_bbl, 7) "LOT",
         ('borough='|| SUBSTR(air_rights_bbl, 1, 1) || '&block=' || TO_NUMBER(SUBSTR(air_rights_bbl, 2, 5)) || '&lot='
         || TO_NUMBER(SUBSTR(air_rights_bbl, 7))) ACRIS,
         EFFECTIVE_TAX_YEAR
      FROM air_rights_lots
      WHERE donating_bbl = inTrans
      order by air_rights_bbl;
   END;
   PROCEDURE PROC_DETAILS_REUC(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT REUC_NUMBER,
         EFFECTIVE_TAX_YEAR
      FROM reuc_lots
      WHERE appurtenant_bbl = inTrans order by REUC_NUMBER;
   END;
   PROCEDURE PROC_DETAILS_SUB_RIGHTS(
      inTrans IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT subterranean_lot_number "LOT",
         ('borough='|| APPURTENANT_BORO || '&block=' || APPURTENANT_BLOCK || '&lot=' || subterranean_lot_number ) ACRIS
         ,
         EFFECTIVE_TAX_YEAR
      FROM subterranean_lots
      WHERE appurtenant_bbl = inTrans order by subterranean_lot_number;
   END;
   PROCEDURE PROC_DETAILS_BBLS(
      inBBLS IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT EFFECTIVE_TAX_YEAR,
         COMMUNITY_DISTRICT,
         SECTION_NUMBER,
         VOLUME_NUMBER,
         DECODE(BORO, 1, 'Manhattan', 2, 'Bronx', 3, 'Brooklyn', 4, 'Queens', 5, 'Staten Island', ' ') BORO,
         BLOCK,
         LOT,
         BBL,
         CONDO_FLAG,
         REUC_FLAG,
         AIR_RIGHTS_FLAG,
         SUBTERRANEAN_FLAG,
         EASEMENT_FLAG,
         ('borough='|| BORO || '&block=' || BLOCK || '&lot=' || LOT) ACRIS
      FROM TAX_LOT_POLYGON
      WHERE BBL = inBBLS;
   END;
   PROCEDURE PROC_SEARCH_REUC_Ident(
      inREUCIdent IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT DISTINCT appurtenant_bbl bbl
      FROM reuc_lots
      WHERE reuc_number = inREUCIdent  ;
   END;
   PROCEDURE PROC_SEARCH_AIR_SUB_RIGHTS(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inAirSubRights IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT DISTINCT donating_bbl bbl
      FROM air_rights_lots
      WHERE air_rights_bbl > 0
      AND donating_boro = inBorough
      AND donating_block = inBlock
      AND TO_NUMBER(SUBSTR(air_rights_bbl, 7)) = inAirSubRights UNION
      SELECT DISTINCT appurtenant_bbl bbl
      FROM subterranean_lots
      WHERE appurtenant_boro = inBorough
      AND appurtenant_block = inBlock
      AND subterranean_lot_number = inAirSubRights
      AND appurtenant_bbl > 0;
   END;
   PROCEDURE PROC_SEARCH_CONDO(
      inBorough IN VARCHAR,
      inCondo VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT condo_base_bbl bbl
      FROM condo
      WHERE condo_base_bbl > 0
      AND condo_boro = inBorough
      AND condo_number = inCondo;
   END;
   PROCEDURE PROC_SEARCH_BOROUGH_LOT(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inLot IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT bbl,
         1 AS datasource
      FROM tax_lot_polygon
      WHERE boro = inBorough
      AND block = inBlock
      AND lot = inLot UNION
      SELECT DISTINCT condo_base_bbl bbl,
         2 AS datasource
      FROM condo_units
      WHERE condo_base_boro = inBorough
      AND condo_base_block = inBlock
      AND unit_lot = inLot
      AND condo_base_bbl > 0 UNION
      SELECT donating_bbl bbl,
         3 AS datasource
      FROM air_rights_lots
      WHERE donating_bbl > 0
      AND donating_boro = inBorough
      AND donating_block = inBlock
      AND TO_NUMBER(SUBSTR(air_rights_bbl, 7)) = inLot UNION
      SELECT appurtenant_bbl bbl,
         4 AS datasource
      FROM subterranean_lots
      WHERE appurtenant_boro = inBorough
      AND appurtenant_block = inBlock
      AND subterranean_lot_number = inLot
      AND appurtenant_bbl > 0 UNION
      SELECT c.condo_base_bbl bbl,
         5 AS datasource
      FROM condo c
      WHERE c.condo_billing_bbl > 0
      AND c.condo_boro = inBorough
      AND TO_NUMBER(SUBSTR(c.condo_billing_bbl, 2, 5)) = inBlock
      AND TO_NUMBER(SUBSTR(c.condo_billing_bbl, 7)) = inLot
      ORDER BY 1, 2;
   END;
   PROCEDURE PROC_SEARCH_BBL(
      inLot IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT bbl,
         1 AS datasource
      FROM tax_lot_polygon
      WHERE bbl = inLot UNION
      SELECT condo_base_bbl bbl,
         2 AS datasource
      FROM condo_units u
      WHERE (condo_base_boro || LPAD(condo_base_block, 5, 0) || LPAD(unit_lot, 5, 0)) = inLot UNION
      SELECT donating_bbl bbl,
         3 AS datasource
      FROM air_rights_lots
      WHERE air_rights_bbl = inLot
      AND donating_bbl > 0 UNION
      SELECT c.condo_base_bbl bbl,
         4 AS datasource
      FROM condo c
      WHERE c.condo_billing_bbl = inLot UNION
      SELECT appurtenant_bbl bbl,
         5 AS datasource
      FROM subterranean_lots
      WHERE (APPURTENANT_BORO || LPAD(APPURTENANT_BLOCK, 5, 0) || LPAD(SUBTERRANEAN_LOT_NUMBER, 5, 0) ) = inLot
      ORDER BY 1, 2;
   END;
   PROCEDURE PROC_SEARCH_ACRIS_LOT(
      inBorough IN VARCHAR,
      inBlock IN VARCHAR,
      inLot IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT bbl,
         1 AS datasource
      FROM tax_lot_polygon
      WHERE boro = inBorough
      AND block = inBlock
      AND lot = inLot UNION
      SELECT DISTINCT condo_base_bbl bbl,
         2 AS datasource
      FROM condo_units
      WHERE condo_base_boro = inBorough
      AND condo_base_block = inBlock
      AND unit_lot = inLot
      AND condo_base_bbl > 0 UNION
      SELECT donating_bbl bbl,
         3 AS datasource
      FROM air_rights_lots
      WHERE donating_bbl > 0
      AND donating_boro = inBorough
      AND donating_block = inBlock
      AND TO_NUMBER(SUBSTR(air_rights_bbl, 7)) = inLot UNION
      SELECT appurtenant_bbl bbl,
         4 AS datasource
      FROM subterranean_lots
      WHERE appurtenant_boro = inBorough
      AND appurtenant_block = inBlock
      AND subterranean_lot_number = inLot
      AND appurtenant_bbl > 0
      ORDER BY 1, 2;
   END;
   PROCEDURE PROC_SEARCH_ACRIS_BBL(
      inLot IN VARCHAR,
      outResults OUT curDetails
   )
   IS
   BEGIN
      OPEN outResults FOR
      SELECT bbl,
         1 AS datasource
      FROM tax_lot_polygon
      WHERE bbl = inLot UNION
      SELECT condo_base_bbl bbl,
         2 AS datasource
      FROM condo_units u
      WHERE (condo_base_boro || LPAD(condo_base_block, 5, 0) || LPAD(unit_lot, 5, 0)) = inLot UNION
      SELECT donating_bbl bbl,
         3 AS datasource
      FROM air_rights_lots
      WHERE air_rights_bbl = inLot
      AND donating_bbl > 0 UNION
      SELECT appurtenant_bbl bbl,
         5 AS datasource
      FROM subterranean_lots
      WHERE (APPURTENANT_BORO || LPAD(APPURTENANT_BLOCK, 5, 0) || LPAD(SUBTERRANEAN_LOT_NUMBER, 5, 0) ) = inLot
      ORDER BY 1, 2;
   END;
END;
