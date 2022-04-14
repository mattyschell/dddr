CREATE OR REPLACE PACKAGE BODY DOF_TAXMAP.GIS_UTILS
AS

   --MSCHELL 20151009
   --For use in geodatashare
   --code resides in python class and is compiled on OracleDdlManager init

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE DUMMY (
      the_letter_a      IN VARCHAR2
   )
   AS

      --mschell! 20161209
      --dumb tester for unit tests.  A profound success would be
      --CALL GIS_UTILS.DUMMY('A');

   BEGIN

      IF UPPER(the_letter_a) = 'A'
      THEN

          RETURN;

      ELSE

         RAISE_APPLICATION_ERROR(-20001, 'Thats not the letter A');

      END IF;

   END DUMMY;

   FUNCTION QUERY_DELIMITED_LIST (
     p_input     IN GIS_UTILS.stringarray,
     p_query     IN NUMBER
   ) RETURN NUMBER DETERMINISTIC
   AS

   BEGIN

      FOR i IN 1 .. p_input.COUNT
      LOOP

         IF TO_NUMBER(p_input(i)) = p_query
         THEN
            RETURN i;
         END IF;

      END LOOP;

      RETURN 0;

   END QUERY_DELIMITED_LIST;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

    FUNCTION SPLIT (
      p_str   IN VARCHAR2,
      p_regex IN VARCHAR2 DEFAULT NULL,
      p_match IN VARCHAR2 DEFAULT NULL,
      p_end   IN NUMBER DEFAULT 0
   ) RETURN GIS_UTILS.stringarray DETERMINISTIC
   AS
      int_delim      PLS_INTEGER;
      int_position   PLS_INTEGER := 1;
      int_counter    PLS_INTEGER := 1;
      ary_output     GIS_UTILS.stringarray;
   BEGIN

      IF p_str IS NULL
      THEN
         RETURN ary_output;
      END IF;

      --Split byte by byte
      --split('ABCD',NULL) gives back A  B  C  D
      IF p_regex IS NULL
      OR p_regex = ''
      THEN
         FOR i IN 1 .. LENGTH(p_str)
         LOOP
            ary_output(i) := SUBSTR(p_str,i,1);
         END LOOP;
         RETURN ary_output;
      END IF;

      LOOP
         EXIT WHEN int_position = 0;
         int_delim  := REGEXP_INSTR(p_str,p_regex,int_position,1,0,p_match);
         IF  int_delim = 0
         THEN
            -- no more matches found
            ary_output(int_counter) := SUBSTR(p_str,int_position);
            int_position  := 0;
         ELSE
            IF int_counter = p_end
            THEN
               -- take the rest as is
               ary_output(int_counter) := SUBSTR(p_str,int_position);
               int_position  := 0;
            ELSE
               ary_output(int_counter) := SUBSTR(p_str,int_position,int_delim-int_position);
               int_counter := int_counter + 1;
               int_position := REGEXP_INSTR(p_str,p_regex,int_position,1,1,p_match);
               IF int_position > length(p_str)
               THEN
                  int_position := 0;
               END IF;
            END IF;
         END IF;
      END LOOP;

     RETURN ary_output;

   END SPLIT;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE DROP_TABLE (
      p_table_name      IN VARCHAR2,
      p_noexists_error  IN VARCHAR2 DEFAULT 'Y'
   )
   AS

      psql      VARCHAR2(4000);

   BEGIN

      psql := 'DROP TABLE ' || UPPER(p_table_name) || ' PURGE';

      BEGIN

         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF SQLCODE = -942
         AND UPPER(p_noexists_error) = 'Y'
         THEN

            RAISE_APPLICATION_ERROR(-20001, 'TABLE ' || UPPER(p_table_name)
                                            || ' doesnt exist');

         ELSIF SQLCODE = -942
         AND UPPER(p_noexists_error) <> 'Y'
         THEN

            RETURN;

         ELSE

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' , '
                                            || dbms_utility.format_error_backtrace);

         END IF;

      END;

   END DROP_TABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE DROP_VIEW (
      p_view_name       IN VARCHAR2,
      p_noexists_error  IN VARCHAR2 DEFAULT 'Y'
   )
   AS

      psql      VARCHAR2(4000);

   BEGIN

      psql := 'DROP VIEW ' || UPPER(p_view_name);

      BEGIN

         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF SQLCODE = -942
         AND UPPER(p_noexists_error) = 'Y'
         THEN

            RAISE_APPLICATION_ERROR(-20001, 'VIEW ' || UPPER(p_view_name)
                                            || ' doesnt exist');

         ELSIF SQLCODE = -942
         AND UPPER(p_noexists_error) <> 'Y'
         THEN

            RETURN;

         ELSE

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' , '
                                            || dbms_utility.format_error_backtrace);

         END IF;

      END;

   END DROP_VIEW;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE DROP_SEQUENCE (
      p_sequence_name       IN VARCHAR2,
      p_noexists_error      IN VARCHAR2 DEFAULT 'Y'
   )
   AS

      psql      VARCHAR2(4000);

   BEGIN

      psql := 'DROP SEQUENCE ' || UPPER(p_sequence_name);

      BEGIN

         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF SQLCODE = -2289
         AND UPPER(p_noexists_error) = 'Y'
         THEN

            RAISE_APPLICATION_ERROR(-20001, 'SEQUENCE ' || UPPER(p_sequence_name)
                                            || ' doesnt exist');

         ELSIF SQLCODE = -2289
         AND UPPER(p_noexists_error) <> 'Y'
         THEN

            RETURN;

         ELSE

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' , '
                                            || dbms_utility.format_error_backtrace);

         END IF;

      END;

   END DROP_SEQUENCE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION TABLE_EXISTS (
      p_table_name      IN VARCHAR2
   ) RETURN BOOLEAN
   AS

       psql           VARCHAR2(4000);
       kount          PLS_INTEGER;

   BEGIN

      --kick out junk right away
      IF LENGTH(p_table_name) = 0
      THEN
         RETURN FALSE;
      END IF;

      psql := 'SELECT count(*) '
           || 'FROM ' || UPPER(p_table_name) || ' a '
           || 'WHERE rownum = 1 ';

      BEGIN

         EXECUTE IMMEDIATE psql INTO kount;

      EXCEPTION
      WHEN OTHERS THEN

         IF SQLCODE = -942
         THEN
            --ORA-00942: table or view does not exist
            RETURN FALSE;
         ELSE
            --What else is possible?
            RETURN FALSE;
         END IF;

      END;

      RETURN TRUE;

   END TABLE_EXISTS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE ASSERT_TABLE_EXISTS (
      p_table_name     IN VARCHAR2
   )
   AS

   BEGIN

      IF NOT TABLE_EXISTS(p_table_name)
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Table ' || p_table_name || ' doesnt exist');

      END IF;

   END ASSERT_TABLE_EXISTS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION SEQUENCE_EXISTS (
      p_sequence_name      IN VARCHAR2
   ) RETURN BOOLEAN
   AS

       psql           VARCHAR2(4000);
       kount          PLS_INTEGER;

   BEGIN

      --kick out junk right away
      IF LENGTH(p_sequence_name) = 0
      THEN
         RETURN FALSE;
      END IF;

      psql := 'SELECT count(*) '
           || 'FROM user_sequences a '
           || 'WHERE a.sequence_name = :p1';

      BEGIN

         EXECUTE IMMEDIATE psql INTO kount USING UPPER(p_sequence_name);

      EXCEPTION
      WHEN OTHERS THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' , '
                                            || dbms_utility.format_error_backtrace);

      END;

      IF kount = 1
      THEN

         RETURN TRUE;

      ELSE

         RETURN FALSE;

      END IF;

   END SEQUENCE_EXISTS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE ASSERT_SEQUENCE_EXISTS(
      p_sequence_name     IN VARCHAR2
   )
   AS

   BEGIN

      IF NOT SEQUENCE_EXISTS(p_sequence_name)
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Sequence ' || p_sequence_name || ' doesnt exist');

      END IF;

   END ASSERT_SEQUENCE_EXISTS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION SPATIAL_INDEX_EXISTS (
      p_table_name         IN VARCHAR2
   ) RETURN BOOLEAN
   AS

      psql        VARCHAR2(4000);
      kount       PLS_INTEGER;

   BEGIN

      IF LENGTH(p_table_name) = 0
      THEN
         RETURN FALSE;
      END IF;

      psql := 'SELECT COUNT(*) '
           || 'FROM user_indexes u '
           || 'WHERE '
           || 'u.table_name = :p1 AND '
           || 'u.index_type = :p2';

      BEGIN

         EXECUTE IMMEDIATE psql INTO kount USING UPPER(p_table_name),
                                                 'DOMAIN';

      EXCEPTION
      WHEN OTHERS THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' , '
                                      || dbms_utility.format_error_backtrace);

      END;

      IF kount > 0
      THEN

         RETURN TRUE;

      ELSE

         RETURN FALSE;

      END IF;

   END SPATIAL_INDEX_EXISTS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE GRANT_PRIVS (
      p_object_name        IN VARCHAR2,
      p_grantee            IN VARCHAR2,
      p_priv               IN VARCHAR2 DEFAULT 'SELECT',
      p_grantee_errors     IN VARCHAR2 DEFAULT 'N'
   )
   AS

      --mschell! 20160630
      --pulled out of raw ddl in python
      --want to trap and snuff errors when user doesnt exist
      --so I can maintain sloppy lists of all possible grantees

      --p_priv could also be comma delimd list like 'SELECT,INSERT,UPDATE,DELETE'
      --so could p_object_name

      psql              VARCHAR2(4000);

   BEGIN

      psql := 'GRANT ' || p_priv || ' ON ' || p_object_name || ' TO ' || p_grantee;

      BEGIN

         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS THEN

         IF  p_grantee_errors = 'N'
         AND SQLCODE = -1917
         THEN

            --ORA-01917: user or role 'GEODATASHARE' does not exist
            NULL;

         ELSE

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

         END IF;

      END;

   END GRANT_PRIVS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE COMPILE_VIEW (
      p_view_name       IN VARCHAR2
   )
   AS

      --MSchell! 20151021
      --primarily a sanity check
      --If the table(s) on which the view is based change,
      --find out now, not on first select and recompile, if
      --theres an error.

      psql              VARCHAR2(4000);

   BEGIN

      psql := 'ALTER VIEW ' || p_view_name ||  ' COMPILE';

      --dont think there's any error handling
      EXECUTE IMMEDIATE psql;

   END COMPILE_VIEW;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE REWIRE_VIEW (
      p_view                IN VARCHAR2,
      p_current_table       IN VARCHAR2,
      p_new_table           IN VARCHAR2
   )
   AS

      --Mschell! 20151021
      --Point a view to a new source table
      --Just one table for now

      --caller must manage metadata (geom, geoserver, other)

      psql              VARCHAR2(4000);
      cols              VARCHAR2(12000);
      text_long         LONG; --ick
      new_select        VARCHAR2(12000);
      view_sql          VARCHAR2(12000);


   BEGIN

      psql := 'SELECT LISTAGG(a.column_name, :p1) '
           || 'WITHIN GROUP (ORDER BY a.column_id) '
           || 'FROM user_tab_cols a '
           || 'WHERE a.table_name = :p2';

      --produces 'SHAPE,OBJECTID,ID,BIN,BBL...'
      EXECUTE IMMEDIATE psql INTO cols USING ',',
                                             UPPER(p_view);

      psql := 'SELECT a.text '
           || 'FROM user_views a '
           || 'WHERE a.view_name = :p1 ';

      --includes the select
      --SELECT SDO_CS.transform (shape, 4326) shape, objectid, ...
      EXECUTE IMMEDIATE psql INTO text_long USING UPPER(p_view);

      new_select := REPLACE(TO_CHAR(text_long),
                            UPPER(p_current_table),
                            UPPER(p_new_table));

      EXECUTE IMMEDIATE 'CREATE OR REPLACE FORCE VIEW '
                     || UPPER(p_view) || ' ('
                     || cols || ') AS '
                     || new_select;

   END REWIRE_VIEW;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE TRANSFORM_TABLE (
      p_table_name         IN VARCHAR2,
      p_srid               IN NUMBER,
      p_column_name        IN VARCHAR2 DEFAULT 'SHAPE',
      p_depth              IN NUMBER DEFAULT 1
   )
   AS

      --mschell! 20160420
      psql                 VARCHAR2(4000);
      current_srid         NUMBER;

   BEGIN

      psql := 'SELECT a.' || p_column_name || '.sdo_srid '
           || 'FROM ' || p_table_name || ' a '
           || 'WHERE rownum = 1';

      EXECUTE IMMEDIATE psql INTO current_srid;

      IF current_srid IS NULL
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Cant transform. First srid of ' || p_table_name
                                      || ' is null');

      ELSIF current_srid = p_srid
      THEN

         RETURN;

      ELSE

         psql := 'UPDATE ' || p_table_name || ' a '
              || 'SET '
              || 'a.' || p_column_name || ' = sdo_cs.transform(a.' || p_column_name || ',:p1)';

      END IF;

      BEGIN

         EXECUTE IMMEDIATE psql USING p_srid;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF SQLERRM LIKE '%layer SRID does not match geometry SRID%'
         THEN

            IF GIS_UTILS.SPATIAL_INDEX_EXISTS(p_table_name)
            AND p_depth = 1
            THEN

               GIS_UTILS.DROP_SPATIAL_INDEX(p_table_name,
                                            p_column_name,
                                            'Y'); --kill metadata too

               GIS_UTILS.TRANSFORM_TABLE(p_table_name,
                                         p_srid,
                                         p_column_name,
                                         p_depth + 1);

            END IF;

         ELSE

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql || ' using ' || TO_CHAR(p_srid));

         END IF;

      END;

      COMMIT;

   END TRANSFORM_TABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE SET_SRID (
      p_table_name      IN VARCHAR2,
      p_srid            IN NUMBER,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE'
   )
   AS

      --mschell! 20160330
      --this exists as a hack
      --using esri featureclass_tofeatureclass with our keyword setup
      --can sometimes result in NULL srids in the SDO
      --ESRI dont care, tracks all the info in the SDE internals

      psql              VARCHAR2(4000);
      dcision           VARCHAR2(1);

   BEGIN

      --if something else is going on, like some but not all are null
      --or there are populated srids and caller is confused
      --dont do anything

      psql := 'SELECT '
           || 'CASE '
           || '   WHEN aa.total = bb.nullsrid THEN ''Y'' '
           || '   ELSE ''N'' '
           || 'END '
           || 'FROM '
           || '(SELECT COUNT(*) total FROM ' || p_table_name || ' a) aa, '
           || '(SELECT COUNT(*) nullsrid FROM ' || p_table_name || ' a '
           || ' WHERE a.' || p_column_name || '.sdo_srid IS NULL) bb ';

      EXECUTE IMMEDIATE psql INTO dcision;

      IF dcision = 'Y'
      THEN

         psql := 'UPDATE ' || p_table_name || ' a '
              || 'SET a.' || p_column_name || '.sdo_srid = :p1 ';

         EXECUTE IMMEDIATE psql USING p_srid;
         COMMIT;

      END IF;

   END SET_SRID;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE INSERT_SDOGEOM_METADATA (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2,
      p_srid            IN NUMBER,
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_3d              IN VARCHAR2 DEFAULT 'N'
   )
   AS

    --Matt! DOB 3/08/10
    --20150707 added NYC srids
    --April 2016 added 3D, WGS84 and Web Mercator

    psql    VARCHAR2(4000);
    psql2   VARCHAR2(4000);


   BEGIN

      ----------------------------------------------------------------------------------
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      DBMS_APPLICATION_INFO.SET_ACTION('Step 10');
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO('INSERT_SDOGEOM_METADATA');
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      ----------------------------------------------------------------------------------

      IF p_srid = 41088
      OR p_srid = 2263
      THEN

         --NAD 1983 StatePlane New York Long Island FIPS 3104 Feet
         --aka EPSG 102718 http://epsg.io/102718

         psql := 'INSERT INTO user_sdo_geom_metadata a '
              || '(table_name, column_name, srid, diminfo) '
              || 'VALUES '
              || '(:p1,:p2,:p3, '
              || 'SDO_DIM_ARRAY ('
              || 'MDSYS.SDO_DIM_ELEMENT (''X'', 900000, 1090000, :p4), '
              || 'MDSYS.SDO_DIM_ELEMENT (''Y'', 110000, 295000, :p5)';

         IF UPPER(p_3d) = 'Y'
         THEN

            --according to planimetrics elevation feature class
            --max elevation in NYC is ~1,500 feet
            --min is ~ -16 feet
            --in other words, these values are naive and waiting to be updated by an expert
            psql := psql || ', '
                         || 'MDSYS.SDO_DIM_ELEMENT (''Z'', -100, 2000, ' || p_tolerance || ')';

         END IF;

         psql := psql || ' )) ';

      ELSIF (p_srid = 8265
         OR  p_srid = 4269
         OR  p_srid = 4326)
      AND UPPER(p_3d) = 'N'
      THEN

         --GEODETIC

         psql := 'INSERT INTO user_sdo_geom_metadata a '
              || '(a.table_name, a.column_name, a.srid, a.diminfo) '
              || 'VALUES '
              || '(:p1,:p2,:p3, '
              || 'SDO_DIM_ARRAY (SDO_DIM_ELEMENT (''Longitude'',-180,180,:p4), '
              || 'SDO_DIM_ELEMENT(''Latitude'',-90,90,:p5) ))';

      ELSIF p_srid = 3857
      AND UPPER(p_3d) = 'N'
      THEN

         --Web Mercator
         --Values are lifted directly from bounds on http://epsg.io/3857
         --THE WORLD IS OURS
         --units are meters so caller should not be passing in .0005 as tolerance

         psql := 'INSERT INTO user_sdo_geom_metadata a '
              || '(table_name, column_name, srid, diminfo) '
              || 'VALUES '
              || '(:p1,:p2,:p3, '
              || 'SDO_DIM_ARRAY ('
              || 'MDSYS.SDO_DIM_ELEMENT (''X'', -20026376.39, 20026376.39, :p4), '
              || 'MDSYS.SDO_DIM_ELEMENT (''Y'', -20048966.10, 20048966.10, :p5) ))';


      ELSIF p_srid IS NULL
      AND UPPER(p_3d) = 'N'
      THEN

         --special NULLed out geodetic to cartesian working coordinate system
         --same SQL as geodetic, but separated for obvitude

         psql := 'INSERT INTO user_sdo_geom_metadata a '
              || '(a.table_name, a.column_name, a.srid, a.diminfo) '
              || 'VALUES '
              || '(:p1,:p2,:p3, '
              || 'SDO_DIM_ARRAY (SDO_DIM_ELEMENT (''Longitude'',-180,180,:p4), '
              || 'SDO_DIM_ELEMENT(''Latitude'',-90,90,:p5) ))';


      ELSE

         RAISE_APPLICATION_ERROR(-20001,'Sorry, no one taught me what to do with srid '
                                     || p_srid || ' with 3D = ' || p_3d);

      END IF;

      BEGIN

         --dbms_output.put_line(psql);
         --dbms_output.put_line(p_table_name || ',' || p_column_name || ',' || p_srid ||
                              --',' || p_tolerance || ',' || p_tolerance);

         EXECUTE IMMEDIATE psql USING p_table_name,
                                      p_column_name,
                                      p_srid,
                                      p_tolerance,
                                      p_tolerance;

      EXCEPTION
      WHEN OTHERS
      THEN

         psql2 := 'DELETE FROM user_sdo_geom_metadata a '
               || 'WHERE a.table_name = :p1 '
               || 'AND a.column_name = :p2 ';

         EXECUTE IMMEDIATE psql2 USING p_table_name,
                                       p_column_name;

         EXECUTE IMMEDIATE psql USING p_table_name,
                                      p_column_name,
                                      p_srid,
                                      p_tolerance,
                                      p_tolerance;

      END;

   END INSERT_SDOGEOM_METADATA;

    ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE ADD_SPATIAL_INDEX (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2,
      p_srid            IN NUMBER,
      p_tolerance       IN NUMBER,
      p_local           IN VARCHAR2 DEFAULT NULL,
      p_parallel        IN NUMBER DEFAULT NULL,
      p_idx_name        IN VARCHAR2 DEFAULT NULL,
      p_3d              IN VARCHAR2 DEFAULT 'N',
      p_depth           IN PLS_INTEGER DEFAULT 1
   )
   AS

    --Matt! DOB 3/08/10

       psql          VARCHAR2(4000);
       psql2         VARCHAR2(4000);
       table_name    VARCHAR2(4000) := UPPER(p_table_name);
       column_name   VARCHAR2(4000) := UPPER(p_column_name);
       index_name    VARCHAR2(4000);
       v_3d          VARCHAR2(1) := UPPER(p_3d);

   BEGIN

      IF INSTR(p_table_name,'.') <> 0
      THEN

         RAISE_APPLICATION_ERROR(-20001,'Sorry database hero, I can''t '
                                     || 'index tables in remote schemas like ' || p_table_name);

      END IF;

      IF p_depth > 3
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Called recursively ' || p_depth || ' '
                                      || 'times attempting to index '
                                      || p_table_name);

      END IF;

      ----------------------------------------------------------------------------------
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      DBMS_APPLICATION_INFO.SET_ACTION('Step 10');
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO('ADD_SPATIAL_INDEX');
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      ----------------------------------------------------------------------------------

      --performs deletes if already existing
      GIS_UTILS.INSERT_SDOGEOM_METADATA(table_name,
                                        column_name,
                                        p_srid,
                                        p_tolerance,
                                        v_3d);

      IF p_idx_name IS NULL
      THEN
         index_name := p_table_name || 'SHAIDX';
      ELSE
         index_name := p_idx_name;
      END IF;

      IF length(index_name) > 30
      THEN
         index_name := substr(index_name,1,30);
      END IF;

      psql := 'CREATE INDEX '
           || index_name
           || ' ON ' || table_name || '(' || column_name || ')'
           || ' INDEXTYPE IS MDSYS.SPATIAL_INDEX ';

      --until something changes, we have no need for a true 3D spatial index
      --Adding this cuts off use of lots of non-3D supported operators.  Ex sdo_relate
      --ORA-13243: specified operator is not supported for 3- or higher-dimensional R-tree
      --IF UPPER(p_3d) = 'Y'
      --THEN

         --psql := psql || 'PARAMETERS (''sdo_indx_dims=3'') ';

      --END IF;

      IF p_local IS NOT NULL
      THEN
         psql := psql || 'LOCAL ';
      END IF;

      IF p_parallel IS NOT NULL
      THEN
         psql := psql || 'PARALLEL ' || TO_CHAR(p_parallel) || ' ';
      ELSE
         psql := psql || 'NOPARALLEL ';
      END IF;

      --unpublished oracle bug requires this parm
      --commenting since presumably fixed in 11g
      --psql := psql || 'PARAMETERS (''SDO_DML_BATCH_SIZE=1'') ';

      BEGIN

         --dbms_output.put_line(psql);
         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF SQLERRM LIKE '%layer SRID does not match geometry SRID%'
         THEN

            RAISE_APPLICATION_ERROR(-20001, 'Removed the ESRI hack. Got SQLERRM '
                                    || SQLERRM);

         ELSIF SQLERRM LIKE '%layer dimensionality does not match geometry dimensions%'
         AND v_3d = 'N'
         THEN

            --Most likely 3D data.  Send us a clue to create diff metadata
            v_3d := 'Y';

            --probably created but busted
            IF GIS_UTILS.SPATIAL_INDEX_EXISTS(table_name)
            THEN

               GIS_UTILS.DROP_SPATIAL_INDEX(table_name,
                                            column_name,
                                            'Y'); --kill metadata, we'll try again

            END IF;

         ELSE

            GIS_UTILS.DROP_SPATIAL_INDEX(table_name,
                                         column_name,
                                         'N'); --already killed and created metadata

         END IF;

         GIS_UTILS.ADD_SPATIAL_INDEX(table_name,
                                     column_name,
                                     p_srid,
                                     p_tolerance,
                                     p_local,
                                     p_parallel,
                                     p_idx_name,
                                     v_3d,
                                     (p_depth + 1));

      END;

   END ADD_SPATIAL_INDEX;

   -----------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   -----------------------------------------------------------------------------------------

   PROCEDURE DROP_SPATIAL_INDEX (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE',
      p_metadata        IN VARCHAR2 DEFAULT 'Y'
   )
   AS

      --mschell! 20160330
      --typically not called directly, call add_spatial_index
      --  which calls this if necessary
      --make user sdo metadata deletion transparently handled

      psql          VARCHAR2(4000);
      sidx_name     VARCHAR2(32);

   BEGIN

      IF UPPER(p_metadata) = 'Y'
      THEN

         --may delete nothing, tis fine
         psql := 'DELETE FROM user_sdo_geom_metadata a '
              || 'WHERE '
              || 'a.table_name = :p1 AND '
              || 'a.column_name = :p2 ';

         EXECUTE IMMEDIATE psql USING UPPER(p_table_name),
                                      UPPER(p_column_name);

         COMMIT;

      END IF;

      psql := 'SELECT u.index_name '
           || 'FROM user_indexes u '
           || 'WHERE '
           || 'u.table_name = :p1 AND '
           || 'u.index_type = :p2';

      BEGIN

         EXECUTE IMMEDIATE psql INTO sidx_name USING UPPER(p_table_name),
                                                     'DOMAIN';

      EXCEPTION
      WHEN OTHERS
      THEN

          RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql || ' USING '
                               || UPPER(p_table_name) || ',' || UPPER(p_column_name)
                               || ',' || 'DOMAIN');

      END;

      psql := 'DROP INDEX ' || sidx_name;

      BEGIN

         EXECUTE IMMEDIATE psql;

      EXCEPTION
      WHEN OTHERS
      THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

      END;

   END DROP_SPATIAL_INDEX;

   -----------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   -----------------------------------------------------------------------------------------

   PROCEDURE ADD_INDEX (
      p_table_name      IN VARCHAR2,
      p_index_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2,
      p_type            IN VARCHAR2 DEFAULT NULL,
      p_parallel        IN NUMBER DEFAULT NULL,
      p_logging         IN VARCHAR2 DEFAULT NULL,
      p_local           IN VARCHAR2 DEFAULT NULL
   )
   AS

      --mschell! 20151016

      psql          VARCHAR2(4000);
      psql2         VARCHAR2(4000);
      table_name    VARCHAR2(4000) := UPPER(p_table_name);
      column_name   VARCHAR2(4000) := UPPER(p_column_name);

   BEGIN

      IF INSTR(p_table_name,'.') <> 0
      THEN

         RAISE_APPLICATION_ERROR(-20001,'Sorry database hero, I can''t index tables in remote schemas like ' || p_table_name);

      END IF;

      ----------------------------------------------------------------------------------
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      DBMS_APPLICATION_INFO.SET_ACTION('Step 10');
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO('ADD_INDEX');
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
      ----------------------------------------------------------------------------------

      psql := 'CREATE ';

      IF p_type IS NOT NULL
      THEN
         psql := psql || UPPER(p_type) || ' ';
      END IF;

      psql := psql || 'INDEX '
                   || p_index_name
                   || ' ON ' || table_name || '(' || column_name || ') ';

      IF p_parallel IS NOT NULL
      THEN
         psql := psql || 'PARALLEL ' || TO_CHAR(p_parallel) || ' ';
      ELSE
         psql := psql || 'NOPARALLEL ';
      END IF;

      IF p_logging IS NOT NULL
      THEN
         psql := psql || 'LOGGING ';
      ELSE
         psql := psql || 'NOLOGGING ';
      END IF;

      IF p_local IS NOT NULL
      THEN
         psql := psql || 'LOCAL ';
      END IF;

      BEGIN

         --dbms_output.put_line(psql);
         EXECUTE IMMEDIATE psql;

      EXCEPTION
         WHEN OTHERS
         THEN

         psql2 := 'DROP INDEX ' || p_index_name;
         EXECUTE IMMEDIATE psql2;

         EXECUTE IMMEDIATE psql;

      END;


   END ADD_INDEX;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE GATHER_TABLE_STATS (
      p_table_name      IN VARCHAR2
   )
   AS

   --MSCHELL! 20151016
   --Any new advice on these mystery parameters welcome
   --Added option 2 for topo tables 10/12/11 !
   --see related GATHER_TOPO_STATS below


   BEGIN


      IF UPPER(p_table_name) NOT LIKE '%$'
      THEN

         --standard tables
         --this is the version Matt tweaked out over time for CAMPS tables, histograms being the main problem

         DBMS_STATS.GATHER_TABLE_STATS(ownname => USER,
                                       tabname => p_table_name,
                                       granularity => 'AUTO',                 --Oracle determine what partition-level stats to get (default)
                                       degree => 1,                           --no parallelism on gather
                                       cascade => DBMS_STATS.AUTO_CASCADE, --Oracle determine whether stats on idxs too
                                       method_opt => 'FOR ALL COLUMNS SIZE 1' --This prevents histograms
                                       );

      ELSE

         --topo primitives and relation$ table

         DBMS_STATS.GATHER_TABLE_STATS(ownname => USER,
                                          tabname => p_table_name,
                                          degree => 1,              --no parallelism on gather, changed from SK 16
                                          cascade => TRUE,          --yes, always gather stats on idxs too
                                          estimate_percent=>20      --20 percent sample
                                          );

      END IF;


   END GATHER_TABLE_STATS;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   PROCEDURE SET_APPLICATION_INFO (
      p_action             IN VARCHAR2,
      p_client_info        IN VARCHAR2,
      p_module             IN VARCHAR2 DEFAULT NULL
   )
   AS

      --mschell! 20160721
      --called from dbutils.py OracleDdlManager class or from pl/sql
      --Module, action, and client info are a hierarchy
      --module: High level function that is being performed. Set this from control code 1x
      --   action: A major step running within the application
      --      info: Any additional bits of info piped out from the step

      --after calling this the inputs will be in v$session and v$sqlarea,
      --but most doitt schemas dont have select privileges
      --see instead SYSTEM view V_DOITT_USER_SES_STATUS

      --select status, db_user, client_user, action, client, module
      --from system.V_DOITT_USER_SES_STATUS
      --where db_user = USER
      --and status = 'ACTIVE'

      --SOP example
      --from script kicking off work: SET_APPLICATION_INFO(NULL,NULL,'My processing script')
      --...
      --some internal module to dissolve
      --SET_APPLICATION_INFO('Dissolve','Start')
      --SET_APPLICATION_INFO('Dissolve','Processed 10000 recs')
      --SET_APPLICATION_INFO(NULL,'Complete')


   BEGIN

      --comment to code ratio high score

      IF p_module IS NOT NULL
      THEN

         DBMS_APPLICATION_INFO.SET_MODULE(p_module,
                                          p_action);

      ELSE

         DBMS_APPLICATION_INFO.SET_ACTION(p_action);

      END IF;

      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(p_client_info);

   END SET_APPLICATION_INFO;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   PROCEDURE ESCAPE_CHAR_REFERENCES (
      p_table_name      IN VARCHAR2,
      p_cs_name         IN VARCHAR2 DEFAULT 'US7ASCII'
   )
   AS

      --mschell! 20160422
      --For tables headed to webmap applications special chars
      --  like "e-acute" and "n-tilde" cause a mess.
      --Dont know where in the stack this happens.
      --Reserved html chars like "ampersand" and "less-than" seem to
      --  be OK but we can replace them anyway to be safe.
      --edit: except for <br> which we make a special case to allow
      --Default characterset replacement US7ASCII is the Oracle
      --  word for ascii and is conservative.
      -- Meaning for ex. e-acute will turn into a sad americanized "e".
      --    "Freedom Press Coffee Cafe"

      --Use care not to re-run this procedure on text that has already
      --   been escaped.  Many of the escaped outputs contain chars like
      --   ampersand which will then be double-escaped

      psql           VARCHAR2(8000);
      colz           GIS_UTILS.stringarray;

   BEGIN

      psql := 'SELECT a.column_name '
           || 'FROM user_tab_cols a '
           || 'WHERE '
           || 'a.table_name = :p1 AND '
           || 'a.data_type LIKE :p2';

      EXECUTE IMMEDIATE psql BULK COLLECT INTO colz USING UPPER(p_table_name),
                                                          '%' || 'CHAR' || '%';

      IF colz.COUNT > 0
      THEN

         psql := 'UPDATE ' || p_table_name || ' a '
              || 'SET ';

         FOR i IN 1 .. colz.COUNT
         LOOP

            psql := psql || 'a.' || colz(i)
                         || ' = REPLACE(UTL_I18N.ESCAPE_REFERENCE(REPLACE(a.' || colz(i) || ',''<br>'',''M8id3n''),'''
                                                                 || p_cs_name || '''),''M8id3n'',''<br>'')';

            IF i <> colz.COUNT
            THEN

               psql := psql || ',';

            END IF;

         END LOOP;

         dbms_output.put_line(psql);

         BEGIN

            EXECUTE IMMEDIATE psql;
            COMMIT;

         EXCEPTION
         WHEN OTHERS
         THEN

            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

         END;

      END IF;

   END ESCAPE_CHAR_REFERENCES;
   

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------
   
   FUNCTION PROPERCASE (
      p_text            IN VARCHAR2,
      p_style           IN VARCHAR2 DEFAULT 'CENTERLINE'
   ) RETURN VARCHAR2 DETERMINISTIC
   AS
   
      --mschell! 20161004
      
      temp_output       GIS_UTILS.stringarray;
      replace_hash      GIS_UTILS.stringhash32;
      output            VARCHAR2(4000);   
      
      FUNCTION CENTERLINE_PROPERCASE 
      RETURN GIS_UTILS.stringhash32
      IS         
         output         GIS_UTILS.stringhash32;         
      BEGIN
         output('Bqe') := 'BQE';
         output('Eb') := 'EB';
         output('Lirr') := 'LIRR';
         output('Nb') := 'NB';
         output('Ne') := 'NE';
         output('Nw') := 'NW';
         output('Sb') := 'SB';
         output('Se') := 'SE';
         output('Sw') := 'SW';
         output('Wb') := 'WB';
         --
         RETURN output; 
      END CENTERLINE_PROPERCASE;
   
   BEGIN
   
      temp_output := GIS_UTILS.SPLIT(INITCAP(p_text), ' ');
      
      IF p_style = 'CENTERLINE'
      THEN
      
         PRAGMA INLINE(CENTERLINE_PROPERCASE, 'YES');
         replace_hash := CENTERLINE_PROPERCASE;
         
         FOR i IN 1 .. temp_output.COUNT
         LOOP
      
            IF replace_hash.EXISTS(temp_output(i))
            THEN
            
               output := output || replace_hash(temp_output(i));
            
            ELSE
            
               output := output || temp_output(i);
            
            END IF;
            
            IF i <> temp_output.COUNT
            THEN
            
               output := output || ' ';
            
            END IF;
            
         END LOOP;
      
      ELSE
      
         raise_application_error(-20001, 'Unknown style ' || p_style);
         
      END IF;    
      
      RETURN output;
   
   END PROPERCASE;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   FUNCTION DUMP_SDO_SUBELEMENTS (
      geom      IN SDO_GEOMETRY,
      indent    IN VARCHAR2 DEFAULT '',
      concise   IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB
   AS
      output    CLOB;
      linefeed  VARCHAR2(1);

   BEGIN

      IF concise = 'N'
      THEN

         linefeed := Chr(10);

      ELSE

         linefeed := '';

      END IF;

      IF geom.SDO_GTYPE = 2004
      OR geom.SDO_GTYPE = 2006
      OR geom.SDO_GTYPE = 2007
      THEN

         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(geom)
         LOOP
            IF output IS NULL
            THEN
               output := DUMP_SDO(MDSYS.SDO_UTIL.EXTRACT(geom,i),indent);
            ELSE
               output := output || linefeed || DUMP_SDO(MDSYS.SDO_UTIL.EXTRACT(geom,i),indent);
            END IF;
         END LOOP;

         RETURN output;

      ELSE

         RETURN DUMP_SDO(geom,indent);

      END IF;

   END DUMP_SDO_SUBELEMENTS;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   FUNCTION DUMP_SDO_SRID (
      srid          IN NUMBER,
      indent        IN VARCHAR2 DEFAULT ''
   ) RETURN VARCHAR2

   AS

   BEGIN

      IF srid IS NULL
      THEN

         RETURN 'NULL';

      ELSE

         RETURN TO_CHAR(srid);

      END IF;


   END DUMP_SDO_SRID;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   FUNCTION DUMP_SDO (
      geom      IN SDO_GEOMETRY,
      indent    IN VARCHAR2 DEFAULT '',
      concise   IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB
   AS
      output    CLOB := '';
      linefeed  VARCHAR2(1);
      spacing   VARCHAR2(4);

      --Main entry point for dumping oracle sdo_geometry to text

   BEGIN

      IF concise = 'N'
      THEN

         linefeed := Chr(10);
         spacing := '   ';

      ELSE

         linefeed := '';
         spacing := ' ';

      END IF;

      output := indent || 'MDSYS.SDO_GEOMETRY' || linefeed
             || indent || '('            || linefeed
             || indent || spacing || TO_CHAR(geom.SDO_GTYPE) || ',' || linefeed
             || indent || spacing || dump_sdo_srid(geom.SDO_SRID,indent)  || ',' || linefeed
             || indent ||       dump_sdo_point(geom.SDO_POINT,indent,concise)    || ',' || linefeed
             || indent ||       dump_sdo_elem(geom.SDO_ELEM_INFO,indent,concise) || ',' || linefeed
             || indent ||       dump_sdo_ords(geom.SDO_ORDINATES,indent,concise) || linefeed
             || indent || ')' || linefeed;

      RETURN output;

   END DUMP_SDO;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------


   FUNCTION DUMP_SDO_POINT (
      geom          IN SDO_POINT_TYPE,
      indent        IN VARCHAR2 DEFAULT '',
      concise       IN VARCHAR2 DEFAULT 'N'
   ) RETURN VARCHAR2

   AS
      output VARCHAR2(4000) := '';
      X VARCHAR2(64);
      Y VARCHAR2(64);
      Z VARCHAR2(64);
      linefeed  VARCHAR2(1);
      spacing   VARCHAR2(4);

   BEGIN

      IF concise = 'N'
      THEN

         linefeed := Chr(10);
         spacing := '   ';

      ELSE

         linefeed := '';
         spacing := ' ';

      END IF;

      IF geom IS NULL
      THEN
         RETURN indent || spacing || 'NULL';
      END IF;

      IF geom.X IS NULL
      THEN
         X := 'NULL';
      ELSE
         X := TO_CHAR(geom.X);
      END IF;

      IF geom.Y IS NULL
      THEN
         Y := 'NULL';
      ELSE
         Y := TO_CHAR(geom.Y);
      END IF;

      IF geom.Z IS NULL
      THEN
         Z := 'NULL';
      ELSE
         Z := TO_CHAR(geom.Z);
      END IF;

      output := indent || spacing || 'MDSYS.SDO_POINT_TYPE'    || linefeed
             || indent || spacing || '(' || linefeed
             || indent || spacing || spacing || X  || ',' || linefeed
             || indent || spacing || spacing || Y  || ',' || linefeed
             || indent || spacing || spacing || Z  || linefeed
             || indent || spacing || ')';

      RETURN output;

   END DUMP_SDO_POINT;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   FUNCTION DUMP_SDO_ELEM (
      geom          IN SDO_ELEM_INFO_ARRAY,
      indent        IN VARCHAR2 DEFAULT '',
      concise       IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB

   AS
      output CLOB := '';
      linefeed  VARCHAR2(1);
      spacing   VARCHAR2(4);

   BEGIN

      IF concise = 'N'
      THEN

         linefeed := Chr(10);
         spacing := '   ';

      ELSE

         linefeed := '';
         spacing := ' ';

      END IF;

      IF geom IS NULL
      THEN
         RETURN indent || spacing || 'NULL';
      END IF;

      output := indent || spacing || 'MDSYS.SDO_ELEM_INFO_ARRAY' || linefeed
             || indent || spacing || '('                   || linefeed;

      FOR i IN geom.FIRST .. geom.LAST
      LOOP
         output := output || indent || spacing || spacing || TO_CHAR(geom(i));
         IF i != geom.LAST
         THEN
            output := output || indent || ',' || linefeed;
         END IF;
      END LOOP;

      RETURN output || linefeed || indent || '   )';

   END DUMP_SDO_ELEM;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ---------------------------------------------------------------------------------

   FUNCTION DUMP_SDO_ORDS (
      geom          IN SDO_ORDINATE_ARRAY,
      indent        IN VARCHAR2 DEFAULT '',
      concise       IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB

   AS
      output       CLOB := '';
      linefeed     VARCHAR2(1);
      spacing      VARCHAR2(4);
      cloblength   NUMBER;

   BEGIN

      IF concise = 'N'
      THEN

         linefeed := Chr(10);
         spacing := '   ';

      ELSE

         linefeed := '';
         spacing := ' ';

      END IF;

      IF geom IS NULL
      THEN
         RETURN indent || spacing || 'NULL';
      END IF;

      output := indent || spacing || 'MDSYS.SDO_ORDINATE_ARRAY' || linefeed
             || indent || spacing || '('                  || linefeed;

      IF concise <> 'N'
      THEN

         cloblength := LENGTH(output);

      END IF;

      FOR i IN geom.FIRST .. geom.LAST
      LOOP

         output := output || indent || spacing || spacing || TO_CHAR(geom(i));

         IF i != geom.LAST
         THEN

            output := output || indent || ',' || linefeed;

             IF concise <> 'N'
             THEN

                cloblength := cloblength +
                              LENGTH(indent || spacing || spacing || TO_CHAR(geom(i)));

                IF cloblength > 2000
                THEN

                   --line breaks at 2000 to avoid hitting SQLPlus 2500 limit
                   output := output || CHR(10);
                   cloblength := 0;

                END IF;

             END IF;

         END IF;

      END LOOP;

      RETURN output || linefeed || indent || spacing || ')';

   END DUMP_SDO_ORDS;

   -----------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   -----------------------------------------------------------------------------------------

   FUNCTION ORDINATE_ROUNDER (
      p_geometry               IN SDO_GEOMETRY,
      p_places                 IN PLS_INTEGER DEFAULT 6
   ) RETURN SDO_GEOMETRY DETERMINISTIC

   AS


     geom          SDO_GEOMETRY;
     ordinates     SDO_ORDINATE_ARRAY;


   BEGIN

      IF p_geometry.sdo_gtype = 2001
      THEN

         geom := p_geometry;
         geom.sdo_point.X := ROUND(p_geometry.sdo_point.X,p_places);
         geom.sdo_point.Y := ROUND(p_geometry.sdo_point.Y,p_places);

      ELSIF (p_geometry.sdo_gtype = 2002)
      OR (p_geometry.sdo_gtype = 2003)
      OR (p_geometry.sdo_gtype = 2007)
      THEN

         ordinates := p_geometry.SDO_ORDINATES;

         FOR i in 1 .. ordinates.COUNT
         LOOP

            ordinates(i) := ROUND(ordinates(i),p_places);

         END LOOP;

         geom := p_geometry;
         geom.sdo_ordinates := ordinates;

      ELSE

          RAISE_APPLICATION_ERROR(-20001,'Dude, I have no idea what to do with a ' ||p_geometry.sdo_gtype );

      END IF;

      RETURN geom;

   END ORDINATE_ROUNDER;
   
   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Private------------------------------------------------------------------------
   
   FUNCTION devolve_point(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      IF p_input.get_gtype() IN (3,7)
      AND p_geom_devolve = 'ACCURATE'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_CENTROID(
             p_input
            ,p_tolerance
         );
         
      ELSIF p_input.get_gtype() IN (3,7)
      AND p_geom_devolve = 'FAST'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_POINTONSURFACE(
             p_input
            ,p_tolerance
         );
         
      ELSIF p_input.get_gtype() IN (2,4,5,6)
      AND p_geom_devolve = 'ACCURATE'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_CENTROID(
             MDSYS.SDO_GEOM.SDO_MBR(p_input)
            ,p_tolerance
         );
         
         IF sdo_output IS NULL
         THEN
             sdo_output := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    p_input.SDO_ORDINATES(1)
                   ,p_input.SDO_ORDINATES(2)
                   ,NULL
                )
               ,NULL
               ,NULL
            );
            
         END IF;
      
      ELSIF p_input.get_gtype() IN (2,4,5,6)
      AND p_geom_devolve = 'FAST'
      THEN
         sdo_output := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 p_input.SDO_ORDINATES(1)
                ,p_input.SDO_ORDINATES(2)
                ,NULL
             )
            ,NULL
            ,NULL
         );
         
      ELSIF p_input.get_gtype() = 1
      THEN
         IF p_input.SDO_POINT IS NULL
         THEN
            sdo_output := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    p_input.SDO_ORDINATES(1)
                   ,p_input.SDO_ORDINATES(2)
                   ,NULL
                )
               ,NULL
               ,NULL
            );
         
         ELSE
            sdo_output := p_input;
            
         END IF;
      
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
      RETURN sdo_output;
   
   END devolve_point;
   
    -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Function by Simon Greener
   -- http://www.spatialdbadvisor.com/oracle_spatial_tips_tricks/138/spatial-sorting-of-data-via-morton-key
   FUNCTION morton(
       p_column           IN  NATURAL
      ,p_row              IN  NATURAL
   ) RETURN INTEGER DETERMINISTIC
   AS
      v_row       NATURAL := ABS(p_row);
      v_col       NATURAL := ABS(p_column);
      v_key       NATURAL := 0;
      v_level     BINARY_INTEGER := 0;
      v_left_bit  BINARY_INTEGER;
      v_right_bit BINARY_INTEGER;
      v_quadrant  BINARY_INTEGER;
    
      FUNCTION left_shift(
          p_val   IN  NATURAL
         ,p_shift IN  NATURAL
      ) RETURN PLS_INTEGER
      AS
      BEGIN
         RETURN TRUNC(p_val * POWER(2,p_shift));
      
      END left_shift;
       
   BEGIN
      WHILE v_row > 0 OR v_col > 0 
      LOOP
         /*   split off the row (left_bit) and column (right_bit) bits and
              then combine them to form a bit-pair representing the
              quadrant                                                  */
         v_left_bit  := MOD(v_row,2);
         v_right_bit := MOD(v_col,2);
         v_quadrant  := v_right_bit + (2 * v_left_bit);
         v_key       := v_key + left_shift(v_quadrant,( 2 * v_level));
         /*   row, column, and level are then modified before the loop
              continues                                                */
         v_row := TRUNC(v_row / 2);
         v_col := TRUNC(v_col / 2);
         v_level := v_level + 1;
        
      END LOOP;
      
      RETURN v_key;
   
   END morton;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   --function by Paul Dziemiela
   --https://github.com/pauldzy/DZ_SDO/blob/master/Packages/DZ_SDO_CLUSTER.pkb
   FUNCTION morton_key(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_x_offset         IN  NUMBER
      ,p_y_offset         IN  NUMBER
      ,p_x_divisor        IN  NUMBER
      ,p_y_divisor        IN  NUMBER
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN INTEGER DETERMINISTIC
   AS
      sdo_input        MDSYS.SDO_GEOMETRY := p_input;
      str_geom_devolve VARCHAR2(4000 Char) := UPPER(p_geom_devolve);
      num_tolerance    NUMBER := p_tolerance;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_geom_devolve IS NULL
      OR str_geom_devolve NOT IN ('ACCURATE','FAST')
      THEN
         str_geom_devolve := 'ACCURATE';
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Devolve the input geometry to a point
      --------------------------------------------------------------------------
      sdo_input := devolve_point(
          p_input        => sdo_input
         ,p_geom_devolve => str_geom_devolve
         ,p_tolerance    => num_tolerance
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return the Morton key
      --------------------------------------------------------------------------
      RETURN morton(
          FLOOR((sdo_input.SDO_POINT.y + p_y_offset ) / p_y_divisor )
         ,FLOOR((sdo_input.SDO_POINT.x + p_x_offset ) / p_x_divisor )
      );
   
   END morton_key;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION VALIDATE_GEOMETRY (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_tolerance               IN NUMBER
   ) RETURN BOOLEAN
   AS

      --mschell 20160107
      psql           VARCHAR2(4000);
      kount          PLS_INTEGER;

   BEGIN

      psql := 'SELECT COUNT(*) '
           || 'FROM ' || p_table_name || ' a '
           || 'WHERE '
           || 'sdo_geom.validate_geometry_with_context(a.' || p_column || ',:p1) NOT IN (:p2,:p3)';

      EXECUTE IMMEDIATE psql INTO kount USING p_tolerance,
                                              'TRUE',
                                              '54668'; --ORA-54668:  2D SRID cannot be used with a 3D geometry
                                                       --we carry around unusable Z values for some fcs
      IF kount > 0
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;

   END VALIDATE_GEOMETRY;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   PROCEDURE ASSERT_VALID_GEOM (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_tolerance               IN NUMBER
   )
   AS

      --mschell! 20160107

   BEGIN

      IF NOT VALIDATE_GEOMETRY(p_table_name,
                               p_column,
                               p_tolerance)
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Table ' || p_table_name || ' geom isnt valid');

      END IF;


   END ASSERT_VALID_GEOM;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION FIX_A_INVALID_GEOM (
      p_sdo                     IN MDSYS.SDO_GEOMETRY,
      p_tolerance               IN NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY
   AS

      --mschell! 20160601
      --will attempt some fairly tame rectifications
      --add more as needed
      --does not guarantee a fix.  Intentionally returns
      --the input unchanged when obvious fixes dont work

      p_out          MDSYS.SDO_GEOMETRY;
      msg            VARCHAR2(4000);

   BEGIN

      msg := sdo_geom.validate_geometry_with_context(p_sdo,
                                                     p_tolerance);

      IF msg = 'TRUE'
      THEN

         RETURN p_sdo;

      END IF;

      IF msg LIKE '13356%'
      OR msg LIKE '13349%'
      THEN

         --option 1, rectify for simple dupes and self-intersections

         p_out := mdsys.sdo_util.rectify_geometry(p_sdo,
                                            p_tolerance);

         msg := sdo_geom.validate_geometry_with_context(p_out,
                                                        p_tolerance);

      END IF;

      --consider self-union and additional flailing here
      --depending on what typically turns up around here

      IF msg = 'TRUE'
      AND p_out.get_gtype() = p_sdo.get_gtype() --dont allow degeneration
      AND p_out IS NOT NULL
      THEN

         RETURN p_out;

      ELSE

         --We lost. Caller must check again and decide what to do
         RETURN p_sdo;

      END IF;

   END FIX_A_INVALID_GEOM;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   PROCEDURE FIX_INVALID_GEOM (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2 DEFAULT 'SHAPE',
      p_tolerance               IN NUMBER DEFAULT .0005,
      p_where_clause            IN VARCHAR2 DEFAULT NULL
   )
   AS

      --mschell! 20160601
      --table wrapper to FIX_A_INVALID_GEOM

      psql           VARCHAR2(4000);

   BEGIN

      psql := 'UPDATE ' || p_table_name || ' a '
           || 'SET '
           || 'a.' || p_column || ' = GIS_UTILS.FIX_A_INVALID_GEOM(' || p_column || ', :p1) '
           || 'WHERE '
           || 'SDO_GEOM.validate_geometry_with_context(a.shape, :p2) <> :p3 ';

      IF p_where_clause IS NOT NULL
      THEN

         psql := psql || 'AND ' || p_where_clause;

      END IF;

      EXECUTE IMMEDIATE psql USING p_tolerance,
                                   p_tolerance,
                                   'TRUE';

      COMMIT;

   END FIX_INVALID_GEOM;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION HAS_CURVES (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2
   ) RETURN BOOLEAN
   AS

      --mschell 20160310

      psql           VARCHAR2(4000);
      kount          PLS_INTEGER;

   BEGIN

      psql := 'SELECT COUNT(*) FROM '
           || '(SELECT '
           || 'DECODE(MOD(ROWNUM, 3), 2, t.COLUMN_VALUE, NULL) etype, '
           || 'DECODE(MOD(ROWNUM, 3), 0, t.COLUMN_VALUE, NULL) interpretation '
           || 'FROM '
           || p_table_name || ' a, '
           || 'TABLE(a.' || p_column || '.sdo_elem_info) t) aa '
           || 'WHERE aa.etype IN (:p1, :p2) OR '
           || 'aa.interpretation IN (:p3 , :p4)';

      EXECUTE IMMEDIATE psql INTO kount USING 1005, 2005,
                                              2,4;

      IF kount > 0
      THEN

         RETURN TRUE;

      ELSE

         RETURN FALSE;

      END IF;

   END HAS_CURVES;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   PROCEDURE REMOVE_CURVES (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2 DEFAULT 'SHAPE',
      p_pkc_column              IN VARCHAR2 DEFAULT 'OBJECTID',
      p_arc_tolerance           IN NUMBER DEFAULT .25,
      p_unit                    IN VARCHAR2 DEFAULT 'FOOT',
      p_tolerance               IN NUMBER DEFAULT .0005
   )
   AS

      --mschell 20160331
      --partial dupe of sql here and in has_curves below has got. ta. go.

      psql           VARCHAR2(4000);
      idz            MDSYS.SDO_LIST_TYPE := MDSYS.SDO_LIST_TYPE();

   BEGIN

      psql := 'SELECT DISTINCT ' || p_pkc_column || ' FROM ( '
           || 'SELECT a.' || p_pkc_column || ', '
           || 'DECODE (MOD (ROWNUM, 3), 2, t.COLUMN_VALUE, NULL) etype, '
           || 'DECODE (MOD (ROWNUM, 3), 0, t.COLUMN_VALUE, NULL) interpretation '
           || 'FROM '
           || p_table_name || ' a, '
           || 'TABLE(a.' || p_column || '.sdo_elem_info) t) '
           || 'WHERE etype IN (:p1, :p2) OR interpretation IN (:p3,:p4) ';

      EXECUTE IMMEDIATE psql BULK COLLECT INTO idz USING 1005, 2005,
                                                         2,4;

      IF idz.COUNT > 0
      THEN

         psql := 'UPDATE ' || p_table_name || ' a '
              || 'SET '
              || 'a.' || p_column || ' = sdo_geom.sdo_arc_densify(a.shape, :p1, :p2) '
              || 'WHERE a.' || p_pkc_column || ' IN (SELECT * FROM TABLE(:p3))';

         EXECUTE IMMEDIATE psql USING p_tolerance,
                                      'arc_tolerance=' || TO_CHAR(p_arc_tolerance) || ' unit=' || p_unit,
                                      idz;

         COMMIT;

      END IF;

   END REMOVE_CURVES;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION VALIDATE_SHAPETYPE (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_shapetype               IN VARCHAR2
   ) RETURN BOOLEAN
   AS

      --mschell 20160310
      --p_shapetype uses OGC simple features spec words
      --will translate to oracle gtypes

      psql           VARCHAR2(4000);
      kount          PLS_INTEGER;

      TYPE shapehash IS TABLE OF NUMBER
      INDEX BY VARCHAR2(32);
      shapetypes shapehash;

      FUNCTION get_shaptypes RETURN shapehash IS
      BEGIN
         shapetypes('POINT')        := 1;
         shapetypes('LINE')         := 2;
         shapetypes('CURVE')        := 2;
         shapetypes('POLYGON')      := 3;
         shapetypes('SURFACE')      := 3;
         shapetypes('COLLECTION')   := 4;
         shapetypes('MULTIPOINT')   := 5;
         shapetypes('MULTILINE')    := 6;
         shapetypes('MULTICURVE')   := 6;
         shapetypes('MULTIPOLYGON') := 7;
         shapetypes('MULTISURFACE') := 7;
         shapetypes('SOLID')        := 8;
         shapetypes('MULTISOLID')   := 9;
         RETURN shapetypes;
      END;

   BEGIN

      shapetypes := get_shaptypes();

      IF UPPER(p_shapetype) NOT IN ('COLLECTION','MULTIPOLYGON','MULTILINE')
      THEN

         --mostly points, lines, polygons
         --for the other weirdos be strict until I actually see one

         psql := 'SELECT COUNT(*) '
              || 'FROM ' || p_table_name || ' a '
              || 'WHERE '
              || 'a.' || p_column || '.get_gtype() <> :p1';
              
         IF UPPER(p_shapetype) = 'POLYGON'
         THEN
         
            --ESRI loads single outer ring polys with inner rings as 2007s
            --this will avoid false positives
            psql := psql || ' AND SDO_UTIL.GETNUMELEM(a.shape) <> 1';
         
         END IF;

         EXECUTE IMMEDIATE psql INTO kount USING shapetypes(UPPER(p_shapetype));

      ELSIF UPPER(p_shapetype) = 'COLLECTION'
      THEN

         psql := 'SELECT COUNT(*) '
              || 'FROM ' || p_table_name || ' a '
              || 'WHERE '
              || 'a.' || p_column || '.get_gtype() > :p1';

         EXECUTE IMMEDIATE psql INTO kount USING shapetypes(UPPER(p_shapetype));

      ELSIF UPPER(p_shapetype) = 'MULTIPOLYGON'
      THEN

         psql := 'SELECT COUNT(*) '
              || 'FROM ' || p_table_name || ' a '
              || 'WHERE '
              || 'a.' || p_column || '.get_gtype() NOT IN (:p1,:p2)';

         EXECUTE IMMEDIATE psql INTO kount USING shapetypes(UPPER(p_shapetype)),
                                                 shapetypes(UPPER('POLYGON'));

      ELSIF UPPER(p_shapetype) = 'MULTILINE'
      THEN

         psql := 'SELECT COUNT(*) '
              || 'FROM ' || p_table_name || ' a '
              || 'WHERE '
              || 'a.' || p_column || '.get_gtype() NOT IN (:p1,:p2)';

         EXECUTE IMMEDIATE psql INTO kount USING shapetypes(UPPER(p_shapetype)),
                                                 shapetypes(UPPER('LINE'));

      ELSE

         RAISE_APPLICATION_ERROR(-20001, 'Unknown shapetype ' || p_shapetype);

      END IF;

      IF kount > 0
      THEN
         RETURN FALSE;
      END IF;

      IF UPPER(p_shapetype) NOT IN ('CURVE','MULTICURVE')
      THEN

          IF GIS_UTILS.HAS_CURVES(p_table_name,
                                  p_column)
          THEN

             RETURN FALSE;

          END IF;

      END IF;

      RETURN TRUE;

   END VALIDATE_SHAPETYPE;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   PROCEDURE ASSERT_VALID_SHAPETYPE (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_shapetype               IN VARCHAR2
   )
   AS

      --mschell! 20160310

   BEGIN

      IF NOT GIS_UTILS.VALIDATE_SHAPETYPE(p_table_name,
                                          p_column,
                                          p_shapetype)
      THEN

         --dont change sqlerrm, callers parse it
         RAISE_APPLICATION_ERROR(-20001, 'Table ' || p_table_name || ' shape type isnt valid');

      END IF;

   END ASSERT_VALID_SHAPETYPE;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION VALIDATE_OBJECT (
      p_object_name              IN VARCHAR2
   ) RETURN BOOLEAN
   AS

      --mschell! 20160523
      psql           VARCHAR2(4000);
      kount          PLS_INTEGER;

   BEGIN

      psql := 'SELECT COUNT(*) '
           || 'FROM user_objects a '
           || 'WHERE '
           || 'a.object_name = :p1 AND '
           || 'a.status = :p2';

      EXECUTE IMMEDIATE psql INTO kount USING UPPER(p_object_name),
                                              'VALID';

      IF kount = 1
      THEN

         RETURN TRUE;

      ELSE

         RETURN FALSE;

      END IF;

   END VALIDATE_OBJECT;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   PROCEDURE ASSERT_VALID_OBJECT (
      p_object_name             IN VARCHAR2
   )
   AS

      --mschell! 20160523

   BEGIN

      IF NOT GIS_UTILS.VALIDATE_OBJECT(p_object_name)
      THEN

         --dont change message, parsed by dbutils.py
         RAISE_APPLICATION_ERROR(-20001, 'Object ' || p_object_name || ' isnt valid');

      END IF;

   END ASSERT_VALID_OBJECT;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION VALIDATE_LINES_WITH_CONTEXT (
      p_line                  IN SDO_GEOMETRY,
      p_tolerance             IN NUMBER DEFAULT .05,
      p_which_check           IN VARCHAR2 DEFAULT 'BOTH'
   ) RETURN VARCHAR2
   AS

      --Matt! DOB 1/26/11

      --sample usage
      --select e.edge_id, gis_utils.validate_lines_with_context(e.geometry, .05)
      --from z955ls_edge$ e
      --where gis_utils.validate_lines_with_context(e.geometry, .05) != 'TRUE'


      psql              VARCHAR2(4000);
      kount             PLS_INTEGER;


   BEGIN

      IF p_line IS NULL
      THEN

         RETURN 'SDOGEOMETRY is NULL';

      END IF;

      IF p_line.sdo_gtype = 2002 or p_line.sdo_gtype = 2006
      THEN

         NULL;

      ELSE

         RETURN 'Gtype is ' || p_line.sdo_gtype;

      END IF;

      IF p_which_check = 'BOTH'
      OR p_which_check = '13356'
      THEN

         IF sdo_geom.validate_geometry_with_context(p_line, p_tolerance) != 'TRUE'
         THEN

            RETURN sdo_geom.validate_geometry_with_context(p_line, p_tolerance);

         END IF;

      END IF;

      IF p_which_check = 'BOTH'
      OR p_which_check = '13349'
      THEN

         psql := 'SELECT COUNT(*) FROM ( '
              || 'SELECT t.x, t.y, COUNT(*) kount '
              || 'FROM '
              || 'TABLE(SDO_UTIL.GETVERTICES(:p1)) t '
              || 'GROUP BY t.x, t.y '
              || ') WHERE kount > 1';

         EXECUTE IMMEDIATE psql INTO kount USING sdo_geom.sdo_intersection(p_line, p_line, p_tolerance);

         IF kount > 1
         THEN

            RETURN kount || ' self intersections ';

         ELSIF kount = 1
         THEN

            --This could be a ring!

            IF  p_line.sdo_ordinates(1) = p_line.sdo_ordinates(p_line.sdo_ordinates.COUNT - 1)
            AND p_line.sdo_ordinates(2) = p_line.sdo_ordinates(p_line.sdo_ordinates.COUNT)
            THEN

               RETURN 'TRUE';

            ELSE

               RETURN kount || ' self intersections ';

            END IF;

         END IF;

      END IF;

      RETURN 'TRUE';

   END VALIDATE_LINES_WITH_CONTEXT;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION VALIDATE_TOUCHING_LINES (
      p_line1                    IN SDO_GEOMETRY,
      p_line2                    IN SDO_GEOMETRY,
      p_tolerance                IN NUMBER DEFAULT .05,
      p_round_digits             IN NUMBER DEFAULT 6
   ) RETURN VARCHAR2
   AS

      --Matt! DOB 10/31/13

      --returns 'TRUE' or 'FALSE'
      --TRUE if the two lines do not come within p_tolerance of each other
      --FALSE if the two lines do come almost into contact with each other (other than shared point)
      --   Goal is to ID stuff like
      --
      --  x-----1------------
      --   \      /\
      --    \__2_/  \________

      --Lines must touch at one or 2 vertices, assumption is that these are next/previous edge$ edges


      --Specimen:
      --select gis_utils.VALIDATE_TOUCHING_LINES(e.geometry, ee.geometry, .05)
      --from z699tm_edge$ e,
      --z699tm_edge$ ee
      --where e.edge_id = 46935
      --and ee.edge_id = 46937

      --side note on why rounding is necessary
      --heres an example of a loop x position for 2 edges that share a node
      -- -80.43940281608109899025293998420238494873
      -- -80.43940299999999865576683077961206436157
      --might be better to put the points in a sdo_geometry and use sdo_relate. Have done this elsewhere
      --adds overhead however

      val_result        VARCHAR2(4000);
      x1head            NUMBER := ROUND(p_line1.sdo_ordinates(1), p_round_digits);
      y1head            NUMBER := ROUND(p_line1.sdo_ordinates(2), 6);
      x1tail            NUMBER := ROUND(p_line1.sdo_ordinates(p_line1.sdo_ordinates.COUNT - 1), p_round_digits);
      y1tail            NUMBER := ROUND(p_line1.sdo_ordinates(p_line1.sdo_ordinates.COUNT), p_round_digits);
      x2head            NUMBER := ROUND(p_line2.sdo_ordinates(1), p_round_digits);
      y2head            NUMBER := ROUND(p_line2.sdo_ordinates(2), p_round_digits);
      x2tail            NUMBER := ROUND(p_line2.sdo_ordinates(p_line2.sdo_ordinates.COUNT - 1), p_round_digits);
      y2tail            NUMBER := ROUND(p_line2.sdo_ordinates(p_line2.sdo_ordinates.COUNT), p_round_digits);
      loop_allow_kount  PLS_INTEGER;
      ix_kount          PLS_INTEGER;

   BEGIN

      --Check for head-head, head-tail, tail-head, or tail-tail

      IF (x1head = x2head AND y1head = y2head)
      OR (x1head = x2tail AND y1head = y2tail)
      OR (x1tail = x2head AND y1tail = y2head)
      OR (x1tail = x2tail AND y1tail = y2tail)
      THEN

         --dont even make a copy of the concat geom in a local var
         val_result := GIS_UTILS.VALIDATE_LINES_WITH_CONTEXT(mdsys.SDO_UTIL.CONCAT_LINES(p_line1,
                                                                                       p_line2),
                                                                 p_tolerance,
                                                                 '13349'); --only check for self-intersection

         --theres potentially more info here if we want it
         --dbms_output.put_line(val_result);

         IF val_result = 'TRUE'
         THEN

            RETURN 'TRUE';

         ELSIF val_result LIKE '1 self intersections%'
         OR    val_result LIKE '2 self intersections%'
         OR    val_result LIKE '3 self intersections%'
         THEN

            --check that one of the edges isn't a ring attached to the other edge
            --that spot would appear as a self-intersection in the concatenated geom

            --   ---1--    x is a node in the original topo
            --   |    |      and also the reported intersection point in the concatenated validation
            --   |    |
            --   -----x----2-----

            --and also there's an unfortunate wrinkle regarding the *2* and *3* self intersections
            --in cases like the one diagrammed above Oracle appears to always output (in the validate subroutine sdo_intersection)
            --a new start point for the looping edge somewhere on the loop.
            --I guess this makes it a little more valid or something

            --   x--1--        <---Bonus intersection point, start-end loop of the concatenated intersection
            --   |    |
            --   |    |
            --   -----x----2-----   <--True sensible intersection of the input geom

            IF  (x1head <> x1tail AND y1head <> y1tail)
            AND (x2head <> x2tail AND y2head <> y2tail)
            THEN

               IF (x1head = x2head AND y1head = y2head AND x1tail = x2tail AND y1tail = y2tail) --1head/2head + 1tail/2tail
               OR (x1head = x2tail AND y1head = y2tail AND x1tail = x2head AND y1tail = y2head) --1head/2tail + 1tail/2head
               THEN

                  --However check that the two edges dont join at a node on both ends
                  --this results in 1 false positive intersection
                  --    __1__
                  --   /     \
                  --  x       x
                  --   \__2__/

                  ix_kount := TO_NUMBER(SUBSTR(val_result,1,1));

                  IF ix_kount = 1
                  THEN

                     RETURN 'TRUE';

                  ELSE

                     RETURN 'FALSE';

                  END IF;


               ELSE

                  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
                  --No looping involved. Got a real intersection at tolerance.
                  --legit FALSE return values 99.99% go here, everything else is
                  --false positive loops burrowing toward a TRUE
                  RETURN 'FALSE';
                  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

               END IF;

            ELSE

               --false alarm, most likely, got loops in the picture

               --1, 2, or 3
               ix_kount := TO_NUMBER(SUBSTR(val_result,1,1));

               --start with one point for there being a loop,
               --always an intersection at the junction
               loop_allow_kount := 1;

               --next allow 1 or 2 more depending on how many self loops we have

               IF  x1head = x1tail
               AND y1head = y1tail
               THEN

                  loop_allow_kount := loop_allow_kount + 1;

               END IF;

               IF  x2head = x2tail
               AND y2head = y2tail
               THEN

                  loop_allow_kount := loop_allow_kount + 1;

               END IF;


               IF ix_kount <= loop_allow_kount
               THEN

                  RETURN 'TRUE';

               ELSE

                  RETURN 'FALSE';

               END IF;

            END IF;

         ELSE

            --4 intersections?  Hopefully never
            RETURN 'FALSE';

         END IF;

      ELSE

         RAISE_APPLICATION_ERROR(-20001, 'Input lines dont touch buster');

      END IF;

   END VALIDATE_TOUCHING_LINES;

   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Private------------------------------------------------------------------------------------------

   FUNCTION SDO_ARRAY_TO_SDO (
      p_sdo_array   IN  GIS_UTILS.geomarray
   ) RETURN SDO_GEOMETRY
   AS

      output SDO_GEOMETRY;

   BEGIN

      FOR i IN 1 .. p_sdo_array.COUNT
      LOOP
         IF output IS NULL
         THEN
            output := p_sdo_array(i);
         ELSE
            output := mdsys.SDO_UTIL.APPEND(output,p_sdo_array(i));
         END IF;

      END LOOP;

      RETURN output;

   END SDO_ARRAY_TO_SDO;

   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Private------------------------------------------------------------------------------------------

   FUNCTION GZ_SCRUB_LINE (
      p_incoming    IN SDO_GEOMETRY
   ) RETURN GIS_UTILS.geomarray
   AS

      subelement   SDO_GEOMETRY;
      output       GIS_UTILS.geomarray;
      pcounter     PLS_INTEGER;

   BEGIN

      -- These outcomes are all garbage
      -- for lines
      IF p_incoming IS NULL
      OR p_incoming.SDO_GTYPE = 2001
      OR p_incoming.SDO_GTYPE = 2003
      OR p_incoming.SDO_GTYPE = 2005
      OR p_incoming.SDO_GTYPE = 2007
      THEN

         RETURN output;

      ELSIF p_incoming.SDO_GTYPE = 2002
      THEN

         output(1) := p_incoming;
         RETURN output;

      ELSIF p_incoming.SDO_GTYPE = 2004
      OR    p_incoming.SDO_GTYPE = 2006
      THEN

         pcounter := 1;
         FOR i IN 1 .. mdsys.SDO_UTIL.GETNUMELEM(p_incoming)
         LOOP
            subelement := mdsys.SDO_UTIL.EXTRACT(p_incoming,i);
            IF subelement.SDO_GTYPE = 2002
            THEN
               output(pcounter) := subelement;
               pcounter := pcounter + 1;
            END IF;
         END LOOP;

         RETURN output;

      ELSE
         RAISE_APPLICATION_ERROR(-20001,'incoming SDO_GEOMETRY cannot be processed!');
      END IF;

   END GZ_SCRUB_LINE;


   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Private------------------------------------------------------------------------------------------

   FUNCTION GZ_SCRUB_POLY (
      p_incoming    IN SDO_GEOMETRY
   ) RETURN GIS_UTILS.geomarray
   AS

      subelement   SDO_GEOMETRY;
      output       GIS_UTILS.geomarray;
      pcounter     PLS_INTEGER;

   BEGIN

      -- These outcomes are all garbage
      -- for polygons
      IF p_incoming IS NULL
      OR p_incoming.SDO_GTYPE = 2001
      OR p_incoming.SDO_GTYPE = 2002
      OR p_incoming.SDO_GTYPE = 2005
      OR p_incoming.SDO_GTYPE = 2006
      THEN

         RETURN output;

      ELSIF p_incoming.SDO_GTYPE = 2003
      THEN

         output(1) := p_incoming;
         RETURN output;

      ELSIF p_incoming.SDO_GTYPE = 2004
      OR    p_incoming.SDO_GTYPE = 2007
      THEN

         pcounter := 1;
         FOR i IN 1 .. mdsys.SDO_UTIL.GETNUMELEM(p_incoming)
         LOOP
            subelement := mdsys.SDO_UTIL.EXTRACT(p_incoming,i);
            IF subelement.SDO_GTYPE = 2003
            THEN
               output(pcounter) := subelement;
               pcounter := pcounter + 1;
            END IF;
         END LOOP;

         RETURN output;

      ELSE
         RAISE_APPLICATION_ERROR(-20001,'incoming SDO_GEOMETRY cannot be processed!');
      END IF;

   END GZ_SCRUB_POLY;


   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Private------------------------------------------------------------------------------------------

   FUNCTION GZ_POLY_SDO (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER,
      p_operation     IN VARCHAR2
   ) RETURN GIS_UTILS.geomarray
   AS

      sdo_temp     SDO_GEOMETRY;
      output       GIS_UTILS.geomarray;

   BEGIN

      IF p_operation = 'INTERSECTION'
      THEN

         IF p_incoming.SDO_GTYPE = 2003
         OR p_incoming.SDO_GTYPE = 2007
         THEN

            RETURN GZ_SCRUB_POLY(SDO_GEOM.SDO_INTERSECTION(p_incoming,p_clipper,p_tolerance));

         ELSE
            RAISE_APPLICATION_ERROR(-20001,'ERROR GZ_POLY_SDO only works on 2003 and 2007 SDO_GTYPEs!');
         END IF;

      ELSE
         RAISE_APPLICATION_ERROR(-20001,'Unknown operation ' || p_operation || '!');
      END IF;

   END GZ_POLY_SDO;


   -----------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public---------------------------------------------------------------------------------

    FUNCTION GZ_INTERSECTION (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC
   AS

      --Matt!  5/20/11 Copied and modified camps clipper

   BEGIN

      IF p_incoming.SDO_GTYPE = 2001 OR p_incoming.SDO_GTYPE = 2005
      THEN

         -- Just do a regular intersection on points
         RETURN SDO_GEOM.SDO_INTERSECTION(p_incoming,
                                          p_clipper,
                                          p_tolerance);

      ELSIF p_incoming.SDO_GTYPE = 2002 OR p_incoming.SDO_GTYPE = 2006
      THEN

         -- use the special GZ_LINE_INTERSECTION function
         RETURN GIS_UTILS.GZ_LINE_INTERSECTION(p_incoming,
                                                   p_clipper,
                                                   p_tolerance);

      ELSIF p_incoming.SDO_GTYPE = 2003 OR p_incoming.SDO_GTYPE = 2007
      THEN

           -- use the special GZ_POLY_INTERSECTION function
         RETURN GIS_UTILS.GZ_POLY_INTERSECTION(p_incoming,
                                                   p_clipper,
                                                   p_tolerance);

      ELSE
         RAISE_APPLICATION_ERROR(-20001,'Dude, I have no idea what to do with SDO_GTYPE ' || p_incoming.SDO_GTYPE || '!');
      END IF;


   END GZ_INTERSECTION;

   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------------------------

   FUNCTION GZ_LINE_INTERSECTION (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC
   AS
   BEGIN

      IF p_incoming.SDO_GTYPE != 2002 AND p_incoming.SDO_GTYPE != 2006
      THEN
         RAISE_APPLICATION_ERROR(-20001,'GZ_LINE_INTERSECTION: input_line sdo geometry is not 2002 or 2006 but ' || p_incoming.SDO_GTYPE || '!');
      END IF;

      IF p_clipper.SDO_GTYPE != 2003 AND p_clipper.SDO_GTYPE != 2007
      THEN
         RAISE_APPLICATION_ERROR(-20001,'GZ_LINE_INTERSECTION: clip_polygon sdo geometry is not 2003 or 2007 but ' || p_clipper.SDO_GTYPE || '!');
      END IF;

      RETURN SDO_ARRAY_TO_SDO(GZ_LINE_SDO(p_incoming,p_clipper,p_tolerance,'INTERSECTION'));

   END GZ_LINE_INTERSECTION;


   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION GZ_LINE_SDO (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER,
      p_operation     IN VARCHAR2
   ) RETURN GIS_UTILS.geomarray DETERMINISTIC
   AS

      output       GIS_UTILS.geomarray;

   BEGIN

      IF p_operation = 'INTERSECTION'
      THEN
         output := GZ_SCRUB_LINE(SDO_GEOM.SDO_INTERSECTION(p_incoming,p_clipper,p_tolerance));

      ELSIF p_operation = 'DIFFERENCE'
      THEN
         output := GZ_SCRUB_LINE(SDO_GEOM.SDO_DIFFERENCE(p_incoming,p_clipper,p_tolerance));
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'GZ_2002_SDO: unknown operation ' || p_operation || '!');
      END IF;


      RETURN output;

   END GZ_LINE_SDO;


   ---------------------------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------------------------

   FUNCTION GZ_POLY_INTERSECTION (
      p_incoming    IN SDO_GEOMETRY,
      p_clipper     IN SDO_GEOMETRY,
      p_tolerance   IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC
   AS


   BEGIN

      IF p_incoming.SDO_GTYPE != 2003 AND p_incoming.SDO_GTYPE != 2007
      THEN
         RAISE_APPLICATION_ERROR(-20001,'GZ_POLY_INTERSECTION: input_line sdo geometry is not 2003 or 2007 but ' || p_incoming.SDO_GTYPE || '!');
      END IF;

      IF p_clipper.SDO_GTYPE != 2003 AND p_clipper.SDO_GTYPE != 2007
      THEN
         RAISE_APPLICATION_ERROR(-20001,'GZ_POLY_INTERSECTION: clip_polygon sdo geometry is not 2003 or 2007 but ' || p_clipper.SDO_GTYPE || '!');
      END IF;

      RETURN SDO_ARRAY_TO_SDO(GZ_POLY_SDO(p_incoming,p_clipper,p_tolerance,'INTERSECTION'));

   END GZ_POLY_INTERSECTION;

   ---------------------------------------------------------------------------------
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --Public-------------------------------------------------------------------------

   FUNCTION INTERSECTION_CENTROID (
      p_incoming        IN SDO_GEOMETRY,
      p_clipper         IN SDO_GEOMETRY,
      p_tolerance       IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC
   AS

      --mschell! 20160108

      --input a poly (p_incoming)
      --and a clipper (p_clipper)
      --clip incoming to the poly and get the centroid where
      --   If the result of the clip is multiple polygons
      --   place the centroid at the center of the largest bit
      --   If the centroid isnt inside then move it inside,
      --   to technically no longer a centroid location

      --anticipated usage is labeling points like the crime map
      --Given unclipped NYPD sectors, clip and get the best
      -- centroid

      --ex
      --create table centroidtest as
      --select a.objectid, sector, gis_utils.intersection_centroid(a.shape,
      --                                 (select shape from nycland),
      --                                 .001) as shape
      --from NYPDSECTOR20151113 a
      --where a.sector IN ('1A','1B','1C','1D')

      winningarea       NUMBER;
      clipped           SDO_GEOMETRY;
      poly2use          SDO_GEOMETRY;
      centroid          SDO_GEOMETRY;

   BEGIN

      IF p_incoming.sdo_gtype NOT IN (2003,2007)
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Input isnt a poly. Gtype: '
                                         || p_incoming.sdo_gtype);

      END IF;

      IF p_clipper.sdo_gtype NOT IN (2003,2007)
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Clip mask isnt a poly. Gtype: '
                                         || p_clipper.sdo_gtype);

      END IF;

      clipped := GIS_UTILS.GZ_INTERSECTION(p_incoming,
                                           p_clipper,
                                           p_tolerance);

      IF clipped.sdo_gtype = 2003
      THEN

         poly2use := clipped;

      ELSE

         FOR i IN 1 .. mdsys.SDO_UTIL.GETNUMELEM(clipped)
         LOOP

            IF i = 1
            THEN

               poly2use := mdsys.SDO_UTIL.EXTRACT(clipped, i);

               winningarea := SDO_GEOM.SDO_AREA(poly2use, p_tolerance);

            ELSE

               IF winningarea < SDO_GEOM.SDO_AREA(mdsys.SDO_UTIL.EXTRACT(clipped, i),
                                                  p_tolerance)
               THEN

                  poly2use := mdsys.SDO_UTIL.EXTRACT(clipped, i);

                  winningarea := SDO_GEOM.SDO_AREA(poly2use, p_tolerance);

               END IF;

            END IF;

         END LOOP;

      END IF;

      centroid := SDO_GEOM.SDO_CENTROID(poly2use,p_tolerance);

      IF SDO_GEOM.RELATE(centroid, 'INSIDE', poly2use, p_tolerance) <> 'INSIDE'
      THEN

         centroid := mdsys.SDO_UTIL.INTERIOR_POINT(poly2use, p_tolerance);

      END IF;

      IF SDO_GEOM.RELATE(centroid, 'INSIDE', poly2use, p_tolerance) <> 'INSIDE'
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Boo, cant get an interior point!');

      END IF;

      RETURN centroid;

   END INTERSECTION_CENTROID;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION COUNT_RINGS (
      p_in_geom         IN SDO_GEOMETRY
   ) RETURN NUMBER DETERMINISTIC
   AS

      --mschell! 20160610
      --from Simon Greener helping a moron a decade ago
      --https://community.oracle.com/thread/841182

      --subtract getnumelem for inner ring only count

      v_ring_count number := 0;

   BEGIN

       SELECT count(*) as ringcount
       INTO v_ring_count
       FROM (SELECT e.id,
                    e.etype,
                    e.offset,
                    e.interpretation
               FROM (SELECT trunc((rownum - 1) / 3,0) as id,
                            sum(case when mod(rownum,3) = 1 then sei.column_value else null end) as offset,
                            sum(case when mod(rownum,3) = 2 then sei.column_value else null end) as etype,
                            sum(case when mod(rownum,3) = 0 then sei.column_value else null end) as interpretation
                       FROM TABLE(p_in_geom.sdo_elem_info) sei
                      GROUP BY trunc((rownum - 1) / 3,0)
                     ) e
            ) i
      WHERE i.etype in (1003,1005,2003,2005);

     RETURN v_ring_count;

   END COUNT_RINGS;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION GET_GEOM_SET (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE',
      p_whereclause     IN VARCHAR2 DEFAULT NULL
   ) RETURN SDO_GEOMETRY_ARRAY DETERMINISTIC
   AS

      --mschell! 20160613
      --cribbed directly from the docs

      --1st intended use is stitching landmass datasets into single records
      --ex
      --select SDO_AGGR_SET_UNION(GIS_UTILS.get_geom_set('LANDMASS_SDO_2263_1'),.0005 )
      --from dual

      TYPE            cursor_type IS REF CURSOR;
      query_crs       cursor_type;
      g               SDO_GEOMETRY;
      GeometryArr     SDO_GEOMETRY_ARRAY;
      where_clause    VARCHAR2(2000);

   BEGIN

      IF p_whereclause IS NULL
      THEN
         where_clause := NULL;
      ELSE
        where_clause := ' WHERE ';
      END IF;

      GeometryArr := SDO_GEOMETRY_ARRAY();

      OPEN query_crs FOR ' SELECT ' || p_column_name ||
                         ' FROM ' || p_table_name ||
                         where_clause || p_whereclause;
      LOOP

         FETCH query_crs into g;
         EXIT when query_crs%NOTFOUND ;

         GeometryArr.EXTEND;
         GeometryArr(GeometryArr.count) := g;

      END LOOP;

      RETURN GeometryArr;

   END GET_GEOM_SET;


   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION REMOVE_HOLES (
      p_input              IN  MDSYS.SDO_GEOMETRY,
      p_tolerance          IN NUMBER DEFAULT .0005
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC
   AS

      --mschell! 20160624
      --inspiration: https://github.com/pauldzy/DZ_SDO
      --   but that business about the first ring being the "mother"
      --   doesnt appear to hold true

      --edge case driving: The island inside a hole.
      --2004 detritus (lines and points) will be ditched

      temp_input       MDSYS.SDO_GEOMETRY;
      output_geom      MDSYS.SDO_GEOMETRY;
      gtype4           NUMBER;
      gtype4a          NUMBER;
      str_relationship VARCHAR2(4000 Char);
      dbug_print       PLS_INTEGER := 0;


   BEGIN

      gtype4 := p_input.get_gtype();

      IF gtype4 = 3
      THEN

         RETURN MDSYS.SDO_UTIL.EXTRACT(p_input,1,1);

      ELSIF gtype4 NOT IN (4,7)
      THEN

         RETURN p_input;

      END IF;

      output_geom := MDSYS.SDO_UTIL.EXTRACT(p_input,1,1);

      FOR i in 2 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
      LOOP

         temp_input := MDSYS.SDO_UTIL.EXTRACT(p_input,i,1);

         gtype4a := temp_input.get_gtype();

         IF gtype4a = 3
         THEN

            str_relationship := MDSYS.SDO_GEOM.RELATE(
                temp_input
               ,'DETERMINE'
               ,output_geom
               ,p_tolerance
            );

            IF dbug_print = 1
            THEN

               dbms_output.put_line('str_rel ' || i || ' ' || str_relationship);

            END IF;

            IF  str_relationship = 'INSIDE'
            OR  str_relationship = 'COVERS'
            OR  str_relationship = 'COVEREDBY'
            OR  str_relationship = 'CONTAINS'
            OR  str_relationship = 'EQUALS'
            OR  str_relationship = 'OVERLAPBDYINTERSECT'
            OR  str_relationship = 'OVERLAPBDYDISJOINT'  --island inside 2007
            THEN

               output_geom := MDSYS.SDO_GEOM.SDO_UNION(
                   output_geom
                  ,temp_input
                  ,p_tolerance
               );

            ELSE

               output_geom := MDSYS.SDO_UTIL.APPEND(
                   output_geom
                  ,temp_input
               );

            END IF;

         END IF;

      END LOOP;

      RETURN output_geom;

   END REMOVE_HOLES;
   
   
   FUNCTION REMOVE_SMALL_HOLES (
      geom_in              IN MDSYS.SDO_GEOMETRY,
      p_area               IN NUMBER,
      p_tolerance          IN NUMBER DEFAULT .0005
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC
   AS
   
      --Caller beware: 
      --   There is no check on validity of input or output
      --   Dont pass curves in here. Guaranteed to get index our of range errors
      
      --mschell! 20171215
      --get rid of sliver holes in polys
      --Geoms with these are frequently valid upon arrival from a source
      --But as coordinates are copied about using 3rd party tools, reprojected,
      --   etc, they become invalid

      --ex
      --update PARKFUNCTIONAL_SDO_2263_2 a 
      -- set a.shape = gis_utils.remove_holes(a.shape, 1)
      -- where a.name = 'Cross Island Parkway'
      
      geom_temp      SDO_GEOMETRY;
      inner_ring     SDO_GEOMETRY;
      geom_out       SDO_GEOMETRY;
      eleminfo       SDO_ELEM_INFO_ARRAY := SDO_ELEM_INFO_ARRAY();
      tempinfo       SDO_ELEM_INFO_ARRAY := SDO_ELEM_INFO_ARRAY();
      ordinates      SDO_ORDINATE_ARRAY :=  SDO_ORDINATE_ARRAY();
      humpty         SDO_GEOMETRY;
      keptkount      PLS_INTEGER := 0;
      ordstart       PLS_INTEGER;
      ordend         PLS_INTEGER;
      ordkounter     PLS_INTEGER := 0;
      
   BEGIN
   
      IF geom_in.SDO_GTYPE != 2003
      AND geom_in.SDO_GTYPE != 2007
      THEN
      
         RETURN geom_in;
         
      END IF;

      FOR i IN 1 .. mdsys.SDO_UTIL.GETNUMELEM(geom_in)
      LOOP

         --dbms_output.put_line('on i ' || i);
         
         --Get each outer ring
         geom_temp := mdsys.SDO_UTIL.EXTRACT(geom_in,i);

         --Check for valid outer ring if the caller cares
         --We never touch the outer ring, all we can do is bomb

         eleminfo := geom_temp.SDO_ELEM_INFO;

         IF eleminfo.COUNT = 3
         THEN

            --nothing to do
            IF i = 1
            THEN
               geom_out := geom_temp;
            ELSE
               geom_out := mdsys.SDO_UTIL.APPEND(geom_out,geom_temp);
            END IF;

         ELSE

            --we have inner rings
            --in this section we will attempt to build a 2003, with our without holes
            -- (based on the areas of the holes)
            --then append the result to the running geom_out

            --ELEM info is in triplets

            FOR j IN 1 .. (eleminfo.COUNT)/3
            LOOP
            
               --dbms_output.put_line('on j ' || j);

               IF j = 1
               THEN

                  --technically this one isnt an "inner"
                  inner_ring := mdsys.SDO_UTIL.EXTRACT(geom_temp,1,j);

                  --move the info array along
                  tempinfo.EXTEND(3);
                  tempinfo := inner_ring.SDO_ELEM_INFO;

                  --move the ordinates along
                  ordinates.EXTEND(inner_ring.sdo_ordinates.COUNT);
                  ordinates := inner_ring.SDO_ORDINATES;

                  --start this counter up for later
                  ordkounter := ordinates.COUNT;

               ELSE

                  --get the inner ring
                  --element is always 1 since the EXTRACT up above guarantees a 2003
                  --ring is 2 or higher
                  inner_ring := mdsys.SDO_UTIL.EXTRACT(geom_temp,1,j);

                  --test for validation and rectify if necessary
                  --so we can get a true area next

                  IF SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(inner_ring, p_tolerance) != 'TRUE'
                  THEN

                     BEGIN
                        inner_ring := mdsys.SDO_UTIL.RECTIFY_GEOMETRY(inner_ring, p_tolerance);
                     EXCEPTION
                     WHEN OTHERS THEN
                        --tiny triangles cant be rectified
                        --live dangerously 
                        NULL;
                     END;

                  END IF;

                  --dbms_output.put_line('area is ' || SDO_GEOM.SDO_AREA(inner_ring, p_tolerance));                  
                  
                  IF SDO_GEOM.SDO_AREA(inner_ring, p_tolerance) < p_area
                  OR SDO_GEOM.SDO_AREA(inner_ring, p_tolerance) IS NULL --Sometimes rectify rectifies a sliver out of existence
                  THEN

                     NULL;

                  ELSE
                  
                     keptkount := keptkount + 1;

                     --we need him
                     --extend silly arrays
                     tempinfo.EXTEND(3);

                     --keeper starts at current ordinate kount + 1
                     tempinfo((keptkount * 3) + 1) := ordinates.COUNT + 1;
                     --inner ring is always a 2003
                     tempinfo((keptkount * 3) + 2) := 2003;
                     --etype is always a 1 (I think)
                     tempinfo((keptkount * 3) + 3) := 1;

                     --the extracted ordinates are actually reversed
                     --so go back to the geom_temp where the inner ring ordinates are still inners

                     --(1, 1003, 1, 2105, 2003, 1, 2113, 2003, 1, 2123, 2003, 1)
                     --For example start at ordinates 2105 go to 2112
                     ordstart := eleminfo((j*3) - 2);
                     ordend   := ordstart + inner_ring.sdo_ordinates.COUNT - 1;

                     ordinates.EXTEND(inner_ring.sdo_ordinates.COUNT);

                     FOR ii IN ordstart .. ordend
                     LOOP

                        IF ii = 1
                        THEN
                           ordkounter := ordinates.COUNT;
                        END IF;

                        ordkounter := ordkounter + 1;

                        ordinates(ordkounter) :=  geom_temp.sdo_ordinates(ii);

                     END LOOP;

                  END IF; --end if on keep or nokeep

               END IF;

            END LOOP;   --end loop over inner rings

            --we have put humpty back together again without any small inner rings
            --add this bit back to the full geometry

            humpty := SDO_GEOMETRY(2003,
                                   geom_in.SDO_SRID,
                                   NULL,
                                   tempinfo,
                                   ordinates);

            IF i = 1
            THEN
               geom_out := humpty;
            ELSE
               geom_out := mdsys.SDO_UTIL.APPEND(geom_out,humpty);
            END IF;

            --some day Ill know which of these is correct
            tempinfo.DELETE;
            tempinfo := SDO_ELEM_INFO_ARRAY();
            ordinates.DELETE;
            ordinates := SDO_ORDINATE_ARRAY();
            keptkount := 0; --doh

         END IF;

      END LOOP; --end loop over this piece of the original

      IF geom_out.SDO_GTYPE != 2003
      AND geom_out.SDO_GTYPE != 2007
      THEN

         RAISE_APPLICATION_ERROR(-20001,'Ended with gtype ' || geom_out.SDO_GTYPE || '. Whats the deal?');

      END IF;

      RETURN geom_out;
   
   END REMOVE_SMALL_HOLES; 

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION EXPLODE_POLYGON (
     p_in_geom          IN SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY_ARRAY
   AS

      --mschell! 20160613

      --return type allows call from SQL, but beware TOAD croaks easily
      --select gis_utils.EXPLODE_POLYGON(a.shape)
      --from master.LANDMASSBOROCLIP_SDO_2263_1 a
      --where a.objectid = 2

      output         MDSYS.SDO_GEOMETRY_ARRAY := MDSYS.SDO_GEOMETRY_ARRAY();

   BEGIN

      IF p_in_geom.sdo_gtype NOT IN (2003, 2007)
      THEN

         raise_application_error(-20001, 'Sorry dudely, I cant process gtype '
                                         || p_in_geom.sdo_gtype);

      END IF;

      IF p_in_geom IS NULL
      THEN

         RETURN output;

      END IF;

      --dont use gtype.  ESRI loaders still like to call any poly with
      --rings, including inner rings, 2007s

      output.EXTEND(mdsys.SDO_UTIL.GETNUMELEM(p_in_geom));

      FOR i IN 1 .. mdsys.SDO_UTIL.GETNUMELEM(p_in_geom)
      LOOP

         output(i) := mdsys.SDO_UTIL.EXTRACT(p_in_geom, i);

      END LOOP;

      RETURN output;

   END EXPLODE_POLYGON;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   FUNCTION SIMPLIFY_GEOMETRY (
      p_in_geom         IN SDO_GEOMETRY,
      p_threshhold      IN NUMBER,
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_recursion       IN NUMBER DEFAULT 0
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC
   AS

      --mschell! 20160629
      --do not need to rectify or check validity
      --simplify supposedly does internally

      p_out_geom        MDSYS.SDO_GEOMETRY;

   BEGIN

      p_out_geom := mdsys.SDO_UTIL.simplify(p_in_geom,
                                      p_threshhold,
                                      p_tolerance);

      IF  p_out_geom.get_gtype() = p_in_geom.get_gtype()
      AND p_out_geom IS NOT NULL
      THEN

         RETURN p_out_geom;

      ELSIF p_recursion < 2
      THEN

         --one or 2 more tries at half the threshhold
         RETURN GIS_UTILS.simplify_geometry(p_in_geom,
                                            p_threshhold/2,
                                            p_tolerance,
                                            (p_recursion+1));

      ELSE

         --We lost. Caller must decide what to do
         RETURN p_in_geom;

      END IF;

   END SIMPLIFY_GEOMETRY;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE CLIPTABLE (
      p_target_table    IN VARCHAR2,
      p_clip_table      IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_clip_clause     IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_clip_pkc        IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_clip_type       IN VARCHAR2 DEFAULT 'DIFFERENCE'
   )
   AS

      --mschell! 20160616

      --not sure if intersection clip of records that do not interact is
      --correct here.  For ex, if clipping assembly districts down
      --to the long island shape, assembly districts in the Bronx will
      --remain untouched
      --alternative: for intersection clips track all target table ids
      --touched, at the end delete any that weren't clipped back at least
      --some

      psql              VARCHAR2(4000);
      unclipidz         GIS_UTILS.numberarray;
      targetidz         GIS_UTILS.numberarray;
      workinggeom       SDO_GEOMETRY;

   BEGIN

      IF p_clip_type NOT IN ('DIFFERENCE','INTERSECTION')
      THEN

         raise_application_error(-20001, 'Unknown clip type parameter ' || p_clip_type);

      END IF;

      --get all ids to work - simple
      psql := 'SELECT a.' || p_target_pkc || ' '
           || 'FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      EXECUTE IMMEDIATE psql BULK COLLECT INTO unclipidz;

      FOR i IN 1 .. unclipidz.COUNT
      LOOP

         --get target geoms one by one
         psql := 'SELECT a.shape '
              || 'FROM ' || p_target_table || ' a '
              || 'WHERE a.' || p_target_pkc || ' = :p1';

         EXECUTE IMMEDIATE psql INTO workinggeom USING unclipidz(i);

         --avoid pulling clip geoms into memory, get their ids
         --and difference in SQL

         psql := 'SELECT a.' || p_clip_pkc || ' '
              || 'FROM ' || p_clip_table || ' a '
              || 'WHERE '
              || 'SDO_RELATE(a.shape, :p1, :p2) = :p3 ';

         IF p_clip_clause IS NOT NULL
         THEN

            --ex 'AND a.feature_code NOT IN (2640,2650) '
            psql := psql || 'AND ' ||  p_clip_clause || ' ';

         END IF;

         --assumption is that in most scenarios we are clipping a simple geom
         --by a wiggly one like hydro, so stay simple as long as possible
         psql := psql || 'ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC ';

         EXECUTE IMMEDIATE psql BULK COLLECT INTO targetidz USING workinggeom,
                                                                  'mask=ANYINTERACT',
                                                                  'TRUE';
         FOR jj in 1 .. targetidz.count
         LOOP

            IF p_clip_type = 'DIFFERENCE'
            THEN

               psql := 'SELECT SDO_GEOM.sdo_difference(:p1, a.shape, :p2) ';

            ELSIF p_clip_type = 'INTERSECTION'
            THEN

               psql := 'SELECT GIS_UTILS.gz_intersection(:p1, a.shape, :p2) ';

            END IF;

            psql := psql || 'FROM ' || p_clip_table || ' a '
                         || 'WHERE a.' || p_clip_pkc || ' = :p3';

            EXECUTE IMMEDIATE psql INTO workinggeom USING workinggeom,
                                                          p_tolerance,
                                                          targetidz(jj);

         END LOOP;

         IF workinggeom IS NOT NULL
         THEN

            psql := 'UPDATE ' || p_target_table || ' a '
                 || 'SET a.shape = :p1 '
                 || 'WHERE a.' || p_target_pkc || ' = :p2 ';

            EXECUTE IMMEDIATE psql USING workinggeom,
                                         unclipidz(i);
            COMMIT;

         ELSE

            --a little scary might want to parameterize
            psql := 'DELETE FROM ' || p_target_table || ' a '
                 || 'WHERE a.' || p_target_pkc || ' = :p1 ';

            EXECUTE IMMEDIATE psql USING  unclipidz(i);
            COMMIT;

         END IF;

      END LOOP;

   END CLIPTABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE UNIONTABLE (
      p_target_table    IN VARCHAR2,
      p_union_table     IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_union_clause    IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_union_pkc       IN VARCHAR2 DEFAULT 'OBJECTID',
      p_uniondisjoint   IN VARCHAR2 DEFAULT 'Y',
      p_unioncols       IN VARCHAR2 DEFAULT 'SHAPE',
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS

      --mschell! 20160621
      --target table records will expand outward with any spatially related pieces
      --of union table
      --if p_uniondisjoint is Y then disjoint uniontable recs will append to target too
      --
      --results are probably as expected when targettable is big
      --and union table are little bits
      --output will be a fully dissolved record
      --
      --       __     __
      --      |  |   |  | <-- union shapes
      --   --------------------
      --   |   target         |
      --   |                  |
      --   -------------------

      --But if union shapes interact in more complex ways with multiple target recs
      --then the output shapes may include interior boundaries
      --
      --   __________________________
      --   |     unionX              |
      --   --------------------      |
      --   |   targetA        |-------
      --   |                  |      |
      --   -------------------   uY  |
      --                      |      |
      --   |------------------|      |
      --   |   targetB        |      |
      --   |                  |      |
      --   ---------------------------
      --
      --   Yields
      --   __________________________
      --   |                         |
      --   -                         |
      --   |   targetA               -
      --   |                         |
      --   -------------------       |
      --                      |      |
      --   |------------------|      |
      --   |   targetB        | <----|---Nonunioned boundary between output recs
      --   |                  |      |
      --   ---------------------------

      --   So call dissolve on the output
      --   Which is identical to putting all records from both datasets in one
      --   table and calling dissolve

      --rainy day: replace this looping inefficiency
      --with sdo_join and sdo_aggr/set_union

      psql           VARCHAR2(4000);
      unionpsql      VARCHAR2(4000);
      insert_sql     VARCHAR2(4000);
      inputidz       GIS_UTILS.numberarray;
      unionidz       GIS_UTILS.numberarray;
      workinggeom    SDO_GEOMETRY;
      processedids   MDSYS.SDO_List_Type := MDSYS.SDO_List_Type();
      maxid          NUMBER;

   BEGIN

      --get all objectids ordered by complexity
      psql := 'SELECT a.' || p_target_pkc || ' '
           || 'FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      psql := psql || 'ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC ';

      EXECUTE IMMEDIATE psql BULK COLLECT INTO inputidz;

      FOR i IN 1 .. inputidz.COUNT
      LOOP

         psql := 'SELECT a.shape '
              || 'FROM ' || p_target_table || ' a '
              || 'where a.objectid = :p1';

         EXECUTE IMMEDIATE psql INTO workinggeom USING inputidz(i);

         unionpsql := 'SELECT a.' || p_union_pkc || ' '
                   || 'FROM ' || p_union_table || ' a '
                   || 'WHERE '
                   || 'a.' || p_union_pkc || ' NOT IN (SELECT * FROM TABLE(:p1)) AND ';

         IF p_union_clause IS NOT NULL
         THEN

            unionpsql := unionpsql || p_union_clause || ' AND ';

         END IF;

         unionpsql := unionpsql || 'SDO_RELATE(a.shape, :p2, :p3) = :p4 '
                                || 'ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC ';

         EXECUTE IMMEDIATE unionpsql BULK COLLECT INTO unionidz USING processedids,
                                                                      workinggeom,
                                                                      'mask=ANYINTERACT',
                                                                      'TRUE';
         WHILE unionidz.COUNT > 0
         LOOP

            FOR jj in 1 .. unionidz.COUNT
            LOOP

               psql := 'SELECT SDO_GEOM.sdo_union(:p1, a.shape, :p2) '
                    || 'FROM ' || p_union_table || ' a '
                    || 'WHERE a.objectid = :p3';

               EXECUTE IMMEDIATE psql INTO workinggeom USING workinggeom,
                                                             p_tolerance,
                                                             unionidz(jj);

               processedids.EXTEND(1);
               processedids(processedids.COUNT) := unionidz(jj);

            END LOOP;

            --ANYINTERACT will repeatedly bring in same records, processedids will toss them
            --not efficient
            EXECUTE IMMEDIATE unionpsql BULK COLLECT INTO unionidz USING processedids,
                                                                         workinggeom,
                                                                         'mask=ANYINTERACT',
                                                                         'TRUE';
         END LOOP;

         psql := 'UPDATE ' || p_target_table || ' a '
              || 'SET a.shape = :p1 '
              || 'WHERE '
              || 'a.' || p_target_pkc || ' = :p2 ';

         EXECUTE IMMEDIATE psql USING workinggeom,
                                      inputidz(i);
         COMMIT;

      END LOOP;

      IF p_uniondisjoint = 'Y'
      THEN

         psql := 'SELECT MAX(a.' || p_target_pkc || ') '
              || 'FROM ' || p_target_table || ' a ';

         EXECUTE IMMEDIATE psql INTO maxid;

         --pass through others that arent spatially related
         --if requested

         insert_sql := 'INSERT INTO ' || p_target_table || ' '
                    || '(' || p_target_pkc || ',' || p_unioncols || ') '
                    || 'SELECT (:p1 + rownum),' || p_unioncols || ' '
                    || 'FROM '   || p_union_table || ' a '
                    || 'WHERE '
                    || 'a.' || p_union_pkc || ' NOT IN (SELECT * FROM TABLE(:p2)) ';

         IF p_union_clause IS NOT NULL
         THEN

            insert_sql := insert_sql || 'AND ' || p_union_clause;

         END IF;

         EXECUTE IMMEDIATE insert_sql USING maxid,
                                            processedids;
         COMMIT;

      END IF;

   END UNIONTABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE EXPLODETABLE (
      p_target_table    IN VARCHAR2,
      p_target_cols     IN VARCHAR2 DEFAULT 'OBJECTID,SHAPE',
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID'
   ) AS

      --mschell! 20160621

      --any multipolygons will be exploded, given new ids, and other target_cols duped
      --single outer ring polys will be untouched
      --columns not listed explicitly will dupe as NULL

      --ex
      --CALL GIS_UTILS.EXPLODETABLE('LANDMASSCOUNTY_SDO_2263_1',
      --                            'OBJECTID,STATEFP,COUNTYFP,GEOID,NAME,SHAPE',
      --                            q'^name='New York'^');

      --caller should ensure that these are polygons
      --and that any p_target_cols (other than pkc col)
      --that get duped do not have unique constraints or similar

      --rainy day:
      --this is too pl/sql-ey
      --rewrite to use SQL type without pulling every geom into pl/sql one by one
      --I think GIS_UTILS.EXPLODE_POLYGON could be table()d

      psql              VARCHAR2(4000);
      insert_sql        VARCHAR2(4000);
      maxid             NUMBER;
      idz               GIS_UTILS.numberarray;
      explodedgeom      SDO_GEOMETRY_ARRAY;
      colarray          GIS_UTILS.stringarray;
      switch_first      VARCHAR2(5) := 'UNSET';

   BEGIN

      psql := 'SELECT MAX(a.' || p_target_pkc || ') '
           || 'FROM ' || p_target_table || ' a ';

      EXECUTE IMMEDIATE psql INTO maxid;

      --ala [(objectid) (name) (shape)] leave pkc col and shape col in there
      colarray := GIS_UTILS.split(p_target_cols,',');

      psql := 'SELECT a.' || p_target_pkc || ' '
           || 'FROM ' || p_target_table || ' a '
           || 'WHERE '
           || 'SDO_UTIL.GETNUMELEM(a.shape) > :p1 ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'AND ' || p_target_clause;

      END IF;

      --get all ids up front so no mutation
      EXECUTE IMMEDIATE psql BULK COLLECT INTO idz USING 1;

      --set this insert mess up once
      insert_sql := 'INSERT INTO ' || p_target_table || ' '
                 || '(' || p_target_cols || ') '
                 || 'SELECT ';

      FOR jj in 1 .. colarray.COUNT
      LOOP

         IF UPPER(colarray(jj)) = UPPER(p_target_pkc)
         THEN

            --new objectid
            insert_sql := insert_sql || ':p1 ';

            IF switch_first = 'UNSET'
            THEN
               switch_first := 'PKC';
            END IF;

         ELSIF UPPER(colarray(jj)) = 'SHAPE'
         THEN

            --new shape
            insert_sql := insert_sql || ':p2 ';

            IF switch_first = 'UNSET'
            THEN
               switch_first := 'GEOM';
            END IF;

         ELSE

            insert_sql := insert_sql || 'a.' || colarray(jj) || ' ';

         END IF;

         IF jj <> colarray.COUNT
         THEN

            insert_sql := insert_sql || ', ';

         END IF;

      END LOOP;

      IF switch_first = 'UNSET'
      THEN

         RAISE_APPLICATION_ERROR(-20001, 'Something wrong with expected primary key and geom col '
                                      || 'inputs, insert so far: ' || insert_sql);

      END IF;

      insert_sql := insert_sql || 'FROM '
                               || p_target_table || ' a '
                               || 'WHERE a.' || p_target_pkc || ' = :p3 ';

      FOR i IN 1 .. idz.COUNT
      LOOP

         psql := 'SELECT GIS_UTILS.EXPLODE_POLYGON(a.shape) '
              || 'FROM ' || p_target_table || ' a '
              || 'WHERE '
              || 'a.' || p_target_pkc || ' = :p1 ';

         EXECUTE IMMEDIATE psql INTO explodedgeom USING idz(i);

         --insert these records

         IF explodedgeom.COUNT <= 1
         THEN

            RAISE_APPLICATION_ERROR(-20001, 'Failed to explode ' || p_target_table || ' '
                                         || p_target_pkc || ' ' || idz(i));

         END IF;

         FOR kk IN 1 .. explodedgeom.COUNT
         LOOP

            maxid := maxid + 1;

            IF switch_first = 'PKC'
            THEN

               BEGIN

                  EXECUTE IMMEDIATE insert_sql USING maxid,
                                                     explodedgeom(kk),
                                                     idz(i);
               EXCEPTION
               WHEN OTHERS
               THEN

                  --FRAUGHT i tells ya
                  RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || insert_sql
                                       || 'binds: ' || maxid || ',<geom>,' || idz(i));

               END;

            ELSIF switch_first = 'GEOM'
            THEN

               BEGIN

                  EXECUTE IMMEDIATE insert_sql USING explodedgeom(kk),
                                                     maxid,
                                                     idz(i);

               EXCEPTION
               WHEN OTHERS
               THEN

                  RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || insert_sql
                                       || 'binds: <geom>,' || maxid || ',' || idz(i));

               END;

            END IF;

         END LOOP;

         psql := 'DELETE FROM ' || p_target_table || ' a '
              || 'WHERE a.' || p_target_pkc || ' = :p1 ';

         EXECUTE IMMEDIATE psql USING idz(i);

         COMMIT;

      END LOOP;

   END EXPLODETABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE SIMPLIFYTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_threshhold      IN NUMBER DEFAULT .001,
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS

      --mschell! 20160629
      --table wrapper to simplify_geometry
      --the default p_threshhold will do almost nothing
      --   it removes invisible noise

      psql              VARCHAR2(4000);

   BEGIN

      psql := 'UPDATE ' || p_target_table || ' a '
           || 'SET '
           || 'a.shape = GIS_UTILS.simplify_geometry(a.shape, :p1, :p2) ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      BEGIN

         EXECUTE IMMEDIATE psql USING p_threshhold,
                                      p_tolerance;
         COMMIT;

      EXCEPTION
      WHEN OTHERS
      THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

      END;

   END SIMPLIFYTABLE;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE AGGREGATETABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS

      --mschell! 20160715
      --in most use cases the defaults are fine, call simply
      --CALL GIS_UTILS.AGGREGATETABLE('TABLENAMEHERE');

      --Compare to rolluptable, which is faster but expects all geoms disjoint
      --all geometries (including those not disjoint) will be combined into
      --   one giant geometry
      --columns other than pkc and shape will be completely obliterated in the 
      --   output table.  (Unlike rolluptable where a seed record remains)
      --source records input to aggregation will be deleted

      psql                 VARCHAR2(4000);
      workingblob          SDO_GEOMETRY;
      newid                NUMBER;
      grouprow             NUMBER;
      grouppow             NUMBER;

   BEGIN

      psql := 'SELECT MAX(a.' || p_target_pkc || ' + 1) '
           || 'FROM ' || p_target_table || ' a ';

      --no whereclause
      EXECUTE IMMEDIATE psql INTO newid;

      --docs example is 5000 rows
      --5000/50 = 100; and 128 is the next higher power of 2
      psql := 'SELECT '
           || 'POWER(2, CEIL( LOG(2, COUNT(*)/50))), '
           || 'CEIL(LOG(2, COUNT(*)/50)) '
           || 'FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      --grouppow = 128, grouprow = 6
      --grouppow = 32  grouprow = 5
      --grouppow = 4  grouprow = 2
      EXECUTE IMMEDIATE psql INTO grouppow, grouprow;

      --Heres a sample to ogle
      --SELECT sdo_aggr_union (sdoaggrtype (aggr_geom, .0005)) aggr_geom
      --  FROM (  SELECT sdo_aggr_union (sdoaggrtype (aggr_geom, .0005)) aggr_geom
      --            FROM (  SELECT sdo_aggr_union (sdoaggrtype (aggr_geom, .0005))
      --                              aggr_geom
      --                      FROM (  SELECT sdo_aggr_union (sdoaggrtype (a.shape, .0005))
      --                                        aggr_geom
      --                                FROM LANDMASSPANW_SDO_2263_5 a
      --                            GROUP BY MOD (ROWNUM, 32))
      --                  GROUP BY MOD (ROWNUM, 8))
      --        GROUP BY MOD (ROWNUM, 2))

      psql := '';

      FOR i in 1 .. (grouprow - 2)
      LOOP

         psql := psql || 'SELECT '
                      || 'sdo_aggr_union(sdoaggrtype(aggr_geom,' || p_tolerance || ')) aggr_geom '
                      || 'FROM (';

      END LOOP;

      --hit the bottom, or maybe we never looped at all. Whos to say in this crazy world
      psql := psql || 'SELECT '
                   || 'sdo_aggr_union(sdoaggrtype(a.shape,' || p_tolerance || ')) aggr_geom '
                   || 'FROM ';

      psql := psql || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause || ' ';

      END IF;

      FOR i IN 1 .. (grouprow - 2)
      LOOP

         psql := psql || 'GROUP BY mod(rownum, ' || grouppow || '))';

         grouppow := grouppow/2/2;

      END LOOP;

      BEGIN

         EXECUTE IMMEDIATE psql INTO workingblob;

      EXCEPTION
      WHEN OTHERS
      THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

      END;

      psql := 'DELETE FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      EXECUTE IMMEDIATE psql;

      psql := 'INSERT INTO ' || p_target_table || ' '
           || '(' || p_target_pkc || ',' || 'shape) '
           || 'VALUES(:p1,:p2)';

      EXECUTE IMMEDIATE psql USING newid,
                                   workingblob;

      COMMIT;

   END AGGREGATETABLE;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE DISSOLVETABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_mask            IN VARCHAR2 DEFAULT 'ANYINTERACT'
   )
   AS

      --mschell! 20160624

      --All indicated records that are not spatially disjoint (or specified mask)
      --will be combined.
      --Other columns will not be maintained and some records will disappear.
      --For ex
      --If record A dissolves with record B
      --   Record A spatial extent will grow to incorporate B extent
      --   Record A columns other than shape will be untouched
      --   Record B will be deleted.

      allobjectids         GIS_UTILS.numberarray;
      seedobjectid         NUMBER;
      bucketobjectids      GIS_UTILS.numberarray;
      processedids         MDSYS.SDO_List_Type := MDSYS.SDO_List_Type();
      psql                 VARCHAR2(4000);
      bucketsql            VARCHAR2(4000);
      workingblob          SDO_GEOMETRY;
      kount                PLS_INTEGER;
      deadman              PLS_INTEGER := 0;
      deadman_switch       PLS_INTEGER := 999999;

   BEGIN

      --get all objectids ordered by complexity
      --all collected to avoid mutation
      psql := 'SELECT a.' || p_target_pkc || ' '
           || 'FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      psql := psql || ' ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC ';

      EXECUTE IMMEDIATE psql BULK COLLECT INTO allobjectids;

      --dbms_output.put_line(psql);
      --dbms_output.put_line('got ' || allobjectids.COUNT);

      FOR i IN 1 .. allobjectids.COUNT
      LOOP

         psql := 'SELECT COUNT(*) FROM TABLE(:p1) t '
              || 'WHERE t.column_value = :p2 ';

         EXECUTE IMMEDIATE psql INTO kount USING processedids,
                                                 allobjectids(i);

         IF kount = 1
         THEN

            --already processed into some other blob, skip
            CONTINUE;

         ELSE

            seedobjectid := allobjectids(i);
            processedids.EXTEND(1);
            processedids(processedids.COUNT) := allobjectids(i);

            psql := 'SELECT a.shape '
                 || 'FROM ' ||  p_target_table || ' a '
                 || 'WHERE a.' || p_target_pkc || ' = :p1 ';

            EXECUTE IMMEDIATE psql INTO workingblob USING seedobjectid;

         END IF;

         --get other objectids spatially related (may be zero)
         --what about touch at a point buster?

         bucketsql := 'SELECT a.' || p_target_pkc || ' '
                   || 'FROM ' || p_target_table || ' a '
                   || 'WHERE '
                   || 'SDO_RELATE(a.shape, :p1, :p2) = :p3 AND '
                   || 'a.' || p_target_pkc || ' <> :p4 '; --dont keep unioning with og seed

         IF p_target_clause IS NOT NULL
         THEN

            bucketsql := bucketsql || 'AND ' || p_target_clause || ' ';

         END IF;

         bucketsql := bucketsql || 'ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC ';

         EXECUTE IMMEDIATE bucketsql BULK COLLECT INTO bucketobjectids USING workingblob,
                                                                             'mask=' || UPPER(p_mask),
                                                                             'TRUE',
                                                                             allobjectids(i);

         WHILE bucketobjectids.COUNT > 0
         LOOP

            FOR jj IN 1 .. bucketobjectids.COUNT
            LOOP

               --union these one by one, and remove unioned recs from the table

               psql := 'SELECT SDO_GEOM.sdo_union(a.shape, :p1, :p2) '
                    || 'FROM ' || p_target_table || ' a '
                    || 'WHERE a.' || p_target_pkc || ' = :p3 ';

               EXECUTE IMMEDIATE psql INTO workingblob USING workingblob,
                                                             p_tolerance,
                                                             bucketobjectids(jj);

               psql := 'DELETE FROM ' || p_target_table || ' a '
                    || 'WHERE a.' || p_target_pkc || ' = :p1 ';

               EXECUTE IMMEDIATE psql USING bucketobjectids(jj);

               --even though deleted from table must save these for skipping
               --in the outer loop
               processedids.EXTEND(1);
               processedids(processedids.COUNT) := bucketobjectids(jj);

            END LOOP;

            --dip back in for another bucket using expanded blob
            EXECUTE IMMEDIATE bucketsql BULK COLLECT INTO bucketobjectids USING workingblob,
                                                                                'mask=' || UPPER(p_mask),
                                                                                'TRUE',
                                                                                allobjectids(i);

            IF deadman < deadman_switch
            THEN

               deadman := deadman + 1;

            ELSE

               RAISE_APPLICATION_ERROR(-20001, 'Deadman switch, looped 1 million times on '
                                               || bucketsql);

            END IF;

         END LOOP;

         --finished growing outward from this original seed
         psql := 'UPDATE ' || p_target_table || ' a '
              || 'SET a.shape = :p1 '
              || 'WHERE a.' || p_target_pkc || ' = :p2 ';

         EXECUTE IMMEDIATE psql USING workingblob,
                                      allobjectids(i);
         COMMIT;

      END LOOP;


   END DISSOLVETABLE;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE ROLLUPTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_depth           IN NUMBER DEFAULT NULL,
      p_max_depth       IN NUMBER DEFAULT NULL
   )
   AS

      --mschell! 20160629
      --in most use cases the defaults are fine, call simply

      --CALL GIS_UTILS.rolluptable('TABLENAMEHERE');

      --all disjoint geometries (we will check), will be combined into
      --   one giant multipolygon geometry
      --if records spatially interact this will error and exit, saving all work at the
      --  point of discovering the interaction
      --columns other than pkc and shape will be thoroughly disrespected
      --   in the output record
      --   but the seed output record will keep its input values
      --often used in a worflow like
      --   explode polys (some multipolys) to do some work 
      --   do the edits
      --   dissolve all who touch
      --   finally roll up into multipolys as required

      psql                 VARCHAR2(4000);
      psqlappend           VARCHAR2(4000);
      psqlupdate           VARCHAR2(4000);
      psqldelete           VARCHAR2(4000);
      twoidz               GIS_UTILS.numberarray;
      workingblob          SDO_GEOMETRY;
      max_depth            PLS_INTEGER;
      curr_depth           PLS_INTEGER;

   BEGIN

      IF p_max_depth IS NULL
      THEN

         --top of the stack
         psql := 'SELECT COUNT(*) '
              || 'FROM ' || p_target_table;

         EXECUTE IMMEDIATE psql INTO max_depth;

         curr_depth := 0;

      ELSE

         max_depth := p_max_depth;
         curr_depth := p_depth + 1;

      END IF;

      psql := 'SELECT aa.objectid FROM ( '
           || 'SELECT a.objectid, SDO_UTIL.getnumvertices(a.shape) '
           || 'FROM ' || p_target_table || ' a ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      --always work on the two smallest pieces in the bucket
      --otherwise the blob gets scary and performance slows exponentially
      psql := psql || 'ORDER BY SDO_UTIL.getnumvertices(a.shape) ASC) aa '
                   || 'WHERE rownum < 3 ';

      EXECUTE IMMEDIATE psql BULK COLLECT INTO twoidz;

      psqlappend := 'SELECT '
              || 'CASE '
              || '   WHEN SDO_GEOM.relate(a.shape, :p1, b.shape, :p2) = :p3 '
              || '   THEN '
              || '      SDO_UTIL.append(a.shape, b.shape) '
              || '   ELSE '
              || '      NULL '
              || 'END '
              || 'FROM '
              || p_target_table || ' a, '
              || p_target_table || ' b '
              || 'WHERE '
              || 'a.' || p_target_pkc || ' = :p4 AND '
              || 'b.' || p_target_pkc || ' = :p5 ';

      psqlupdate := 'UPDATE ' || p_target_table || ' a '
                 || 'SET a.shape = :p1 '
                 || 'WHERE a.' || p_target_pkc || ' = :p2 ';

      psqldelete := 'DELETE FROM ' || p_target_table || ' a '
                 || 'WHERE a.' || p_target_pkc || ' = :p1 ';

      IF twoidz.COUNT = 2
      THEN

         --append new record geom to seed record if they dont interact
         --would like to do this in a single SQL update statement
         --return when more time

         BEGIN

            EXECUTE IMMEDIATE psqlappend INTO workingblob USING 'ANYINTERACT',
                                                                p_tolerance,
                                                                'FALSE',
                                                                twoidz(1),
                                                                twoidz(2);

         EXCEPTION
         WHEN OTHERS
         THEN

            IF SQLERRM LIKE '%Subscript outside of limit%'
            THEN

               --max ordinates is 1048576 in 11g and 12c oracle spatial
               RAISE_APPLICATION_ERROR(-20001, 'Broke ordinate ceiling appending '
                                            || p_target_pkc || ' ' || twoidz(1) ||
                                            ' to ' ||  twoidz(2) || ' in table ' || p_target_table);

            ELSE

               RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' appending '
                                            || p_target_pkc || ' ' || twoidz(1) ||
                                            ' to ' ||  twoidz(2) || ' in table ' || p_target_table);

            END IF;

         END;

         IF workingblob IS NOT NULL
         THEN

            --update numero uno
            EXECUTE IMMEDIATE psqlupdate USING workingblob,
                                               twoidz(1);

            --delete unlucky numero dos
            EXECUTE IMMEDIATE psqldelete USING twoidz(2);

            COMMIT;

         ELSE

            --current state is valid, can hopefully be eyeballed and fixed

            RAISE_APPLICATION_ERROR(-20001, p_target_pkc || ' ' || twoidz(1) ||
                                            ' in table ' || p_target_table ||
                                            ' spatially interacts with ' || twoidz(2));

         END IF;

         IF curr_depth <= max_depth
         THEN

            --get two fresh baby polygons for the geometric slaughtering
            GIS_UTILS.ROLLUPTABLE(p_target_table,
                                  p_target_clause,
                                  p_target_pkc,
                                  p_tolerance,
                                  curr_depth,
                                  max_depth);
         ELSE

            RAISE_APPLICATION_ERROR(-20001, 'Deadman switch, we are ' || curr_depth || ' recursive calls down');

         END IF;

      ELSE

          --the bottom of the recursive stack
          --we have appended all into a single record
          RETURN;

      END IF;

   END ROLLUPTABLE;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------
   
   PROCEDURE PROCESSTABLEON (
      p_process         IN VARCHAR2 DEFAULT 'AGGREGATETABLE',
      p_target_table    IN VARCHAR2,
      p_process_col     IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS
   
      --mschell 20160818
      
      --wrapper to aggregatetable, dissolvetable, or rolluptable
      --repeatedly calls those two on a distinct column value
      --for example, given counties, create states by
      --dissolving counties on their state column
      --CALL GIS_UTILS.PROCESSTABLEON('DISSOLVETABLE','COUNTIES','STATEFP');
      
      --reminder - dissolvetable and rolluptable will maintain the input 
      --   process column in the output record (theres a seed record)
      --aggregatetable will not, the output processing column will be null
      --so dissolve, then rollup, if the processing column needs to persist
      
      psql              VARCHAR2(4000);
      datatype          VARCHAR2(32);
      processvalz       GIS_UTILS.stringarray;
      processclause     VARCHAR2(4000);
   
   BEGIN
   
      IF p_process NOT IN ('DISSOLVETABLE', 'ROLLUPTABLE', 'AGGREGATETABLE')
      THEN
      
         RAISE_APPLICATION_ERROR(-20001, 'Sorry, no code for process ' || p_process);
      
      END IF;

      psql := 'SELECT a.data_type '
           || 'FROM '
           || 'user_tab_cols a '
           || 'WHERE '
           || 'a.table_name = :p1 AND '
           || 'a.column_name = :p2 ';
           
      EXECUTE IMMEDIATE psql INTO datatype USING UPPER(p_target_table),
                                                 UPPER(p_process_col);
      
      --these vals are going to dynamic SQL, they are chars atm
      psql := 'SELECT DISTINCT TO_CHAR(a.' || p_process_col || ') '
           || 'FROM '
           || p_target_table || ' a ';
          
      IF p_target_clause IS NOT NULL
      THEN

         --reminder: where clauses should be inbound like:
         --q'^a.state IN ('36','34')^'
         psql := psql || 'WHERE ' || p_target_clause;

      END IF;
      
      EXECUTE IMMEDIATE psql BULK COLLECT INTO processvalz;
      
      FOR i IN 1 .. processvalz.COUNT
      LOOP
         
         IF datatype LIKE '%CHAR%'
         OR datatype = 'CLOB'
         THEN
         
             processclause := 'a.' || p_process_col || ' = ''' || processvalz(i) || ''' ';
             
         ELSIF datatype = 'NUMBER'
         OR datatype = 'PLS_INTEGER'
         THEN
         
            processclause := 'a.' || p_process_col || ' = ' || processvalz(i) || ' ';
         
         ELSE
         
            RAISE_APPLICATION_ERROR(-20001, 'Sorry I dont know how to process on column '
                                         || p_target_table || '.' || p_process_col || ' '
                                         || 'with data type ' || datatype);
         
         END IF;
         
         IF p_target_clause IS NOT NULL
         THEN

            processclause := processclause || 'AND ' || p_target_clause;

         END IF;
      
         psql := 'BEGIN '
              || 'GIS_UTILS.' || p_process || '(:p1,:p2,:3,:p4); '
              || 'END;';
         
         EXECUTE IMMEDIATE psql USING p_target_table,
                                      processclause,
                                      p_target_pkc,
                                      p_tolerance;      
      
      END LOOP;
      
   END PROCESSTABLEON;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------

   PROCEDURE REMOVEHOLESTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS

      --mschell! 20160624

      psql              VARCHAR2(4000);


   BEGIN

      psql := 'UPDATE ' || p_target_table || ' a '
           || 'SET '
           || 'a.shape = GIS_UTILS.remove_holes(a.shape, :p1) ';

      IF p_target_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_target_clause;

      END IF;

      BEGIN

         EXECUTE IMMEDIATE psql USING p_tolerance;
         COMMIT;

      EXCEPTION
      WHEN OTHERS
      THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

      END;

   END REMOVEHOLESTABLE;

   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------
    PROCEDURE COPYRECORDS (
      p_src_table       IN VARCHAR2,
      p_dest_table      IN VARCHAR2,
      p_where_clause    IN VARCHAR2 DEFAULT NULL
   )
   AS

      --mschell! 20160620
      --when editing, step 1 is often copy an existing dataset to a new name
      --(optionally with whereclause) then hack away at it

      psql              VARCHAR2(4000);
      colz              GIS_UTILS.stringarray;
      schema_tab        GIS_UTILS.stringarray;

   BEGIN

      --src may be remote
      --destination may not since we are performing ddl on it (not here exactly)

      IF INSTR(p_dest_table, '.') > 0
      THEN

         raise_application_error(-20001, 'Sorry dudely, not set up to copy to remote '
                                      || 'table ' || p_dest_table);

      END IF;

      psql := 'SELECT a.column_name '
           || 'FROM ';

      IF INSTR(p_src_table, '.') > 0
      THEN

         psql := psql ||'all_tab_cols a ';

      ELSE

         psql := psql ||'user_tab_cols a ';

      END IF;

      --not checking types here.  Counting on these layers to be created
      --by my code with fixed types.  Thats what we are copying
      --any add-on junk from ESRI or edits we ignore
      psql := psql || 'INNER JOIN '
                   || 'user_tab_cols b '
                   || 'ON a.column_name = b.column_name '
                   || 'WHERE '
                   || 'a.table_name = :p1 AND ';

      IF INSTR(p_src_table, '.') > 0
      THEN

         psql := psql || 'a.owner = :p2 AND ';

      END IF;

      psql := psql || 'b.table_name = :p3 AND '
                   || 'a.column_name NOT LIKE :p4 AND '
                   || 'b.column_name not like :p5 '
                   || 'ORDER BY a.column_id ';

      IF INSTR(p_src_table, '.') > 0
      THEN

         schema_tab := GIS_UTILS.SPLIT(UPPER(p_src_table), '\.');

         EXECUTE IMMEDIATE psql BULK COLLECT INTO colz USING schema_tab(2),
                                                             schema_tab(1),
                                                             UPPER(p_dest_table),
                                                             'SYS%',
                                                             'SYS%';

      ELSE

         EXECUTE IMMEDIATE psql BULK COLLECT INTO colz USING UPPER(p_src_table),
                                                             UPPER(p_dest_table),
                                                             'SYS%',
                                                             'SYS%';

      END IF;

      IF colz.COUNT = 0
      THEN

         raise_application_error(-20001, 'Didnt get any matching columns using ' || psql);

      END IF;

      psql := 'INSERT INTO ' || p_dest_table || ' (';

      FOR i IN 1 .. colz.COUNT
      LOOP

         psql := psql || colz(i);

         IF i <> colz.COUNT
         THEN

            psql := psql || ', ';

         ELSE

            psql := psql || ') SELECT ';

         END IF;

      END LOOP;

      FOR i IN 1 .. colz.COUNT
      LOOP

         psql := psql || 'a.' || colz(i);

         IF i <> colz.COUNT
         THEN

            psql := psql || ', ';

         ELSE

            psql := psql || ' FROM ';

         END IF;

      END LOOP;

      psql := psql || p_src_table || ' a ';

      IF p_where_clause IS NOT NULL
      THEN

         psql := psql || 'WHERE ' || p_where_clause;

      END IF;

      BEGIN

         EXECUTE IMMEDIATE psql;
         COMMIT;

      EXCEPTION
      WHEN OTHERS
      THEN

         RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);

      END;

   END COPYRECORDS;
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------
   
   PROCEDURE ANNEXRECORD (
      p_src_table       IN VARCHAR2,
      p_annexing_id     IN NUMBER,
      p_annexed_id      IN NUMBER,
      p_pkc_col         IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS
      
      --mschell! 20160817
      --one record absorbs territory of another, deleting the absorbee
      --columns other than primary key and geometry ignored
       
      psql              VARCHAR2(4000);
   
   BEGIN
   
      psql := 'UPDATE ' || p_src_table || ' a '
           || 'SET '
           || 'a.shape = ('
           || '   SELECT sdo_geom.SDO_UNION(aa.shape, bb.shape, :p1) '
           || '   FROM '
           ||     p_src_table || ' aa, '
           ||     p_src_table || ' bb '
           || '   WHERE '
           || '   aa.' || p_pkc_col || ' = :p2 AND '
           || '   bb.' || p_pkc_col || ' = :p3) '
           || 'WHERE a.' || p_pkc_col || ' = :p4 ';

      EXECUTE IMMEDIATE psql USING p_tolerance,
                                   p_annexing_id,
                                   p_annexed_id,
                                   p_annexing_id;
   
      psql := 'DELETE FROM ' 
           || p_src_table || ' a '
           || 'WHERE '
           || 'a.' || p_pkc_col || ' = :p1 ';

      EXECUTE IMMEDIATE psql USING p_annexed_id;
      
      COMMIT;
   
   END ANNEXRECORD;


   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------
   
   PROCEDURE DISSOLVESLIVERSTABLE (
      p_src_table       IN VARCHAR2,
      p_areathreshhold  IN NUMBER,
      p_whereclause     IN VARCHAR2 DEFAULT NULL,
      p_pkc_col         IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   )
   AS
   
      --mschell! 20160817
      --merge polygons below an area threashhold into larger neighbors
      --useful after clipping to land or water
      
      --a typical workflow might be like
      --get rid of totally too small records, like smaller than my 6x8 cubicle
      --   begin
      --      gis_utils.DISSOLVESLIVERSTABLE('CLIPPEDTABLE_SDO_2263_1',48);
      --    end;
      --eyeball what remains
      --   SELECT a.objectid, sdo_geom.sdo_area(a.shape, .0005) from CLIPPEDTABLE_SDO_2263_1 a
      --   ORDER BY sdo_geom.sdo_area(a.shape, .0005) ASC
      --Call one by one, skipping legit bits as necessary.  
      --Some legit, visible bits can be smaller than very long invisible slivers
      --   begin
      --      gis_utils.DISSOLVESLIVERSTABLE('CLIPPEDTABLE_SDO_2263_1',100,'a.objectid = 1337');
      --   end;     
      
      psql              VARCHAR2(4000);
      smallz            GIS_UTILS.numberarray;
      bigz              GIS_UTILS.numberarray;
      biggest           NUMBER;      
      recurse           PLS_INTEGER := 0;
      successes         PLS_INTEGER := 0;
      
   BEGIN
   
      psql := 'SELECT a.' || p_pkc_col || ' ' 
           || 'FROM ' || p_src_table || ' a ' 
           || 'WHERE '
           || 'sdo_geom.SDO_AREA(a.shape, :p1) < :p2 ';
           
      IF p_whereclause IS NOT NULL
      THEN
      
         psql := psql || ' AND ' || p_whereclause || ' ';
      
      END IF;
      
      psql := psql || 'ORDER BY sdo_geom.SDO_AREA(a.shape, :p3) ASC ';
           
      EXECUTE IMMEDIATE psql BULK COLLECT INTO smallz USING p_tolerance,
                                                            p_areathreshhold,
                                                            p_tolerance;
                    
      psql := 'WITH '
           || 'candidates AS ' 
           || '    ( '
           || '    SELECT MAX(sdo_geom.SDO_AREA(a.shape, :p1)) area ' 
           || '    FROM ' || p_src_table || ' a '
           || '    WHERE '
           || '    SDO_RELATE(a.shape, '
           || '               (SELECT b.shape FROM ' || p_src_table || ' b WHERE b.objectid = :p2), '
           || '               :p3) = :p4 '
           || '    AND a.objectid <> :p5 '
           || '    AND sdo_geom.SDO_AREA(a.shape, :p6) > :p7 '
           || '    ), '
           || 'candidates2 AS '
           || '    ( '
           || '    SELECT a.' || p_pkc_col || ', SDO_GEOM.SDO_AREA (a.shape, :p8) area ' 
           || '    FROM ' || p_src_table || ' a '
           || '    WHERE '
           || '    SDO_RELATE(a.shape, '
           || '               (SELECT b.shape FROM ' || p_src_table || ' b WHERE b.objectid = :p9), '
           || '               :p10) = :p11 '
           || '    AND a.objectid <> :p12 '
           || '    AND sdo_geom.SDO_AREA(a.shape, :p13) > :p14 '
           || '    ) '
           || 'SELECT candidates2.objectid '
           || 'FROM '
           || 'candidates2, candidates '
           || 'WHERE candidates.area = candidates2.area ';
                                                    
      FOR i IN 1 .. smallz.COUNT
      LOOP
              
         BEGIN
         
            biggest := NULL; 
         
            EXECUTE IMMEDIATE psql INTO biggest USING p_tolerance,
                                                      smallz(i),
                                                      'mask=ANYINTERACT',
                                                      'TRUE',
                                                      smallz(i),
                                                      p_tolerance,
                                                      p_areathreshhold,
                                                      p_tolerance,
                                                      smallz(i),
                                                      'mask=ANYINTERACT',
                                                      'TRUE',
                                                      smallz(i),
                                                      p_tolerance,
                                                      p_areathreshhold;
                                                      
         EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
         
            --Could be a cluster of smalls, 
            --or a small cut off from bigs by other smalls
            --try again later
            recurse := 1;
            biggest := NULL;         
         
         WHEN OTHERS
         THEN
       
            RAISE_APPLICATION_ERROR(-20001, SQLERRM || ' on ' || psql);
            
         END;
         
         IF biggest IS NOT NULL
         THEN
         
            GIS_UTILS.ANNEXRECORD(p_src_table,
                                  biggest,
                                  smallz(i));
                                  
            successes := successes + 1;
                              
         END IF;
                                                   
      END LOOP;
      
     IF recurse = 1
     AND successes > 0
     THEN
     
        GIS_UTILS.DISSOLVESLIVERSTABLE(p_src_table,
                                       p_areathreshhold,
                                       p_whereclause,
                                       p_pkc_col,
                                       p_tolerance);
     
     END IF;

   END DISSOLVESLIVERSTABLE;
   
   
   ------------------------------------------------------------------------------------
   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   ------------------------------------------------------------------------------------


END GIS_UTILS;