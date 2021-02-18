1) Залить как есть
pgdbf -p -s cp866 ADDROB72.DBF  | awk '{sub("CREATE TABLE ","CREATE TABLE 'fias.'"); sub("DROP TABLE IF EXISTS","DROP TABLE IF EXISTS 'fias.'"); sub("'1000-00-00'","1999-01-01"); sub("COPY ","COPY 'fias.'"); sub("timeout=60000","timeout=999999");  print }' | psql -h localhost -d ms -U postgres
DELETE FROM fias.addrob72 WHERE livestatus != 1 AND actstatus != 1;
CREATE INDEX addrob72_aoguid_pk_idx ON fias.addrob72 USING btree (aoguid);
CREATE INDEX addrob72_parentguid_idx ON fias.addrob72 USING btree (parentguid);



2)Создать таблицу PARTITION
CREATE TABLE fias.addrobj
(
    actstatus numeric(2,0),
    aoguid character varying(36) COLLATE pg_catalog."default",
    aoid character varying(36) COLLATE pg_catalog."default",
    aolevel numeric(2,0),
    areacode character varying(3) COLLATE pg_catalog."default",
    autocode character varying(1) COLLATE pg_catalog."default",
    centstatus numeric(2,0),
    citycode character varying(3) COLLATE pg_catalog."default",
    code character varying(17) COLLATE pg_catalog."default",
    currstatus numeric(2,0),
    enddate date,
    formalname character varying(120) COLLATE pg_catalog."default",
    ifnsfl character varying(4) COLLATE pg_catalog."default",
    ifnsul character varying(4) COLLATE pg_catalog."default",
    nextid character varying(36) COLLATE pg_catalog."default",
    offname character varying(120) COLLATE pg_catalog."default",
    okato character varying(11) COLLATE pg_catalog."default",
    oktmo character varying(11) COLLATE pg_catalog."default",
    operstatus numeric(2,0),
    parentguid character varying(36) COLLATE pg_catalog."default",
    placecode character varying(3) COLLATE pg_catalog."default",
    plaincode character varying(15) COLLATE pg_catalog."default",
    postalcode character varying(6) COLLATE pg_catalog."default",
    previd character varying(36) COLLATE pg_catalog."default",
    regioncode character varying(2) COLLATE pg_catalog."default",
    shortname character varying(10) COLLATE pg_catalog."default",
    startdate date,
    streetcode character varying(4) COLLATE pg_catalog."default",
    terrifnsfl character varying(4) COLLATE pg_catalog."default",
    terrifnsul character varying(4) COLLATE pg_catalog."default",
    updatedate date,
    ctarcode character varying(3) COLLATE pg_catalog."default",
    extrcode character varying(4) COLLATE pg_catalog."default",
    sextcode character varying(3) COLLATE pg_catalog."default",
    livestatus numeric(2,0),
    normdoc character varying(36) COLLATE pg_catalog."default",
    plancode character varying(4) COLLATE pg_catalog."default",
    cadnum character varying(100) COLLATE pg_catalog."default",
    divtype numeric(1,0)
)
PARTITION BY LIST (regioncode)
WITH (
    OIDS = FALSE
);
ALTER TABLE fias.ADDROBJ OWNER TO ms;

3) Объединим
ALTER TABLE fias.addrobj ATTACH PARTITION fias.addrob72 FOR VALUES IN ('72');

/***************************************************************************/
1) Залить как есть
pgdbf -p -s cp866 HOUS72.DBF  | awk '{sub("CREATE TABLE ","CREATE TABLE 'fias.'"); sub("DROP TABLE IF EXISTS","DROP TABLE IF EXISTS 'fias.'"); sub("'1000-00-00'","1999-01-01"); sub("COPY ","COPY 'fias.'"); sub("timeout=60000","timeout=999999");  print }' | psql -h localhost -d ms -U postgres
DELETE FROM fias.house72 WHERE livestatus != 1 AND actstatus != 1;
CREATE INDEX house72_aoguid_pk_idx ON fias.house72 USING btree (aoguid);


2) партиционная таблица
CREATE TABLE fias.house
(
    aoguid character varying(36),
    buildnum character varying(50),
    enddate date,
    eststatus numeric(2,0),
    houseguid character varying(36),
    houseid character varying(36),
    housenum character varying(20),
    statstatus numeric(5,0),
    ifnsfl character varying(4),
    ifnsul character varying(4),
    okato character varying(11),
    oktmo character varying(11),
    postalcode character varying(6),
    startdate date,
    strucnum character varying(50),
    strstatus numeric(1,0),
    terrifnsfl character varying(4),
    terrifnsul character varying(4),
    updatedate date,
    normdoc character varying(36),
    counter numeric(4,0),
    cadnum character varying(100),
    divtype numeric(2,0),
	regioncode character varying(2)
) PARTITION BY LIST (regioncode)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
ALTER TABLE fias.house72 OWNER to ms;

3) Новое поле
ALTER TABLE fias.house72 ADD COLUMN regioncode character varying(2) DEFAULT ('72');
ALTER TABLE fias.house ATTACH PARTITION fias.house72 FOR VALUES IN ('72');







CREATE TABLE fias.ACTSTAT (
	ACTSTATID number(4,0),
	NAME varchar(50)
);

CREATE TABLE fias.CENTERST (
	CENTERSTID smallint,
	NAME varchar(50)
);

CREATE TABLE fias.CURENTST (
	CURENTSTID smallint,
	NAME varchar(50)
);

CREATE TABLE fias.ESTSTAT (
	ESTSTATID smallint,
	NAME varchar(50),
	SHORTNAME varchar(50)
);

CREATE TABLE fias.FLATTYPE (
	FLTYPEID smallint,
	NAME varchar(50)
	SHORTNAME varchar(50)
);

CREATE TABLE fias.NDOCTYPE (
	NDTYPEID smallint,
	NAME varchar(50)
);

CREATE TABLE fias.OPERSTAT (
	OPERSTATID smallint,
	NAME varchar(50)
);

CREATE TABLE fias.ROOMTYPE (
	RMTYPEID smallint,
	NAME varchar(50),
	SHORTNAME varchar(50)
);

CREATE TABLE fias.SOCRBASE (
	LEVEL smallint,
	SOCRNAME varchar(50),
	SCNAME varchar(10),
	KOD_T_ST varchar(4)
	
);


CREATE TABLE fias.NORDOC (
	NORMDOCID varchar(36),
	DOCNAME varchar(250),
	DOCDATE date,
	DOCNUM varchar(20),
	DOCTYPE varchar(5),
	DOCIMGID varchar(36)
);

CREATE TABLE fias.STEAD (
	STEADGUID,C,36
	NUMBER,C,120
	REGIONCODE,C,2
	POSTALCODE,C,6
	IFNSFL,C,4
	TERRIFNSFL,C,4
	IFNSUL,C,4
	TERRIFNSUL,C,4
	OKATO,C,11
	UPDATEDATE date,
	PARENTGUID,C,36
	STEADID,C,36
	PREVID,C,36
	OPERSTATUS smallint,
	STARTDATE date,
	ENDDATE date,
	NEXTID,C,36
	OKTMO,C,11
	LIVESTATUS smallint,
	CADNUM,C,100
	DIVTYPE smallint,
	COUNTER smallint,
	NORMDOC,C,36
);

CREATE TABLE fias.ROOM (
	ROOMID,C,36
	ROOMGUID,C,36
	HOUSEGUID,C,36
	REGIONCODE,C,2
	FLATNUMBER,C,50
	FLATTYPE smallint,
	ROOMNUMBER,C,50
	ROOMTYPE,C,2
	CADNUM,C,100
	ROOMCADNUM,C,100
	POSTALCODE,C,6
	UPDATEDATE date,
	PREVID,C,36
	NEXTID,C,36
	OPERSTATUS smallint,
	STARTDATE date,
	ENDDATE date,
	LIVESTATUS smallint,
	NORMDOC,C,36
);

Удалить старые данные

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX address_search_search_name_idx on fias.address_search USING gin (searchname gin_trgm_ops);


SELECT * FROM fias.addresses WHERE offname ilike '%50 лет поб%' AND offname ilike '%Тюмень%' limit 10

/*CREATE MATERIALIZED VIEW fias.address_houses AS
	SELECT
		aoguid
		,housenum
		,buildnum
		,strucnum
		,regioncode
		,CASE WHEN coalesce(hs.housenum,'')='' THEN ''
		ELSE
			'д '||hs.housenum||
			CASE WHEN coalesce(hs.buildnum,'')='' THEN ''
			ELSE ' к '||hs.buildnum
			END
			||
			CASE WHEN coalesce(hs.strucnum,'')='' THEN ''
			ELSE ' стр '||hs.strucnum
			END
		END AS full_name
		,CASE WHEN housenum ~ '^[0-9]+$' THEN housenum::int ELSE 99999 END AS sort
	FROM fias.house
	GROUP BY housenum,buildnum,strucnum,aoguid
	;
CREATE INDEX address_houses_idx ON fias.address_houses USING btree (aoguid,sort);	
*/

--SELECT * FROM fias.addresses WHERE descr ilike '%нтернацион%' AND descr ilike '%Тюмень%' limit 10
-- Function: fias.aguid_address(in_aguid text)

-- DROP FUNCTION fias.aguid_address(in_aguid text);
-- 'f1127b16-8a8e-4520-b1eb-6932654abdcd' test guid
CREATE OR REPLACE FUNCTION fias.aguid_address(in_aguid text)
  RETURNS JSON AS  
$$
	WITH RECURSIVE
		child_to_parents AS (
			SELECT
				addrobj.*
			FROM fias.addrobj
			WHERE
				aoguid = in_aguid
				AND addrobj.livestatus=1 and  addrobj.actstatus=1
			UNION ALL
			SELECT
				addrobj.*
			FROM fias.addrobj, child_to_parents
			WHERE addrobj.aoguid = child_to_parents.parentguid
			AND addrobj.livestatus=1 and  addrobj.actstatus=1
		)
		SELECT
			json_build_object(
				'search_name', string_agg(expanded.offname||' '||expanded.shortname,', ')
				,'addr_struc', array_agg(expanded.addr)
			)
		FROM (
			SELECT
				offname
				,shortname
				,json_build_object(
					'aolevel', aolevel
					,'aoguid', aoguid
					,'shortname', shortname
					,'offname', offname
					,'regioncode', regioncode
				) AS addr
			FROM child_to_parents
			ORDER BY aolevel
		) AS expanded	
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fias.aguid_address(in_aguid text) OWNER TO ;


CREATE OR REPLACE FUNCTION fias.region_prior(in_regioncode text)
  RETURNS int AS  
$$
	SELECT 1;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION fias.aguid_address(in_aguid text) OWNER TO ms;


CREATE MATERIALIZED VIEW fias.house_search AS
	SELECT
		sub.aguid_address->>'search_name'||sub.search_house AS search_name
		,sub.aguid_address->'addr_struc' AS addr_strucs
		,sub.house_struc
	FROM
		(SELECT
			fias.aguid_address(ao.aoguid) AS aguid_address
			,ao.regioncode
			,ao.aolevel
			,CASE WHEN coalesce(hs.housenum,'')='' THEN ''
			ELSE ', '||hs.full_name
			END AS search_house				
			
			,json_build_object(
				'aoguid', hs.aoguid
				,'housenum', hs.housenum
				,'buildnum', hs.buildnum
				,'strucnum', hs.strucnum
			) AS house_struc
			,hs.sort AS house_sort
		FROM
			fias.addrobj ao
		LEFT JOIN (
			SELECT
				aoguid
				,regioncode
				,housenum
				,buildnum
				,strucnum				
				,CASE WHEN coalesce(housenum,'')='' THEN ''
				ELSE
					'д '||housenum||
					CASE WHEN coalesce(buildnum,'')='' THEN ''
					ELSE ' к '||buildnum
					END
					||
					CASE WHEN coalesce(strucnum,'')='' THEN ''
					ELSE ' стр '||strucnum
					END
				END AS full_name
				,CASE WHEN housenum ~ '^[0-9]+$' THEN housenum::int ELSE 99999 END AS sort
			FROM fias.house
			GROUP BY aoguid,regioncode,housenum,buildnum,strucnum
		) AS hs ON hs.aoguid = ao.aoguid
		WHERE livestatus=1 and  actstatus=1
		) AS sub
	ORDER BY
		--sub.aolevel,sub.house_sort;
		sub.regioncode
		,sub.house_sort;


CREATE MATERIALIZED VIEW fias.address_search AS
	SELECT
		sub.aguid_address->>'search_name' AS search_name
		,sub.aguid_address->'addr_struc' AS addr_strucs
		,NULL::json AS house_struc
	FROM
		(SELECT
			fias.aguid_address(ao.aoguid) AS aguid_address
			,ao.regioncode
			,ao.aolevel
		FROM
			fias.addrobj ao
		WHERE livestatus=1 and  actstatus=1
		) AS sub
	ORDER BY
		sub.regioncode,sub.aolevel;


!!!!!
CREATE INDEX addrob72_aolevel_idx ON fias.addrob72 USING btree (aolevel);


CREATE OR REPLACE FUNCTION fias.find_address(in_search text, in_count int)
  RETURNS TABLE(
  	search_name text
  	,addr_strucs json
  	,house_struc json
  ) AS  
$BODY$
DECLARE
	v_data_row RECORD;
	v_count smallint;
BEGIN
	v_count = 0;
	FOR v_data_row IN
	SELECT t.* FROM fias.address_search AS t WHERE t.search_name ilike in_search LIMIT in_count
	LOOP
		search_name = v_data_row.search_name;
		addr_strucs = v_data_row.addr_strucs;
		house_struc = v_data_row.house_struc;
		
		v_count = v_count + 1;
		
		RETURN NEXT;
	END LOOP;
	
	IF v_count<in_count THEN
		--houses
		FOR v_data_row IN
		SELECT t.* FROM fias.house_search AS t WHERE t.search_name ilike in_search LIMIT (in_count-v_count)
		LOOP
			search_name = v_data_row.search_name;
			addr_strucs = v_data_row.addr_strucs;
			house_struc = v_data_row.house_struc;
		
			v_count = v_count + 1;
				
			RETURN NEXT;
		END LOOP;
		
	END IF;	
	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

