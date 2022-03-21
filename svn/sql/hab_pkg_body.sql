CREATE OR REPLACE PACKAGE BODY DOF_TAXMAP.PKG_ALTERATION_BOOK
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
/