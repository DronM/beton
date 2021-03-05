<?php
//echo date('d/m/Y',strtotime('Jun 10 2019 10:54:10:000AM'));
//exit;

$USE_SQLSRV = TRUE;

//"192.168.1.12:59900"
$serverName = "86.109.193.160";
$serverPort = "50203";//59900 50203
$userName = 'andreymikhalevich';
$userPwd = 'wimaf2020ii42';
//serverName\instanceName 59900 50203

if (!$USE_SQLSRV){
	$link = mssql_connect(sprintf('%s:%d',$serverName,$serverPort), $userName, $userPwd);
}
else{
	$con_info = array('Database'=>'Santral'
		,'UID'=>$userName
		,'PWD'=>$userPwd
		//,'CharacterSet' => 'UTF-8'
	);
	$link = sqlsrv_connect(sprintf('%s, %d',$serverName,$serverPort), $con_info);
}

if (!$link) {
    die('Something went wrong while connecting to MSSQL');
}

echo 'Connected!</BR>';

if (!$USE_SQLSRV){		
	mssql_select_db('Santral', $link);
}


$q = "SELECT
	UretimSonuc.BitisTarihi AS production_dt_end,
	UretimSonuc.Miktar AS concrete_quant
FROM Uretim
LEFT JOIN UretimSonuc ON UretimSonuc.UretimId=Uretim.id
WHERE Uretim.Id=9700";
//WHERE Uretim.Id=91918";

//$q = "SELECT TOP 1 * FROM UretimSonuc";
//$q = "SELECT * FROM SYSOBJECTS WHERE xtype = 'U'";

if (!$USE_SQLSRV){		
	$res = mssql_query($q, $link);
	try{
		while($row = mssql_fetch_assoc($res)){
			echo var_export($row,TRUE).'</BR>';
			//iconv('windows-1251','UTF-8',$arr['project_manager'])
		}
	}
	finally{
		mssql_free_result($res);
	}	
}
else{
	$res = sqlsrv_query($link, $q);
	if( $res === FALSE ) {
		throw new Exception(print_r(sqlsrv_errors()));	
	}
	while($row = sqlsrv_fetch_array($res,SQLSRV_FETCH_ASSOC)){
		echo var_export($row,TRUE).'</BR>';
	}
}	
	

?>
