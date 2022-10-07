-- test data
INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'customer', true, '+39328000001');
INSERT INTO openpudo.tb_user_preferences (user_id, create_tms, update_tms, show_phone_number) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', true);
INSERT INTO openpudo.tb_user_profile (user_id, create_tms, update_tms, first_name, last_name) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Test', 'User');

INSERT INTO openpudo.tb_user (user_id, create_tms, last_login_tms, account_type, test_account_flag, phone_number) VALUES (2, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'pudo', true, '+39328000002');
INSERT INTO openpudo.tb_pudo (pudo_id, create_tms, update_tms, business_name, public_phone_number, email) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Bar La Pinta', NULL, 'foo@bar.com');
INSERT INTO openpudo.tb_address (pudo_id, create_tms, update_tms, label, street, street_num, zip_code, city, province, country, lat, lon) VALUES (1, '2022-01-17 12:30:00.000', '2022-01-17 12:30:00.000', 'Via Alessandro Bisnati 4, Milano, MI, Italia', 'Via Alessandro Bisnati', '4', '20161', 'Milano', 'Milano', 'Italia', 45.5229090, 9.1748640);
INSERT INTO openpudo.tb_reward_policy (reward_policy_id, pudo_id, create_tms, delete_tms, free_checked, customer_checked, customer_selectitem, customer_selectitem_text, members_checked, members_text, buy_checked, buy_text, fee_checked, fee_price) VALUES (1, 1, '2022-01-17 12:30:00.000', NULL, true, false, NULL, NULL, false, NULL, false, NULL, false, NULL);
INSERT INTO openpudo.tb_rating (pudo_id, review_count, average_score) VALUES (1, 0, NULL);
INSERT INTO openpudo.tb_user_pudo_relation (user_pudo_relation_id, user_id, pudo_id, create_tms, delete_tms, relation_type, customer_suffix) VALUES (1, 2, 1, '2022-01-17 12:30:00.000', NULL, 'owner', NULL);

SELECT pg_catalog.setval('openpudo.tb_user_user_id_seq', 1000, true);
SELECT pg_catalog.setval('openpudo.tb_pudo_pudo_id_seq', 1000, true);
SELECT pg_catalog.setval('openpudo.tb_reward_policy_reward_policy_id_seq', 1000, true);
SELECT pg_catalog.setval('openpudo.tb_user_pudo_relation_user_pudo_relation_id_seq', 1000, true);
