t:

cd "\GIS\Internal\Software\ESRI\ArcSDE93\bin"

echo Using instance %1.doitt.nycnet with password %2

sdelayer -o register -l tax_lot_polygon_sdo,shape -e a+ -C objectid,SDE -i sde:oracle10g:/:DOF_TAXMAP;LOCAL=%1.doitt.nycnet -u dof_taxmap -p %2 -t SDO_GEOMETRY -P HIGH

sdetable -o create_view -T V_EVERY_BBL -t tax_lot_polygon_sdo,every_bbl_mv -c "tax_lot_polygon_sdo.objectid,tax_lot_polygon_sdo.shape,every_bbl_mv.boro,every_bbl_mv.block,every_bbl_mv.lot,every_bbl_mv.bbl,every_bbl_mv.map_bbl,every_bbl_mv.title,every_bbl_mv.effective_tax_year" -w "tax_lot_polygon_sdo.bbl=every_bbl_mv.map_bbl"  -i sde:oracle10g:/:DOF_TAXMAP -u dof_taxmap -p %2@%1.doitt.nycnet

sdetable -o create_view -T SUBTERRANEAN_LOTS_V -t tax_lot_polygon_sdo,subterranean_lots -c "tax_lot_polygon_sdo.objectid,tax_lot_polygon_sdo.shape,subterranean_lots.appurtenant_boro,subterranean_lots.appurtenant_block,subterranean_lots.appurtenant_lot,subterranean_lots.appurtenant_bbl,subterranean_lots.subterranean_lot_number,subterranean_lots.effective_tax_year,subterranean_lots.appurtenant_boro||lpad(subterranean_lots.appurtenant_block,5,0)||lpad(subterranean_lots.subterranean_lot_number,4,0)" -a objectid,shape,appurtenant_boro,appurtenant_block,appurtenant_lot,appurtenant_bbl,subterranean_lot_number,effective_tax_year,bbl -w "tax_lot_polygon_sdo.bbl=subterranean_lots.appurtenant_bbl"  -i sde:oracle10g:/:DOF_TAXMAP -u dof_taxmap -p %2@%1.doitt.nycnet
