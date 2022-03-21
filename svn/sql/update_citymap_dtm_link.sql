SET DEFINE OFF
UPDATE link SET href = 'http://gis.nyc.gov/taxmap/map.htm?searchType=BblSearch&featureTypeName=EVERY_BBL&featureName=${PLUTO_BBL}' WHERE link_id = 33;
