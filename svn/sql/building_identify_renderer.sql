set define off

INSERT INTO ft_data_store_renderer VALUES (1275, 1298, 'N', 'BUILDINGIdentifyRenderer', 'Building', NULL, NULL);

UPDATE spatial_feature_type SET markup_order = 19, min_zoom = 11, max_zoom = 13, user_meta_data_id = 70 WHERE feature_type_id = 1298;

INSERT INTO ft_data_store_rend_field VALUES (13264, 3334, 1275, NULL, 'Y', 'N', 1, '<b>', ':</b>&nbsp;', NULL, '<br/>');

INSERT INTO ft_data_store_rend_field VALUES (13265, 3343, 1275, NULL, 'N', 'N', 2, NULL, NULL, '<b>Name:</b>&nbsp;', '<br/>');

INSERT INTO ft_data_store_rend_field VALUES (13266, 178, 1275, NULL, 'Y', 'N', 3, '<b>', ':</b>&nbsp;', NULL, '<br/>');

INSERT INTO ft_data_store_rend_field VALUES (13267, 3346, 1275, NULL, 'N', 'N', 4, NULL, NULL, '<b>Facility Type:</b>&nbsp;', '<br/>');

INSERT INTO ft_data_store_rend_field VALUES (13268, 3335, 1275, NULL, 'Y', 'N', 5, '<b>', ':</b>&nbsp;', NULL, '&nbsp;feet<br/>');

INSERT INTO ft_data_store_rend_field VALUES (13269, 3333, 1275, NULL, 'Y', 'N', 6, '<b>', ':</b>&nbsp;', NULL, NULL);
