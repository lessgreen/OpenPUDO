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


VACUUM FULL ANALYZE tb_user;
