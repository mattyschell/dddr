# dddr

DOF Digital Taxmap Replacement

## Package Inventory

| Package Name | Source | File Name | Notes |
| --- | --- | --- | --- |
| PKG_ALTERATION_BOOK | SVN | package.sql | 2012, does not include PROC_GET_HAB_LIST |
| PKG_ALTERATION_BOOK | SVN | hab_pkg_*.sql | 2014, USE THIS ONE |
| PKG_ALTERATION_BOOK | Prod Schema | NA | Perfect match with hab_pkg_[body|spec].sql |
| PKG_MAP_DISPLAY | Prod Schema | NA | Similar to pkg_alteration_book, no body in prod. Ignore | 
| PKG_DTM_REPORTS | Prod Schema | NA | Includes 2 procedures also in pkg_alteration_book. Ignore | 



## Table Dependencies

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