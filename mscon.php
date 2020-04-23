<?php
//echo date('d/m/Y',strtotime('Jun 10 2019 10:54:10:000AM'));
//exit;

//"192.168.1.12:59900"
$serverName = "86.109.193.160:59900"; //serverName\instanceName 50203

$link = mssql_connect($serverName, 'andreymikhalevich', 'wimaf2020ii42');

if (!$link) {
    die('Something went wrong while connecting to MSSQL');
}
else{
	echo 'Connected!</BR>';
		
	mssql_select_db('Santral', $link);
$q = "
SELECT TOP 1 * FROM UretimSonuc";
	
/*	
$q = "
SELECT * FROM
  SYSOBJECTS
WHERE
  xtype = 'U'
";
*/
/*
		$q  = "WITH
			manual_correction AS (
				SELECT TOP 1
					*
				FROM ManuelKayit
				WHERE ManuelKayit.M_Tarih < (SELECT Uretim.BasTarih FROM Uretim WHERE Uretim.Id=91581)
				ORDER BY ManuelKayit.M_Tarih DESC
			)
			SELECT
				UretimSonuc.BitisTarihi AS production_dt_end,
				UretimSonuc.Miktar AS concrete_quant,
				Recete.ReceteAdi AS concrete_descr,
				Uretim.Olusturan AS user_descr,
				Uretim.AracPlaka AS vehicle_descr,
				(SELECT manual_correction.Id FROM manual_correction) AS correction_id,
				(SELECT manual_correction.M_Tarih FROM manual_correction) AS correction_dt_end,  
				
				'Инертные1' AS mat1_descr,
				UretimSonuc.Agrega1 AS mat1_quant,
				UretimSonuc.Agrega1Istenen AS mat1_quant_req,
				0 AS mat1_cement,
				(SELECT manual_correction.M_Agrega1 FROM manual_correction) AS mat1_quant_corrected,
				
				'Инертные2' AS mat2_descr,
				UretimSonuc.Agrega2 AS mat2_quant,
				UretimSonuc.Agrega2Istenen AS mat2_quant_req,
				0 AS mat2_cement,
				(SELECT manual_correction.M_Agrega2 FROM manual_correction) AS mat2_quant_corrected,
				
				'Инертные3' AS mat3_descr,
				UretimSonuc.Agrega3 AS mat3_quant,
				UretimSonuc.Agrega3Istenen AS mat3_quant_req,
				0 AS mat3_cement,
				(SELECT manual_correction.M_Agrega3 FROM manual_correction) AS mat3_quant_corrected,

				'Инертные4' AS mat4_descr,
				UretimSonuc.Agrega4 AS mat4_quant,
				UretimSonuc.Agrega4Istenen AS mat4_quant_req,
				0 AS mat4_cement,
				(SELECT manual_correction.M_Agrega4 FROM manual_correction) AS mat4_quant_corrected,

				'Инертные5' AS mat5_descr,
				UretimSonuc.Agrega5 AS mat5_quant,
				UretimSonuc.Agrega5Istenen AS mat5_quant_req,
				0 AS mat5_cement,
				(SELECT manual_correction.M_Agrega5 FROM manual_correction) AS mat5_quant_corrected,

				'Инертные6' AS mat6_descr,
				UretimSonuc.Agrega6 AS mat6_quant,
				UretimSonuc.Agrega6Istenen AS mat6_quant_req,
				0 AS mat6_cement,
				0 AS mat6_quant_corrected,
								
				'Хим. добавки1' AS mat7_descr,
				UretimSonuc.Katki1 AS mat7_quant,
				UretimSonuc.Katki1Istenen AS mat7_quant_req,
				0 AS mat7_cement,
				(SELECT manual_correction.M_Katki1 FROM manual_correction) AS mat7_quant_corrected,
				
				'Хим. добавки2' AS mat8_descr,
				UretimSonuc.Katki2 AS mat8_quant,
				UretimSonuc.Katki2Istenen AS mat8_quant_req,
				0 AS mat8_cement,
				(SELECT manual_correction.M_Katki2 FROM manual_correction) AS mat8_quant_corrected,
				
				'Хим. добавки3' AS mat9_descr,
				UretimSonuc.Katki3 AS mat9_quant,
				UretimSonuc.Katki3Istenen AS mat9_quant_req,
				0 AS mat9_cement,
				(SELECT manual_correction.M_Katki3 FROM manual_correction) AS mat9_quant_corrected,

				'Хим. добавки4' AS mat10_descr,
				UretimSonuc.Katki4 AS mat10_quant,
				UretimSonuc.Katki4Istenen AS mat10_quant_req,
				0 AS mat10_cement,
				(SELECT manual_correction.M_Katki4 FROM manual_correction) AS mat10_quant_corrected,

				'Вода1' AS mat11_descr,
				UretimSonuc.Su1 AS mat11_quant,
				UretimSonuc.Su1Istenen AS mat11_quant_req,
				0 AS mat11_cement,
				(SELECT manual_correction.M_Su1 FROM manual_correction) AS mat11_quant_corrected,

				'Вода2' AS mat12_descr,
				UretimSonuc.Su2 AS mat12_quant,
				UretimSonuc.Su2Istenen AS mat12_quant_req,
				0 AS mat12_cement,
				(SELECT manual_correction.M_Su2 FROM manual_correction) AS mat12_quant_corrected,
				
				'Цемент1' AS mat13_descr,
				UretimSonuc.Cimento1 AS mat13_quant,
				UretimSonuc.Cimento1Istenen AS mat13_quant_req,
				1 AS mat13_cement,
				(SELECT manual_correction.M_Cimento1 FROM manual_correction) AS mat13_quant_corrected,

				'Цемент2' AS mat14_descr,
				UretimSonuc.Cimento2 AS mat14_quant,
				UretimSonuc.Cimento2Istenen AS mat14_quant_req,
				1 AS mat14_cement,
				(SELECT manual_correction.M_Cimento2 FROM manual_correction) AS mat14_quant_corrected,
				
				'Цемент3' AS mat15_descr,
				UretimSonuc.Cimento3 AS mat15_quant,
				UretimSonuc.Cimento3Istenen AS mat15_quant_req,
				1 AS mat15_cement,
				(SELECT manual_correction.M_Cimento3 FROM manual_correction) AS mat15_quant_corrected,

				'Цемент4' AS mat16_descr,
				UretimSonuc.Cimento4 AS mat16_quant,
				UretimSonuc.Cimento4Istenen AS mat16_quant_req,
				1 AS mat16_cement,
				(SELECT manual_correction.M_Cimento4 FROM manual_correction) AS mat16_quant_corrected
				
			FROM Uretim
			LEFT JOIN UretimSonuc ON UretimSonuc.UretimId=Uretim.id
			LEFT JOIN Recete ON Recete.Id=Uretim.ReceteId
			
			WHERE Uretim.Id=91581 AND UretimSonuc.BitisTarihi IS NOT NULL"
		;

*/
	$res = mssql_query($q, $link);
	try{
		while($row = mssql_fetch_assoc($res)){
			echo var_export($row,TRUE).'</BR>';
			//iconv('windows-1251','UTF-8',$arr['project_manager'])
			//echo 'id='.$row['id'].'</BR>';
			//echo 'dt_start='.$row['dt_start'].'</BR>';
			//echo 'vehicle_descr='.$row['vehicle_descr'].'</BR>';
			//echo 'user_descr='.$row['user_descr'].'</BR>';
			//echo 'concrete_type_descr='.$row['concrete_type_descr'].'</BR>';
		}
	}
	finally{
		mssql_free_result($res);
	}
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
