<?php
	while(1==1){
		$res = exec("curl 'https://booking.pobeda.aero/sorry/' | grep 'Please come back later'");
		echo $res.PHP_EOL;
		if(!strlen($res)){
			echo '!!!!!!!!!!!!'.PHP_EOL;
			break;
		}
		sleep(10);
	}
?>
