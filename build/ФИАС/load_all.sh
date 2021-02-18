#!/bin/bash

# Загрузка данных ФИАС из DBF

# Настройки
dbf_path='dbf' # Путь к каталогу с файлами
schema_name='fias.' # Схема БД (с точкой)
username='user'
password='pass'
db_mame='export'
db_host='host'
db_port='5432'


export PGUSER=$username
export PGPASSWORD=$password

# Загружается первая таблица ADDROB01 с созданием в БД
echo 'Загрузка таблицы ADDROBJ...'
pgdbf -s cp866 $dbf_path'/ADDROB01.DBF'  | awk '{sub("CREATE TABLE ","CREATE TABLE '$schema_name'"); sub("DROP TABLE IF EXISTS","DROP TABLE IF EXISTS '$schema_name'"); sub("COPY ","COPY '$schema_name'"); sub("timeout=60000","timeout=999999");  print }' | psql -h $db_host -p $db_port -d $db_mame

# Загружаются остальные в цикле
for fn in `find $dbf_path -type f -name "ADDROB*" -not -name "ADDROB01.DBF"`
do
	fn_base=`basename "$fn" `
	echo "Файл "$fn_base"..."
	fn_base=`basename -s .DBF "$fn" | sed 's@[^ ]*@\L&@g'`
	pgdbf -CD -s cp866 $fn | awk '{sub("COPY '$fn_base' FROM STDIN","COPY '$schema_name'addrob01 FROM STDIN"); print }' | psql -h $db_host -p $db_port -d $db_mame
done

#######################################

# То же самое с домами
echo 'Загрузка таблицы HOUSE...'
pgdbf -s cp866 $dbf_path'/HOUSE01.DBF'  | awk '{sub("CREATE TABLE ","CREATE TABLE '$schema_name'"); sub("DROP TABLE IF EXISTS","DROP TABLE IF EXISTS '$schema_name'"); sub("COPY ","COPY '$schema_name'"); sub("timeout=60000","timeout=999999");  print }' | psql -h $db_host -p $db_port -d $db_mame

for fn in `find $dbf_path -type f -name "HOUSE*" -not -name "HOUSE01.DBF"`
do
	fn_base=`basename "$fn" `
	echo "Файл "$fn_base"..."
	fn_base=`basename -s .DBF "$fn" | sed 's@[^ ]*@\L&@g'`
	pgdbf -CD -s cp866 $fn | awk '{sub("COPY '$fn_base' FROM STDIN","COPY '$schema_name'house01 FROM STDIN"); print }' | psql -h $db_host -p $db_port -d $db_mame
done

echo 'OK'

