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
	CHECK (COALESCE(email, phone_number) IS NOT NULL)
);
CREATE UNIQUE INDEX tb_account_username_idx ON tb_account (lower(username));
CREATE UNIQUE INDEX tb_account_email_idx ON tb_account (lower(email));
CREATE UNIQUE INDEX tb_account_phone_number_idx ON tb_account (phone_number);


DROP TABLE IF EXISTS tb_user CASCADE;
CREATE TABLE IF NOT EXISTS tb_user (
	user_id BIGINT PRIMARY KEY REFERENCES tb_account(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	ssn TEXT,
	profile_pic_id UUID
);


DROP TABLE IF EXISTS tb_pudo CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo (
	pudo_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	business_name TEXT NOT NULL,
	vat TEXT,
	phone_number TEXT,
	contact_notes TEXT,
	business_name_search tsvector GENERATED ALWAYS AS (to_tsvector('simple', business_name)) STORED
);
CREATE INDEX tb_pudo_business_name_search_idx ON tb_pudo USING GIN (business_name_search);


DROP TABLE IF EXISTS tb_pudo_user_role CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo_user_role (
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	create_tms TIMESTAMP(3) NOT NULL,
	role_type TEXT NOT NULL
	CHECK (role_type IN ('owner', 'customer'))
);


DROP TABLE IF EXISTS tb_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_address (
	address_id BIGSERIAL PRIMARY KEY,
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	street TEXT NOT NULL,
	street_num TEXT,
	zip_code TEXT NOT NULL,
	city TEXT NOT NULL,
	province TEXT NOT NULL,
	country TEXT NOT NULL,
	notes TEXT,
	lat DECIMAL(10,7) NOT NULL,
	lon DECIMAL(10,7) NOT NULL
);


DROP TABLE IF EXISTS tb_user_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_user_address (
	user_id BIGINT NOT NULL REFERENCES tb_user(user_id),
	address_id BIGINT NOT NULL REFERENCES tb_address(address_id),
	PRIMARY KEY(user_id, address_id)
);


DROP TABLE IF EXISTS tb_pudo_address CASCADE;
CREATE TABLE IF NOT EXISTS tb_pudo_address (
	pudo_id BIGINT NOT NULL REFERENCES tb_pudo(pudo_id),
	address_id BIGINT NOT NULL REFERENCES tb_address(address_id),
	PRIMARY KEY(pudo_id, address_id)
);


-- maintenance
VACUUM FULL ANALYZE;
