-- reset schema
DO 'DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE ''DROP TABLE IF EXISTS '' || quote_ident(rec.tablename) || '' CASCADE'';
    END LOOP;
END';


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
	last_access_tms TIMESTAMP(3) NOT NULL,
	device_type TEXT,
	system_name TEXT,
	system_version TEXT,
	model TEXT,
	resolution TEXT
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
	role_type TEXT NOT NULL,
	PRIMARY KEY(user_id, pudo_id),
	CHECK(role_type IN ('owner', 'customer'))
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


-- maintenance
VACUUM FULL ANALYZE;
