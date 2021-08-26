-- reset schema
DO 'DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE ''DROP TABLE IF EXISTS '' || quote_ident(rec.tablename) || '' CASCADE'';
    END LOOP;
END';


-- anag tables
DROP TABLE IF EXISTS tb_anag_role_type CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_role_type (
	role_type TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_role_type VALUES ('owner', 1);
INSERT INTO tb_anag_role_type VALUES ('customer', 2);


DROP TABLE IF EXISTS tb_anag_package_status CASCADE;
CREATE TABLE IF NOT EXISTS tb_anag_package_status (
	package_status TEXT PRIMARY KEY,
	ordinal INTEGER NOT NULL
);
INSERT INTO tb_anag_package_status VALUES ('delivered', 1);
INSERT INTO tb_anag_package_status VALUES ('notified', 2);
INSERT INTO tb_anag_package_status VALUES ('collected', 3);
INSERT INTO tb_anag_package_status VALUES ('accepted', 4);
INSERT INTO tb_anag_package_status VALUES ('expired', 5);
INSERT INTO tb_anag_package_status VALUES ('returned', 6);


-- data tables
DROP TABLE IF EXISTS tb_account CASCADE;
CREATE TABLE IF NOT EXISTS tb_account (
	user_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	username TEXT,
	email TEXT,
	phone_number TEXT,
	salt TEXT NOT NULL,
	password TEXT NOT NULL,
	hash_specs TEXT NOT NULL,
	CHECK(COALESCE(email, phone_number) IS NOT NULL)
);
CREATE UNIQUE INDEX tb_account_username_idx ON tb_account(lower(username));
CREATE UNIQUE INDEX tb_account_email_idx ON tb_account(lower(email));
CREATE UNIQUE INDEX tb_account_phone_number_idx ON tb_account(phone_number);


DROP TABLE IF EXISTS tb_external_file CASCADE;
CREATE TABLE IF NOT EXISTS tb_external_file (
	external_file_id UUID PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	mime_type TEXT
);


DROP TABLE IF EXISTS tb_user CASCADE;
CREATE TABLE IF NOT EXISTS tb_user (
	user_id BIGINT PRIMARY KEY REFERENCES tb_account(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	ssn TEXT,
	profile_pic_id UUID REFERENCES tb_external_file(external_file_id)
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
	failure_count INTEGER
);
CREATE INDEX tb_device_token_user_id_idx ON tb_device_token(user_id);


DROP TABLE IF EXISTS tb_pudo CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo (
	pudo_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	business_name TEXT NOT NULL,
	vat TEXT,
	phone_number TEXT,
	contact_notes TEXT,
	profile_pic_id UUID REFERENCES tb_external_file(external_file_id),
	business_name_search tsvector GENERATED ALWAYS AS (to_tsvector('simple', business_name)) STORED
);
CREATE INDEX tb_pudo_business_name_search_idx ON tb_pudo USING GIN (business_name_search);


DROP TABLE IF EXISTS tb_pudo_user_role CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo_user_role (
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	create_tms TIMESTAMP(3) NOT NULL,
	role_type TEXT NOT NULL REFERENCES tb_anag_role_type(role_type),
	PRIMARY KEY(user_id, pudo_id)
);


DROP TABLE IF EXISTS tb_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_address (
	address_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	label TEXT NOT NULL,
	street TEXT NOT NULL,
	street_num TEXT,
	zip_code TEXT NOT NULL,
	city TEXT NOT NULL,
	province TEXT NOT NULL,
	country TEXT NOT NULL,
	lat DECIMAL(10,7) NOT NULL,
	lon DECIMAL(10,7) NOT NULL
);
CREATE INDEX tb_address_lat_lon_idx ON tb_address(lat, lon);


DROP TABLE IF EXISTS tb_pudo_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo_address (
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	address_id BIGINT NOT NULL REFERENCES tb_address(address_id),
	PRIMARY KEY(pudo_id, address_id)
);


DROP TABLE IF EXISTS tb_package CASCADE;
CREATE TABLE IF NOT EXISTS tb_package (
	package_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	package_pic_id UUID
);
CREATE INDEX tb_package_pudo_id_idx ON tb_package(pudo_id);
CREATE INDEX tb_package_user_id_idx ON tb_package(user_id);


DROP TABLE IF EXISTS tb_package_event CASCADE;
CREATE TABLE IF NOT EXISTS tb_package_event (
	package_event_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	package_id BIGINT NOT NULL REFERENCES tb_package(package_id),
	package_status TEXT NOT NULL REFERENCES tb_anag_package_status(package_status),
	notes TEXT
);
CREATE INDEX tb_package_event_package_id_idx ON tb_package_event(package_id, create_tms);


DROP TABLE IF EXISTS tb_notification CASCADE;
CREATE TABLE IF NOT EXISTS tb_notification (
	notification_id BIGSERIAL PRIMARY KEY,
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	read_tms TIMESTAMP(3),
	title TEXT NOT NULL,
	title_params TEXT,
	message TEXT NOT NULL,
	message_params TEXT,
	opt_data TEXT
);
CREATE INDEX tb_notification_user_id_idx ON tb_notification(user_id);


-- maintenance
VACUUM FULL ANALYZE;
