-- test data exported with
-- pg_dump --username=postgres --dbname=postgres --schema=openpudo --data-only --inserts --column-inserts -t openpudo.tb_user -t openpudo.tb_user_profile -t openpudo.tb_user_preferences -t openpudo.tb_pudo -t openpudo.tb_address -t openpudo.tb_reward_policy -t openpudo.tb_rating -t openpudo.tb_user_pudo_relation

INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'customer', true, '+39328000001');
INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (2, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'pudo', true, '+39328000002');
INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (3, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'pudo', true, '+39328000003');
INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (4, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'pudo', true, '+39328000004');
INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (5, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'pudo', true, '+39328000005');

INSERT INTO openpudo.tb_user_preferences (user_id, create_tms, update_tms, show_phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', true);

INSERT INTO openpudo.tb_user_profile (user_id, create_tms, update_tms, first_name, last_name, profile_pic_id) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Test', 'User', NULL);

INSERT INTO openpudo.tb_pudo (pudo_id, create_tms, update_tms, business_name, public_phone_number, pudo_pic_id, business_name_search) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Bar La Pinta', NULL, NULL, DEFAULT);
INSERT INTO openpudo.tb_pudo (pudo_id, create_tms, update_tms, business_name, public_phone_number, pudo_pic_id, business_name_search) VALUES (2, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Il Paradiso della Porchetta', NULL, NULL, DEFAULT);
INSERT INTO openpudo.tb_pudo (pudo_id, create_tms, update_tms, business_name, public_phone_number, pudo_pic_id, business_name_search) VALUES (3, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Sushi Arigato Restaurant', NULL, NULL, DEFAULT);
INSERT INTO openpudo.tb_pudo (pudo_id, create_tms, update_tms, business_name, public_phone_number, pudo_pic_id, business_name_search) VALUES (4, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Tabacchi Fortunato', NULL, NULL, DEFAULT);

INSERT INTO openpudo.tb_address (pudo_id, create_tms, update_tms, label, street, street_num, zip_code, city, province, country, lat, lon) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Via Alessandro Bisnati 4, Milano, MI, Italia', 'Via Alessandro Bisnati', '4', '20161', 'Milano', 'Milano', 'Italia', 45.5229090, 9.1748640);
INSERT INTO openpudo.tb_address (pudo_id, create_tms, update_tms, label, street, street_num, zip_code, city, province, country, lat, lon) VALUES (2, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Via Sant''Arnaldo 31, Milano, MI, Italia', 'Via Sant''Arnaldo', '31', '20161', 'Milano', 'Milano', 'Italia', 45.5253360, 9.1754220);
INSERT INTO openpudo.tb_address (pudo_id, create_tms, update_tms, label, street, street_num, zip_code, city, province, country, lat, lon) VALUES (3, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Via Alessandro Astesani 29, Milano, MI, Italia', 'Via Alessandro Astesani', '29', '20161', 'Milano', 'Milano', 'Italia', 45.5189650, 9.1702940);
INSERT INTO openpudo.tb_address (pudo_id, create_tms, update_tms, label, street, street_num, zip_code, city, province, country, lat, lon) VALUES (4, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Via Caltagirone 12, Milano, MI, Italia', 'Via Caltagirone', '12', '20161', 'Milano', 'Milano', 'Italia', 45.5244430, 9.1726410);

INSERT INTO openpudo.tb_reward_policy (reward_policy_id, pudo_id, create_tms, delete_tms, free_checked, customer_checked, customer_selectitem, customer_selectitem_text, members_checked, members_text, buy_checked, buy_text, fee_checked, fee_price) VALUES (1, 1, '2022-01-17 12:30:00.000', NULL, true, false, NULL, NULL, false, NULL, false, NULL, false, NULL);
INSERT INTO openpudo.tb_reward_policy (reward_policy_id, pudo_id, create_tms, delete_tms, free_checked, customer_checked, customer_selectitem, customer_selectitem_text, members_checked, members_text, buy_checked, buy_text, fee_checked, fee_price) VALUES (2, 2, '2022-01-17 12:30:00.000', NULL, true, false, NULL, NULL, false, NULL, false, NULL, false, NULL);
INSERT INTO openpudo.tb_reward_policy (reward_policy_id, pudo_id, create_tms, delete_tms, free_checked, customer_checked, customer_selectitem, customer_selectitem_text, members_checked, members_text, buy_checked, buy_text, fee_checked, fee_price) VALUES (3, 3, '2022-01-17 12:30:00.000', NULL, true, false, NULL, NULL, false, NULL, false, NULL, false, NULL);
INSERT INTO openpudo.tb_reward_policy (reward_policy_id, pudo_id, create_tms, delete_tms, free_checked, customer_checked, customer_selectitem, customer_selectitem_text, members_checked, members_text, buy_checked, buy_text, fee_checked, fee_price) VALUES (4, 4, '2022-01-17 12:30:00.000', NULL, true, false, NULL, NULL, false, NULL, false, NULL, false, NULL);

INSERT INTO openpudo.tb_rating (pudo_id, review_count, average_score) VALUES (1, 0, NULL);
INSERT INTO openpudo.tb_rating (pudo_id, review_count, average_score) VALUES (2, 0, NULL);
INSERT INTO openpudo.tb_rating (pudo_id, review_count, average_score) VALUES (3, 0, NULL);
INSERT INTO openpudo.tb_rating (pudo_id, review_count, average_score) VALUES (4, 0, NULL);

INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (1, 2, 1, '2022-01-17 12:30:00.000', NULL, 'owner', NULL);
INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (2, 3, 2, '2022-01-17 12:30:00.000', NULL, 'owner', NULL);
INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (3, 4, 3, '2022-01-17 12:30:00.000', NULL, 'owner', NULL);
INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (4, 5, 4, '2022-01-17 12:30:00.000', NULL, 'owner', NULL);
INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (5, 1, 1, '2022-01-17 12:30:00.000', NULL, 'customer', 'TU825');

SELECT pg_catalog.setval('openpudo.tb_user_user_id_seq', 5, true);
SELECT pg_catalog.setval('openpudo.tb_pudo_pudo_id_seq', 4, true);
SELECT pg_catalog.setval('openpudo.tb_reward_policy_reward_policy_id_seq', 4, true);
SELECT pg_catalog.setval('openpudo.tb_user_pudo_relation_user_pudo_relation_id_seq', 5, true);


-- maintenance
VACUUM FULL ANALYZE;
