#!/bin/bash

#Скрипт установки классификатора адресов КЛАДР
#для Postgresql
#

PG_USER="ms"

# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# the temp directory used, within $DIR
WORK_DIR=`mktemp -d -p "$DIR"`

# deletes the temp directory
function cleanup {
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

cd "$WORK_DIR"

#Скачивание файла
#wget http://www.gnivc.ru/html/gnivcsoft/KLADR/Base.7z

#Распаковка
#p7zip -d Base.7z

#нинициализация, очистка базы
#if [ -f $DIR/before.sql ]; then
#	psql -d kladr -U "$PG_USER" -f $DIR/before.sql
#fi

# dbf to PG sql
pgdbf -s 866 -c ALTNAMES.DBF | psql -d kladr -U "$PG_USER"
pgdbf -s 866 -c DOMA.DBF code "lower(name)" | psql -d kladr -U "$PG_USER"
pgdbf -s 866 -c FLAT.DBF code "lower(name)" | psql -d kladr -U "$PG_USER"
pgdbf -s 866 -c KLADR.DBF code "lower(name)" | psql -d kladr -U "$PG_USER"
pgdbf -s 866 -c SOCRBASE.DBF | psql -d kladr -U "$PG_USER"
pgdbf -s 866 -c STREET.DBF code "lower(name)" | psql -d kladr -U "$PG_USER"

#Индекс по улицам нас пунктов и городов
psql -d kladr -U "$PG_USER" -c "ALTER TABLE street ADD COLUMN code_part varchar(11)"
psql -d kladr -U "$PG_USER" -c "UPDATE street SET code_part = substr(code,1,11)"
psql -d kladr -U "$PG_USER" -c "CREATE INDEX street_code_part_idx ON street (code_part)"

#Отметка об установке
psql -d kladr -U "$PG_USER" -c "INSERT INTO update_date VALUES(now())"

#Права
psql -d kladr -U "$PG_USER" -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO PUBLIC";

#custim scripts
if [ -f $DIR/after.sql ]; then
	psql -d kladr -U "$PG_USER" -f $DIR/after.sql
fi




pgdbf  -s 866 ADDROB72.DBF | psql -d ms -U fias



GRANT  USAGE   ON SCHEMA fias  TO fias;
GRANT ALL ON ALL TABLES IN SCHEMA fias TO fias;
pgdbf -CDp -s cp866 ADDROBJ.DBF  | awk '{sub("CREATE TABLE ","CREATE TABLE 'fias.'"); sub("DROP TABLE IF EXISTS","DROP TABLE IF EXISTS 'fias.'"); sub("'1000-00-00'","1999-01-01"); sub("COPY ","COPY 'fias.'"); sub("timeout=60000","timeout=999999");  print }' | psql -h localhost -d ms -U fias


