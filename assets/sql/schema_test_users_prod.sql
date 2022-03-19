-- test data

INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'customer', true, '+39328000001');

INSERT INTO openpudo.tb_user_preferences (user_id, create_tms, update_tms, show_phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', true);

INSERT INTO openpudo.tb_user_profile (user_id, create_tms, update_tms, first_name, last_name, profile_pic_id) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Test', 'User', NULL);

SELECT pg_catalog.setval('openpudo.tb_user_user_id_seq', 1000, true);


-- maintenance
VACUUM FULL ANALYZE;
