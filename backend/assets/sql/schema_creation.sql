-- prerequisites
CREATE USER openpudo PASSWORD 'openpudo';
CREATE DATABASE openpudo OWNER openpudo;
\c openpudo
CREATE SCHEMA IF NOT EXISTS openpudo AUTHORIZATION openpudo;