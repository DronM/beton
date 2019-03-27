<?php
require_once(dirname(__FILE__).'/functions/Beton.php');

$d1 = Beton::shiftStart();
$d2 = Beton::shiftEnd($d1);
echo date('Y-m-d H:i:s',$d1).' - '.date('Y-m-d H:i:s',$d2);
?>
