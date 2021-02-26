<?php
require_once('db_con.php');

//User Agent parser
require_once ABSOLUTE_PATH.'models/Spyc.php';
require_once 'common/matomo/device-detector/autoload.php';
require_once 'common/matomo/device-detector/DeviceDetector.php';
require_once 'common/matomo/device-detector/Parser/AbstractParser.php';
require_once 'common/matomo/device-detector/Parser/AbstractBotParser.php';
require_once 'common/matomo/device-detector/Parser/Bot.php';
require_once 'common/matomo/device-detector/Parser/OperatingSystem.php';
require_once 'common/matomo/device-detector/Yaml/ParserInterface.php';
require_once 'common/matomo/device-detector/Yaml/Spyc.php';
require_once 'common/matomo/device-detector/Cache/CacheInterface.php';
require_once 'common/matomo/device-detector/Cache/StaticCache.php';

require_once 'common/matomo/device-detector/Parser/VendorFragment.php';
require_once 'common/matomo/device-detector/Parser/Client/AbstractClientParser.php';
require_once 'common/matomo/device-detector/Parser/Client/FeedReader.php';
require_once 'common/matomo/device-detector/Parser/Client/MobileApp.php';
require_once 'common/matomo/device-detector/Parser/Client/MediaPlayer.php';
require_once 'common/matomo/device-detector/Parser/Client/PIM.php';
require_once 'common/matomo/device-detector/Parser/Client/Browser.php';
require_once 'common/matomo/device-detector/Parser/Client/Browser/Engine/Version.php';
require_once 'common/matomo/device-detector/Parser/Client/Library.php';
require_once 'common/matomo/device-detector/Parser/Device/AbstractDeviceParser.php';
require_once 'common/matomo/device-detector/Parser/Device/HbbTv.php';
require_once 'common/matomo/device-detector/Parser/Device/Notebook.php';
require_once 'common/matomo/device-detector/Parser/Device/Console.php';
require_once 'common/matomo/device-detector/Parser/Device/CarBrowser.php';
require_once 'common/matomo/device-detector/Parser/Device/Camera.php';
require_once 'common/matomo/device-detector/Parser/Device/PortableMediaPlayer.php';
require_once 'common/matomo/device-detector/Parser/Device/Mobile.php';


use DeviceDetector\DeviceDetector;
use DeviceDetector\Parser\Device\AbstractDeviceParser;
AbstractDeviceParser::setVersionTruncation(AbstractDeviceParser::VERSION_TRUNCATION_NONE);

$pn = "User-Agent";
$q_id = $dbLink->query('SELECT headers_j,id FROM logins WHERE headers_j IS NOT NULL AND user_agent IS NULL');
while($header = $dbLink->fetch_array($q_id)){
	$headers = json_decode($header['headers_j']);
	$agent = $headers->$pn;
	
	if (strlen($agent)){
		$dd = new DeviceDetector($agent);
		$dd->skipBotDetection();
		$dd->parse();
		$header_user_agent = json_encode(array(
			'clientInfo'	=> $dd->getClient()
			,'osInfo'	=> $dd->getOs()
			,'device'	=> $dd->getDeviceName()
			,'brand'	=> $dd->getBrandName()
			,'model'	=> $dd->getModel()
		));
		$dbLink->query(sprintf("UPDATE logins SET user_agent='%s' WHERE id=%d",$header_user_agent,$header['id']));
		//echo 'ID='.$header['id'];
		//break;
	}	
}
?>
