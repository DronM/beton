CREATE SCHEMA gis;

GRANT ALL ON SCHEMA gis TO postgres;
GRANT ALL ON SCHEMA gis TO beton;
GRANT ALL ON SCHEMA gis TO franch_1;

UPDATE pg_extension 
  SET extrelocatable = TRUE 
    WHERE extname = 'postgis';


ALTER EXTENSION postgis 
  SET SCHEMA gis;
  
Проверить доступ из-плд beton!!!  
SELECT * FROM destination_dialog_view LIMIT 1;
