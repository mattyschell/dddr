# dddr

DOF Digital Taxmap Replacement

## Packages

#### Package Inventory

| Package Name | Source | File Name | Notes |
| --- | --- | --- | --- |
| PKG_ALTERATION_BOOK | SVN | package.sql | 2012, does not include PROC_GET_HAB_LIST |
| PKG_ALTERATION_BOOK | SVN | hab_pkg_*.sql | 2014, USE THIS ONE |
| PKG_ALTERATION_BOOK | Prod Schema | NA | Perfect match with hab_pkg_[body|spec].sql |
| PKG_MAP_DISPLAY | Prod Schema | NA | Similar to pkg_alteration_book, no body in prod. Ignore | 
| PKG_DTM_REPORTS | Prod Schema | NA | Includes 2 procedures also in pkg_alteration_book. Ignore | 



#### Package Table Dependencies

All are already included in https://github.com/mattyschell/geodatabase-taxmap-toiler which migrates everything except outputs of the ETL and reference data.

| Table Name | Included? |
| ---- | ---- |
| dab_action_definition | Y |
| dab_air_rights | Y |
| dab_air_rights_definition | Y |
| dab_boundary_line | Y |
| dab_condo_conversion | Y |
| dab_condo_units | Y |
| dab_domains | Y |
| dab_reuc | Y |
| dab_subterranean_rights | Y |
| dab_tax_lots | Y |
| dab_wizard_transaction | Y |
| hab | Y |
| map_inset_library | Y |
| map_library | Y |
| tax_block_polygon | Y | 

#### Package Install and Verification

As DOF_TAXMAP (untested, hacked here for now)

```
sqlplus dof_taxmap/iluvesri247@gisdb @compilepackages.sql
```

Test, as MAP_VIEWER:


```sql
declare
   type testcursor is ref cursor;
   boros testcursor;
begin
    dof_taxmap.PKG_ALTERATION_BOOK.PROC_GET_BOROS(boros);
    DBMS_SQL.RETURN_RESULT(boros); 
end;
```

## Application Database Dependencies

#### DOF_TAXMAP schema

All data not already migrated with https://github.com/mattyschell/geodatabase-taxmap-toiler that is not obviously junk or geodatabase administrator configuration.

| Table Name | Spatial | Notes |
| ---- | ---- | ---- | 
| CONDO_LABEL | N | |
| CSCL_CENTERLINE | Y | |
| FINAL_ASMT | N | What is this? |
| HYDRO | Y |  |
| LAND | Y |  |
| LOCATORS | N | empty |
| LOT_FACE_POINT | Y | Crashes ESRI software |
| METADATA | N | Empty of course |
| SHORELINE | Y |  | 
| SUB_LABEL | N |  |
| TAX_BLOCK | Y |  |
| TAX_BLOCK_POINT | Y |  |
| TAX_BLOCK_POLYGON_SDO | Y |  |
| TAX_LOT_POINT | Y |  |
| TAX_LOT_POLYGON_SDO | Y |  |
| TRANSPORTATION_STRUCTURE | Y |  |

| View Name | 
| ---- |  
| AIR_RIGHT |
| AIR_RIGHT_LOOKUP |
| CONDOMINIUM |
| CONDO_UNIT |
| SUBTERRANEAN |
| SUBTERRANEAN_LOOKUP |
| SUBTERRANEAN_LOTS_V |
| V_BORO_BLOCK_CHANGES |
| V_CONDO_RANGE |
| V_EVERY_BBL |
| V_LOT_FACE_SMALL |
| V_REUC_LOT |
| V_TAX_LOT_POINT |
