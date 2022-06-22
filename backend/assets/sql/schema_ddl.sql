-- reset schema
DO 'DECLARE
	rec RECORD;
BEGIN
	FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
		EXECUTE ''DROP TABLE IF EXISTS '' || quote_ident(rec.tablename) || '' CASCADE'';
	END LOOP;
END';


-- anag tables
DROP TABLE IF EXISTS tb_anag_account_type CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_account_type (
	account_type TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_account_type VALUES ('pudo', 1);
INSERT INTO tb_anag_account_type VALUES ('customer', 2);


DROP TABLE IF EXISTS tb_anag_otp_request_type CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_otp_request_type (
	request_type TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_otp_request_type VALUES ('login', 1);


DROP TABLE IF EXISTS tb_anag_relation_type CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_relation_type (
	relation_type TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_relation_type VALUES ('owner', 1);
INSERT INTO tb_anag_relation_type VALUES ('customer', 2);


DROP TABLE IF EXISTS tb_anag_package_status CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_package_status (
	package_status TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_package_status VALUES ('delivered', 1);
INSERT INTO tb_anag_package_status VALUES ('notify_sent', 2);
INSERT INTO tb_anag_package_status VALUES ('notified', 3);
INSERT INTO tb_anag_package_status VALUES ('collected', 4);
INSERT INTO tb_anag_package_status VALUES ('accepted', 5);
INSERT INTO tb_anag_package_status VALUES ('expired', 6);


-- working tables
DROP TABLE IF EXISTS tb_wrk_cron_lock CASCADE;
CREATE TABLE IF NOT EXISTS tb_wrk_cron_lock (
	lock_name TEXT PRIMARY KEY,
	acquired_flag BOOLEAN NOT NULL,
	acquire_tms TIMESTAMP(3) NOT NULL,
	lease_tms TIMESTAMP(3) NOT NULL
);


-- data tables
DROP TABLE IF EXISTS tb_user CASCADE;
CREATE TABLE IF NOT EXISTS tb_user (
	user_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	last_login_tms TIMESTAMP(3) NOT NULL,
	account_type TEXT NOT NULL REFERENCES tb_anag_account_type(account_type),
	test_account_flag BOOLEAN NOT NULL,
	phone_number TEXT NOT NULL
);
CREATE UNIQUE INDEX tb_user_phone_number_idx ON tb_user(phone_number);


DROP TABLE IF EXISTS tb_otp_request CASCADE;
CREATE TABLE IF NOT EXISTS tb_otp_request (
	request_id UUID PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	request_type TEXT NOT NULL REFERENCES tb_anag_otp_request_type(request_type),
	user_id BIGINT REFERENCES tb_user(user_id),
	phone_number TEXT,
	otp TEXT NOT NULL,
	send_count INTEGER NOT NULL,
	CHECK(num_nonnulls(user_id, phone_number) = 1)
);


DROP TABLE IF EXISTS tb_external_file CASCADE;
CREATE TABLE IF NOT EXISTS tb_external_file (
	external_file_id UUID PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	mime_type TEXT NOT NULL
);


DROP TABLE IF EXISTS tb_device_token CASCADE;
CREATE TABLE IF NOT EXISTS tb_device_token (
	device_token TEXT PRIMARY KEY,
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	device_type TEXT,
	system_name TEXT,
	system_version TEXT,
	model TEXT,
	resolution TEXT,
	application_language TEXT,
	last_success_tms TIMESTAMP(3),
	last_success_message_id TEXT,
	last_failure_tms TIMESTAMP(3),
	failure_count INTEGER NOT NULL
);
CREATE INDEX tb_device_token_user_id_idx ON tb_device_token(user_id);


DROP TABLE IF EXISTS tb_user_profile CASCADE;
CREATE TABLE IF NOT EXISTS tb_user_profile (
	user_id BIGINT PRIMARY KEY REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	first_name TEXT,
	last_name TEXT,
	profile_pic_id UUID REFERENCES tb_external_file(external_file_id)
);


DROP TABLE IF EXISTS tb_user_preferences CASCADE;
CREATE TABLE IF NOT EXISTS tb_user_preferences (
	user_id BIGINT PRIMARY KEY REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	show_phone_number BOOLEAN NOT NULL
);


DROP TABLE IF EXISTS tb_pudo CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo (
	pudo_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	business_name TEXT NOT NULL,
	public_phone_number TEXT,
	email TEXT,
	pudo_pic_id UUID REFERENCES tb_external_file(external_file_id),
	business_name_search tsvector GENERATED ALWAYS AS (to_tsvector('simple', business_name)) STORED
);
CREATE INDEX tb_pudo_business_name_search_idx ON tb_pudo USING GIN (business_name_search);


DROP TABLE IF EXISTS tb_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_address (
	pudo_id BIGINT PRIMARY KEY REFERENCES tb_pudo(pudo_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	label TEXT NOT NULL,
	street TEXT NOT NULL,
	street_num TEXT,
	zip_code TEXT,
	city TEXT NOT NULL,
	province TEXT NOT NULL,
	country TEXT NOT NULL,
	lat DECIMAL(10,7) NOT NULL,
	lon DECIMAL(10,7) NOT NULL
);
CREATE INDEX tb_address_lat_lon_idx ON tb_address(lat, lon);


DROP TABLE IF EXISTS tb_reward_policy CASCADE;
CREATE TABLE IF NOT EXISTS tb_reward_policy (
	reward_policy_id BIGSERIAL PRIMARY KEY,
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	create_tms TIMESTAMP(3) NOT NULL,
	delete_tms TIMESTAMP(3),
	free_checked BOOLEAN NOT NULL,
	customer_checked BOOLEAN NOT NULL,
	customer_selectitem TEXT,
	customer_selectitem_text TEXT,
	members_checked BOOLEAN NOT NULL,
	members_text TEXT,
	buy_checked BOOLEAN NOT NULL,
	buy_text TEXT,
	fee_checked BOOLEAN NOT NULL,
	fee_price DECIMAL(3,2)
);
CREATE INDEX tb_reward_policy_pudo_id_idx ON tb_reward_policy(pudo_id);
CREATE UNIQUE INDEX tb_reward_policy_pudo_id_delete_tms_idx ON tb_reward_policy(pudo_id) WHERE delete_tms IS NULL;


DROP TABLE IF EXISTS tb_user_pudo_relation CASCADE;
CREATE TABLE IF NOT EXISTS tb_user_pudo_relation (
	user_pudo_relation_id BIGSERIAL PRIMARY KEY,
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	create_tms TIMESTAMP(3) NOT NULL,
	delete_tms TIMESTAMP(3),
	relation_type TEXT NOT NULL REFERENCES tb_anag_relation_type(relation_type),
	customer_suffix TEXT
);
CREATE INDEX tb_user_pudo_relation_user_id_pudo_id_idx ON tb_user_pudo_relation(user_id, pudo_id);
CREATE UNIQUE INDEX tb_user_pudo_relation_user_id_pudo_id_delete_tms_idx ON tb_user_pudo_relation(user_id, pudo_id) WHERE delete_tms IS NULL;


DROP TABLE IF EXISTS tb_package CASCADE;
CREATE TABLE IF NOT EXISTS tb_package (
	package_id BIGSERIAL PRIMARY KEY,
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	package_pic_id UUID REFERENCES tb_external_file(external_file_id)
);
CREATE INDEX tb_package_pudo_id_idx ON tb_package(pudo_id);
CREATE INDEX tb_package_user_id_idx ON tb_package(user_id);


DROP TABLE IF EXISTS tb_package_event CASCADE;
CREATE TABLE IF NOT EXISTS tb_package_event (
	package_event_id BIGSERIAL PRIMARY KEY,
	package_id BIGINT NOT NULL REFERENCES tb_package(package_id),
	create_tms TIMESTAMP(3) NOT NULL,
	package_status TEXT NOT NULL REFERENCES tb_anag_package_status(package_status),
	auto_flag BOOLEAN NOT NULL,
	notes TEXT
);
CREATE UNIQUE INDEX tb_package_event_package_id_idx ON tb_package_event(package_id, create_tms);
CREATE INDEX tb_package_event_package_status_idx ON tb_package_event(package_status);


DROP TABLE IF EXISTS tb_review CASCADE;
CREATE TABLE IF NOT EXISTS tb_review (
	review_id BIGSERIAL PRIMARY KEY,
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	package_id BIGINT NOT NULL REFERENCES tb_package(package_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3),
	title TEXT NOT NULL,
	message TEXT NOT NULL,
	score SMALLINT NOT NULL,
	review_pic_id UUID REFERENCES tb_external_file(external_file_id)
);
CREATE INDEX tb_review_user_id_idx ON tb_review(user_id);
CREATE INDEX tb_review_pudo_id_idx ON tb_review(pudo_id);
CREATE UNIQUE INDEX tb_review_package_id_idx ON tb_review(package_id);


DROP TABLE IF EXISTS tb_rating CASCADE;
CREATE TABLE IF NOT EXISTS tb_rating (
	pudo_id BIGINT PRIMARY KEY REFERENCES tb_pudo(pudo_id),
	review_count BIGINT NOT NULL,
	average_score DECIMAL(3,2)
);


DROP TABLE IF EXISTS tb_notification CASCADE;
CREATE TABLE IF NOT EXISTS tb_notification (
	notification_id BIGSERIAL PRIMARY KEY,
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	queued_flag BOOLEAN NOT NULL,
	due_tms TIMESTAMP(3) NOT NULL,
	read_tms TIMESTAMP(3),
	title TEXT NOT NULL,
	title_params TEXT,
	message TEXT NOT NULL,
	message_params TEXT
);
CREATE INDEX tb_notification_user_id_idx ON tb_notification(user_id);
CREATE INDEX tb_notification_queued_flag_idx ON tb_notification(queued_flag);


DROP TABLE IF EXISTS tb_notification_package CASCADE;
CREATE TABLE IF NOT EXISTS tb_notification_package (
	notification_id BIGINT PRIMARY KEY REFERENCES tb_notification(notification_id),
	package_id BIGINT NOT NULL REFERENCES tb_package(package_id)
);


DROP TABLE IF EXISTS tb_notification_favourite CASCADE;
CREATE TABLE IF NOT EXISTS tb_notification_favourite (
	notification_id BIGINT PRIMARY KEY REFERENCES tb_notification(notification_id),
	customer_user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id)
);
CREATE INDEX tb_notification_favourite_customer_user_id_idx ON tb_notification_favourite(customer_user_id);
CREATE INDEX tb_notification_favourite_pudo_id_idx ON tb_notification_favourite(pudo_id);


DROP TABLE IF EXISTS tb_redirect_log CASCADE;
CREATE TABLE IF NOT EXISTS tb_redirect_log (
	redirect_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	channel TEXT NOT NULL,
	remote_address TEXT,
	user_agent TEXT
);


DROP TABLE IF EXISTS tb_deleted_user_data CASCADE;
CREATE TABLE IF NOT EXISTS tb_deleted_user_data (
	user_data_id UUID PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	user_data TEXT
);


-- views
DROP VIEW IF EXISTS vw_customer;
CREATE OR REPLACE VIEW vw_customer AS
SELECT u.user_id, u.create_tms, u.last_login_tms, u.phone_number, up.update_tms profile_update_tms, up.first_name, up.last_name, up.profile_pic_id
FROM tb_user u, tb_user_profile up
WHERE u.user_id = up.user_id
AND u.account_type = 'customer';

DROP VIEW IF EXISTS vw_pudo;
CREATE OR REPLACE VIEW vw_pudo AS
SELECT u.user_id, u.create_tms, u.last_login_tms, u.phone_number, p.pudo_id, p.update_tms pudo_update_tms, p.business_name, p.public_phone_number, p.email, p.pudo_pic_id, a.label
FROM tb_user u, tb_user_pudo_relation upr, tb_pudo p, tb_address a
WHERE u.user_id = upr.user_id AND upr.pudo_id = p.pudo_id AND p.pudo_id = a.pudo_id
AND u.account_type = 'pudo'
AND upr.relation_type = 'owner';

DROP VIEW IF EXISTS vw_package_status;
CREATE OR REPLACE VIEW vw_package_status AS
SELECT pa.package_id, pa.create_tms, pa.update_tms, pa.pudo_id, pu.business_name, pa.user_id, up.first_name || ' ' || up.last_name customer_name, pae.package_event_id, pae.package_status, pae.notes
FROM tb_package pa, tb_package_event pae, tb_user_profile up, tb_pudo pu
WHERE pa.package_id = pae.package_id
AND pa.user_id = up.user_id
AND pa.pudo_id = pu.pudo_id
AND pae.create_tms = (SELECT MAX(pae2.create_tms) FROM tb_package_event pae2 WHERE pae2.package_id = pa.package_id);

DROP VIEW IF EXISTS vw_pudo_customer;
CREATE OR REPLACE VIEW vw_pudo_customer AS
SELECT p.pudo_id, p.business_name, a.label, u.user_id, up.first_name || ' ' || up.last_name customer_name, upr.user_pudo_relation_id, upr.create_tms, upr.customer_suffix
FROM tb_user u, tb_user_profile up, tb_user_pudo_relation upr, tb_pudo p, tb_address a
WHERE u.user_id = up.user_id AND u.user_id = upr.user_id AND upr.pudo_id = p.pudo_id AND p.pudo_id = a.pudo_id AND upr.delete_tms IS NULL
AND u.account_type = 'customer'
AND upr.relation_type = 'customer';

-- maintenance
VACUUM FULL ANALYZE;
