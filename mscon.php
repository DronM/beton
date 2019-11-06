<?php
$serverName = "92.255.167.42:733"; //serverName\instanceName

$link = mssql_connect($serverName, 'Admin', 'YWRtaW4=');

if (!$link) {
    die('Something went wrong while connecting to MSSQL');
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
