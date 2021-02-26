
--Add new user
CREATE USER franch_1 WITH PASSWORD '6w5e4g1r6W8r7';
--Create schema
CREATE SCHEMA franch_1;
-- AUTHORIZATION postgres;
--GRANT ALL ON SCHEMA franch_1 TO postgres;
GRANT ALL ON SCHEMA franch_1 TO franch_1;

GRANT SELECT ON ALL TABLES IN SCHEMA franch_1 TO franch_1;
--access to postgis
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO franch_1;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA franch_1 TO franch_1;

GRANT SELECT ON ALL TABLES IN SCHEMA fias TO franch_1;
GRANT USAGE, CREATE ON SCHEMA fias TO franch_1;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA fias TO franch_1;

CREATE USER MAPPING FOR franch_1 SERVER ms OPTIONS (user 'ms', password '159753');


--В Итоге: создал таблицу destinations вручную, потом все загрузолось!
--
--h 192.168.1.77 
pg_dump -U postgres --schema=public --no-owner --schema-only beton > beton_pub.sql

--public -->> franch_1
--Замена
sed 's/public/franch_1/g' beton_pub.sql > beton_md.sql
--!!!НЕ МЕНЯТЬ public.geometry !!!

--загрузка
psql -U franch_1 -d beton -a -f beton_md.sql >beton_md.res

--VIEWS!!!
COPY views TO '/tmp/beton_views.csv';




--**************************************************
CREATE USER concrete1 WITH PASSWORD '5g41We6Rt87h';
CREATE DATABASE concrete1;
GRANT ALL PRIVILEGES ON DATABASE concrete1 TO concrete1;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO concrete1;

--fias
CREATE SCHEMA fias;
GRANT SELECT ON ALL TABLES IN SCHEMA fias TO concrete1;
GRANT USAGE, CREATE ON SCHEMA fias TO concrete1;

CREATE EXTENSION postgres_fdw;
CREATE SERVER ms FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'ms', port '5432');
GRANT USAGE ON FOREIGN SERVER ms TO concrete1;
CREATE SERVER ms FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'ms', port '5432');
CREATE USER MAPPING FOR concrete1 SERVER ms OPTIONS (user 'ms', password '159753');
--Из под юзера concrete1
IMPORT FOREIGN SCHEMA fias FROM SERVER ms INTO fias;

CREATE EXTENSION pgcrypto;
CREATE EXTENSION pg_trgm;
CREATE EXTENSION postgis;

--загрузка
psql -U concrete1 -d concrete1 -a -f beton_md.sql >beton_md.res

--обязательные данные
insert into users (name,email,pwd,role_id) values ('admin','email@mail.ru',md5('123456'),'owner');

insert into production_sites (name,active) values ('Завод',true);

--материалы
insert into raw_materials (id,name,concrete_part,ord,is_cement,dif_store) values (5,'Цемент',true,1,true,false);
insert into raw_materials (id,name,concrete_part,ord,is_cement,dif_store) values (7,'Щебень',true,2,false,false);
insert into raw_materials (id,name,concrete_part,ord,is_cement,dif_store) values (6,'Песок',true,3,false,false);
insert into raw_materials (id,name,concrete_part,ord,is_cement,dif_store) values (4,'Добавка',true,5,false,true);

insert into langs (id,name) values (1,'Русский');

COPY views FROM '/tmp/beton_views.csv';
