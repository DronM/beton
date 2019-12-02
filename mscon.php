<?php
$serverName = "192.168.1.12:59900"; //serverName\instanceName

$link = mssql_connect($serverName, 'andreymikhalevich', 'wimaf2020ii42');

if (!$link) {
    die('Something went wrong while connecting to MSSQL');
}
else{
	echo 'Connected!</BR>';
	mssql_select_db('Santral', $link);
	$res = mssql_query('Select * from Mail', $link);
	$row = mssql_fetch_array($res);
	echo var_export($row,TRUE);
	mssql_free_result($res);
}

/*
$connectionInfo = array("Database"=>"dbName", "UID"=>"userName", "PWD"=>"password");
$conn = sqlsrv_connect( $serverName, $connectionInfo);
if( $conn ) {
     echo "Connection established.<br />";
}else{
     echo "Connection could not be established.<br />";
     die( print_r( sqlsrv_errors(), true));
}
*/

?>
