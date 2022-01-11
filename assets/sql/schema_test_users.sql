DELETE FROM tb_user;
INSERT INTO tb_user VALUES(1, now(), now(), 'customer', true, '+39328000001');
INSERT INTO tb_user VALUES(2, now(), now(), 'pudo', true, '+39328000002');
INSERT INTO tb_user VALUES(3, now(), now(), 'pudo', true, '+39328000003');
INSERT INTO tb_user VALUES(4, now(), now(), 'pudo', true, '+39328000004');
INSERT INTO tb_user VALUES(5, now(), now(), 'pudo', true, '+39328000005');

-- maintenance
VACUUM FULL ANALYZE;
