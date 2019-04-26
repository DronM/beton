<?php
/*require_once(dirname(__FILE__).'/functions/Beton.php');

$d1 = Beton::shiftStart();
$d2 = Beton::shiftEnd($d1);
echo date('Y-m-d H:i:s',$d1).' - '.date('Y-m-d H:i:s',$d2);
*/

$s = '{"value":"{\"id\":\"VehicleDriverForSchedGen_Model\",\"rows\":[{\"fields\":{\"id\":1,\"vehicle\":{\"keys\":{\"id\":533},\"descr\":\"948\"}}},{\"fields\":{\"id\":2,\"vehicle\":{\"keys\":{\"id\":58},\"descr\":\"692\"}}}]}","length":4}';
$l = json_decode($s);
echo isset($l);
return;
$list = json_decode(json_decode($s)->value);
var_dump($list);
?>
