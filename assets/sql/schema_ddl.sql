-- reset schema
DO 'DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE ''DROP TABLE IF EXISTS '' || quote_ident(rec.tablename) || '' CASCADE'';
    END LOOP;
END';

-- data tables
DROP TABLE IF EXISTS tb_user CASCADE;
CREATE TABLE IF NOT EXISTS tb_user (
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
CREATE UNIQUE INDEX tb_user_lower_username_idx ON tb_user (lower(username));
CREATE UNIQUE INDEX tb_user_lower_email_idx ON tb_user (lower(email));
CREATE UNIQUE INDEX tb_user_phone_number_idx ON tb_user (phone_number);


DROP TABLE IF EXISTS tb_user_profile CASCADE;
CREATE TABLE IF NOT EXISTS tb_user_profile (
	user_id BIGINT PRIMARY KEY REFERENCES tb_user(user_id),
	create_tms TIMESTAMP(3) NOT NULL,
	update_tms TIMESTAMP(3) NOT NULL,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	ssn TEXT,
	profile_pic_id UUID
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


-- janitoring
VACUUM FULL ANALYZE;
