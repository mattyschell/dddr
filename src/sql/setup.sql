create table condo_label (
    bbl varchar2(10) not null enable
   ,label varchar2(200) not null enable
   ,count number not null enable
);
create index cond_bbl_idx ON condo_label ('bbl');
grant select on condo_label to "MAP_VIEWER";
--
create table final_asmt (	
    condo_nm number
   ,boro varchar2(2)
   ,block number
   ,lot number
   ,bldgcl varchar2(2)
   ,ap_bbl_key varchar2(10)
   ,ap_block number
   ,aptno varchar2(5)
);
grant select on final_asmt to "MAP_VIEWER";
--
create table lot_face_point (
    shape mdsys.sdo_geometry, 
	tax_lot_face_type number(*,0), 
	bbl varchar2(10), 
	length number(38,8), 
	approx_length_flag number(*,0), 
	angle number, 
	delta_x number, 
	delta_y number, 
	boro varchar2(1), 
	block number(10,0), 
	lot number(5,0)
); 
create index bbl_idx on lot_face_point('BBL');
grant select on lot_face_point to "MAP_VIEWER";
begin
gis_utils.add_spatial_index('LOT_FACE_POINT'
                           ,'SHAPE'
                           ,41088
                           ,0.0005);
end;
/
--
create table sub_label (
    bbl varchar2(10) not null enable, 
    label varchar2(200) not null enable, 
	"COUNT" number(*,0) not null enable
);
create index sub_bbl_idx on sub_label ("BBL");
grant select on sub_label to "MAP_VIEWER"; 
--
create table tax_block 
   (id number primary key, 
	boro_block varchar2(6) not null enable, 
	boro varchar2(1) not null enable, 
	block varchar2(10) not null enable, 
	label varchar2(25) not null enable, 
	shape mdsys.sdo_geometry
);
begin 
gis_utils.add_spatial_index('TAX_BLOCK'
                            ,'SHAPE'
                            ,41088
                            ,0.0005);
end;
/
-- let import take care of this, something is wacky
--create unique index tax_block_boro_block_idx on tax_block ('BORO_BLOCK');
grant select on tax_block to "MAP_VIEWER"; 
--
create table tax_block_point (
    boro varchar2(1) not null enable, 
	block number(10,0) not null enable, 
	shape mdsys.sdo_geometry 
);
begin
gis_utils.add_spatial_index('TAX_BLOCK_POINT'
                            ,'SHAPE'
                            ,41088
                            ,0.0005);
end;
/
grant select on tax_block_point to "MAP_VIEWER"; 
--
create table tax_lot_point (
    bbl varchar2(10) not null enable, 
	lot number(5,0) not null enable, 
	air_rights_flag char(1), 
	condo_flag char(1), 
	reuc_flag char(1), 
	subterranean_flag char(1), 
	shape mdsys.sdo_geometry , 
	lot_area number(19,1)
);
begin
gis_utils.add_spatial_index('TAX_LOT_POINT'
                            ,'SHAPE'
                            ,41088
                            ,0.0005);
end;
/
create index tax_lot_point_idx on tax_lot_point ('BBL');
grant select on tax_lot_point to "MAP_VIEWER"; 
--
create table tax_lot_polygon_sdo 
   (objectid number(*,0) not null enable, 
	boro varchar2(1) not null enable, 
	block number(10,0) not null enable, 
	lot number(5,0) not null enable, 
	bbl varchar2(10), 
	community_district number(5,0), 
	regular_lot_indicator varchar2(1), 
	number_lot_sides number(5,0), 
	condo_flag varchar2(1), 
	reuc_flag varchar2(1), 
	air_rights_flag varchar2(1), 
	subterranean_flag varchar2(1), 
	easement_flag varchar2(1), 
	section_number number(5,0), 
	volume_number number(5,0), 
	page_number varchar2(15), 
	lot_note varchar2(255), 
	nycmap_bldg_flag number(5,0), 
	missing_rpad_flag number(5,0), 
	conversion_exception_flag number(5,0), 
	value_reflected_out_flag number(5,0), 
	created_by varchar2(50), 
	created_date date,  
	last_modified_by varchar2(50), 
	last_modified_date date, 
	av_change number(5,0), 
	bw_change number(5,0), 
	effective_tax_year varchar2(50), 
	bill_bbl_flag number(5,0), 
	globalid char(38) not null enable, 
	shape mdsys.sdo_geometry 
);
-- if the source is registered with ESRI for no reason
--ALTER TABLE tax_lot_polygon_sdo 
--  ADD SE_ANNO_CAD_DATA BLOB;
begin
gis_utils.add_spatial_index('TAX_LOT_POLYGON_SDO'
                            ,'SHAPE'
                            ,41088
                            ,0.0005);
end;
/
--Something is out of whack here, too.  
-- ESRI and I are both creating keys or something
--create unique index tax_lot_polygon_sdo_uqc on tax_lot_polygon_sdo ('OBJECTID');
create index lot_sdo_bbl_idx on tax_lot_polygon_sdo ('BBL');
grant select on tax_lot_polygon_sdo to "MAP_VIEWER"; 
--
create table transportation_structure (
    objectid number(*,0) not null enable, 
	name varchar2(50), 
	se_anno_cad_data blob,  -- NOOOO
	shape mdsys.sdo_geometry 
);
begin
gis_utils.add_spatial_index('TRANSPORTATION_STRUCTURE'
                            ,'SHAPE'
                            ,41088
                            ,0.0005);
end;
/
-- let imp take care of this, something is off in my workflow here
--create unique index transportation_structure_uqc on transportation_structure ('OBJECTID');
grant select on tax_lot_point to "MAP_VIEWER"; 
