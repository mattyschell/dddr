CREATE OR REPLACE PACKAGE GIS_UTILS
AUTHID CURRENT_USER
AS

   TYPE geomarray IS TABLE OF SDO_GEOMETRY
   INDEX BY PLS_INTEGER;

   TYPE numberarray IS TABLE OF NUMBER
   INDEX BY PLS_INTEGER;

   TYPE stringarray IS TABLE OF VARCHAR2(4000)
   INDEX BY PLS_INTEGER;
   
   TYPE stringhash32 IS TABLE OF VARCHAR2(32)
   INDEX by VARCHAR2(32);

   PROCEDURE DUMMY (
      the_letter_a      IN VARCHAR2
   );

   FUNCTION QUERY_DELIMITED_LIST (
     p_input     IN GIS_UTILS.stringarray,
     p_query     IN NUMBER
   ) RETURN NUMBER DETERMINISTIC;

   FUNCTION SPLIT (
      p_str   IN VARCHAR2,
      p_regex IN VARCHAR2 DEFAULT NULL,
      p_match IN VARCHAR2 DEFAULT NULL,
      p_end   IN NUMBER DEFAULT 0
   ) RETURN GIS_UTILS.stringarray DETERMINISTIC;

   PROCEDURE DROP_TABLE (
      p_table_name      IN VARCHAR2,
      p_noexists_error  IN VARCHAR2 DEFAULT 'Y'
   );

   PROCEDURE DROP_VIEW (
      p_view_name       IN VARCHAR2,
      p_noexists_error  IN VARCHAR2 DEFAULT 'Y'
   );

   PROCEDURE DROP_SEQUENCE (
      p_sequence_name   IN VARCHAR2,
      p_noexists_error  IN VARCHAR2 DEFAULT 'Y'
   );

   FUNCTION TABLE_EXISTS (
      p_table_name      IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE ASSERT_TABLE_EXISTS (
      p_table_name     IN VARCHAR2
   );

   FUNCTION SEQUENCE_EXISTS (
      p_sequence_name      IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE ASSERT_SEQUENCE_EXISTS (
      p_sequence_name      IN VARCHAR2
   );

   FUNCTION SPATIAL_INDEX_EXISTS (
      p_table_name         IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE GRANT_PRIVS (
      p_object_name        IN VARCHAR2,
      p_grantee            IN VARCHAR2,
      p_priv               IN VARCHAR2 DEFAULT 'SELECT',
      p_grantee_errors     IN VARCHAR2 DEFAULT 'N'
   );

   PROCEDURE COMPILE_VIEW (
      p_view_name       IN VARCHAR2
   );

   PROCEDURE REWIRE_VIEW (
      p_view                IN VARCHAR2,
      p_current_table       IN VARCHAR2,
      p_new_table           IN VARCHAR2
   );

   PROCEDURE TRANSFORM_TABLE (
      p_table_name         IN VARCHAR2,
      p_srid               IN NUMBER,
      p_column_name        IN VARCHAR2 DEFAULT 'SHAPE',
      p_depth              IN NUMBER DEFAULT 1
   );

   PROCEDURE SET_SRID (
      p_table_name      IN VARCHAR2,
      p_srid            IN NUMBER,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE'
   );

   PROCEDURE INSERT_SDOGEOM_METADATA (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2,
      p_srid            IN NUMBER,
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_3d              IN VARCHAR2 DEFAULT 'N'
   );

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
   );

   PROCEDURE DROP_SPATIAL_INDEX (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE',
      p_metadata        IN VARCHAR2 DEFAULT 'Y'
   );

   PROCEDURE ADD_INDEX (
      p_table_name      IN VARCHAR2,
      p_index_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2,
      p_type            IN VARCHAR2 DEFAULT NULL,
      p_parallel        IN NUMBER DEFAULT NULL,
      p_logging         IN VARCHAR2 DEFAULT NULL,
      p_local           IN VARCHAR2 DEFAULT NULL
   );

   PROCEDURE GATHER_TABLE_STATS (
      p_table_name      IN VARCHAR2
   );

   PROCEDURE SET_APPLICATION_INFO (
      p_action             IN VARCHAR2,
      p_client_info        IN VARCHAR2,
      p_module             IN VARCHAR2 DEFAULT NULL
   );

   PROCEDURE ESCAPE_CHAR_REFERENCES (
      p_table_name      IN VARCHAR2,
      p_cs_name         IN VARCHAR2 DEFAULT 'US7ASCII'
   );
   
   FUNCTION PROPERCASE (
      p_text            IN VARCHAR2,
      p_style           IN VARCHAR2 DEFAULT 'CENTERLINE'
   ) RETURN VARCHAR2 DETERMINISTIC;

   FUNCTION DUMP_SDO_SUBELEMENTS (
      geom         IN SDO_GEOMETRY,
      indent       IN VARCHAR2 DEFAULT '',
      concise      IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB;

   FUNCTION DUMP_SDO (
      geom         IN SDO_GEOMETRY,
      indent       IN VARCHAR2 DEFAULT '',
      concise      IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB;

   FUNCTION DUMP_SDO_POINT (
      geom         IN SDO_POINT_TYPE,
      indent       IN VARCHAR2 DEFAULT '',
      concise      IN VARCHAR2 DEFAULT 'N'
   ) RETURN VARCHAR2;

   FUNCTION DUMP_SDO_ELEM (
      geom         IN SDO_ELEM_INFO_ARRAY,
      indent       IN VARCHAR2 DEFAULT '',
      concise      IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB;

   FUNCTION DUMP_SDO_ORDS (
      geom         IN SDO_ORDINATE_ARRAY,
      indent       IN VARCHAR2 DEFAULT '',
      concise      IN VARCHAR2 DEFAULT 'N'
   ) RETURN CLOB;


   FUNCTION ORDINATE_ROUNDER (
      p_geometry                IN SDO_GEOMETRY,
      p_places                  IN PLS_INTEGER DEFAULT 6
   ) RETURN SDO_GEOMETRY DETERMINISTIC;
   
   FUNCTION morton(
       p_column           IN  NATURAL
      ,p_row              IN  NATURAL
   ) RETURN INTEGER DETERMINISTIC;
   
   FUNCTION morton_key(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_x_offset         IN  NUMBER
      ,p_y_offset         IN  NUMBER
      ,p_x_divisor        IN  NUMBER
      ,p_y_divisor        IN  NUMBER
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN INTEGER DETERMINISTIC;

   FUNCTION VALIDATE_GEOMETRY (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_tolerance               IN NUMBER
   ) RETURN BOOLEAN;

   PROCEDURE ASSERT_VALID_GEOM (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_tolerance               IN NUMBER
   );

   FUNCTION FIX_A_INVALID_GEOM (
      p_sdo                     IN MDSYS.SDO_GEOMETRY,
      p_tolerance               IN NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY;

   PROCEDURE FIX_INVALID_GEOM (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2 DEFAULT 'SHAPE',
      p_tolerance               IN NUMBER DEFAULT .0005,
      p_where_clause            IN VARCHAR2 DEFAULT NULL
   );

   FUNCTION HAS_CURVES (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE REMOVE_CURVES (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2 DEFAULT 'SHAPE',
      p_pkc_column              IN VARCHAR2 DEFAULT 'OBJECTID',
      p_arc_tolerance           IN NUMBER DEFAULT .25,
      p_unit                    IN VARCHAR2 DEFAULT 'FOOT',
      p_tolerance               IN NUMBER DEFAULT .0005
   );

   FUNCTION VALIDATE_SHAPETYPE (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_shapetype               IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE ASSERT_VALID_SHAPETYPE (
      p_table_name              IN VARCHAR2,
      p_column                  IN VARCHAR2,
      p_shapetype               IN VARCHAR2
   );

   FUNCTION VALIDATE_OBJECT (
      p_object_name              IN VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE ASSERT_VALID_OBJECT (
      p_object_name             IN VARCHAR2
   );

   FUNCTION VALIDATE_LINES_WITH_CONTEXT (
      p_line                  IN SDO_GEOMETRY,
      p_tolerance             IN NUMBER DEFAULT .05,
      p_which_check           IN VARCHAR2 DEFAULT 'BOTH'
   ) RETURN VARCHAR2;


   FUNCTION VALIDATE_TOUCHING_LINES (
      p_line1                    IN SDO_GEOMETRY,
      p_line2                    IN SDO_GEOMETRY,
      p_tolerance                IN NUMBER DEFAULT .05,
      p_round_digits             IN NUMBER DEFAULT 6
   ) RETURN VARCHAR2;

   FUNCTION GZ_INTERSECTION (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC;

    FUNCTION GZ_LINE_INTERSECTION (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC;

    FUNCTION GZ_LINE_SDO (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER,
      p_operation     IN VARCHAR2
   ) RETURN GIS_UTILS.geomarray DETERMINISTIC;

   FUNCTION GZ_POLY_INTERSECTION (
      p_incoming      IN SDO_GEOMETRY,
      p_clipper       IN SDO_GEOMETRY,
      p_tolerance     IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC;

   FUNCTION INTERSECTION_CENTROID (
      p_incoming        IN SDO_GEOMETRY,
      p_clipper         IN SDO_GEOMETRY,
      p_tolerance       IN NUMBER
   ) RETURN SDO_GEOMETRY DETERMINISTIC;

   FUNCTION COUNT_RINGS (
      p_in_geom         IN SDO_GEOMETRY
   ) RETURN NUMBER DETERMINISTIC;

   FUNCTION GET_GEOM_SET (
      p_table_name      IN VARCHAR2,
      p_column_name     IN VARCHAR2 DEFAULT 'SHAPE',
      p_whereclause     IN VARCHAR2 DEFAULT NULL
   ) RETURN SDO_GEOMETRY_ARRAY DETERMINISTIC;

   FUNCTION REMOVE_HOLES (
      p_input              IN MDSYS.SDO_GEOMETRY,
      p_tolerance          IN NUMBER DEFAULT .0005
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC;
   
   FUNCTION REMOVE_SMALL_HOLES (
      geom_in              IN MDSYS.SDO_GEOMETRY,
      p_area               IN NUMBER,
      p_tolerance          IN NUMBER DEFAULT .0005
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC;

   FUNCTION EXPLODE_POLYGON (
      p_in_geom         IN SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY_ARRAY DETERMINISTIC;

   FUNCTION SIMPLIFY_GEOMETRY (
      p_in_geom         IN SDO_GEOMETRY,
      p_threshhold      IN NUMBER,
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_recursion       IN NUMBER DEFAULT 0
   ) RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC;

   PROCEDURE CLIPTABLE (
      p_target_table    IN VARCHAR2,
      p_clip_table      IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_clip_clause     IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_clip_pkc        IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_clip_type       IN VARCHAR2 DEFAULT 'DIFFERENCE'
   );

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
   );

   PROCEDURE EXPLODETABLE (
      p_target_table    IN VARCHAR2,
      p_target_cols     IN VARCHAR2 DEFAULT 'OBJECTID,SHAPE',
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID'
   );

   PROCEDURE SIMPLIFYTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_threshhold      IN NUMBER DEFAULT .001,
      p_tolerance       IN NUMBER DEFAULT .0005
   );
   
   PROCEDURE AGGREGATETABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   );
   
   PROCEDURE DISSOLVETABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_mask            IN VARCHAR2 DEFAULT 'ANYINTERACT'
   );

   PROCEDURE ROLLUPTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005,
      p_depth           IN NUMBER DEFAULT NULL,
      p_max_depth       IN NUMBER DEFAULT NULL
   );
   
   PROCEDURE PROCESSTABLEON (
      p_process         IN VARCHAR2 DEFAULT 'AGGREGATETABLE',
      p_target_table    IN VARCHAR2,
      p_process_col     IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_target_pkc      IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   );

   PROCEDURE REMOVEHOLESTABLE (
      p_target_table    IN VARCHAR2,
      p_target_clause   IN VARCHAR2 DEFAULT NULL,
      p_tolerance       IN NUMBER DEFAULT .0005
   );

   PROCEDURE COPYRECORDS (
      p_src_table       IN VARCHAR2,
      p_dest_table      IN VARCHAR2,
      p_where_clause    IN VARCHAR2 DEFAULT NULL
   );
   
   PROCEDURE ANNEXRECORD (
      p_src_table       IN VARCHAR2,
      p_annexing_id     IN NUMBER,
      p_annexed_id      IN NUMBER,
      p_pkc_col         IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   );
   
   PROCEDURE DISSOLVESLIVERSTABLE (
      p_src_table       IN VARCHAR2,
      p_areathreshhold  IN NUMBER,
      p_whereclause     IN VARCHAR2 DEFAULT NULL,
      p_pkc_col         IN VARCHAR2 DEFAULT 'OBJECTID',
      p_tolerance       IN NUMBER DEFAULT .0005
   );

END GIS_UTILS;