<?php
/*require_once(dirname(__FILE__).'/functions/Beton.php');

$d1 = Beton::shiftStart();
$d2 = Beton::shiftEnd($d1);
echo date('Y-m-d H:i:s',$d1).' - '.date('Y-m-d H:i:s',$d2);
*/

require_once('common/WeatherForeca.php');
$w = new WeatherForeca();
$w->getForcast();
echo $w->getContent();
echo '</BR>';
echo '</BR>';
echo '</BR>';
echo $w->getContentDetails();
//file_put_contents('output/weather',$cont);
?>
