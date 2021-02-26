<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');

class Beton {

	/**
	 * return current shift (date+shift start time) for any date or current if empty
	 * can be previous date if current time is less than shift start time
	 */
	public static function shiftStart($aDate=NULL){
		$t = is_null($aDate)? time():$aDate;
		
		$dt = getdate($t);
		$d_start = mktime(0,0,0,$dt['mon'],$dt['mday'],$dt['year']);
		
		$shift_d = $d_start + self::shiftStartTime();
		if($t < $shift_d){
			$shift_d = $shift_d - 24*60*60;
		}
		return $shift_d;
	}

	public static function shiftEnd($shiftStart){
		return $shiftStart + self::shiftLengthTime() - 1;
	}

	private static function timeStrToSec($timeStr){
		$h = 0;
		$m = 0;
		$s = 0;
		$ar = explode(':',$timeStr);
		if(count($ar)>=3){
			list($h_s,$m_s,$s_s) = $ar;
			if(strlen($h_s) && strlen($m_s) && strlen($s_s)){
				$h = intval(($h_s[0]=='0')? $h_s[1]:$h_s);
				$m = intval(($m_s[0]=='0')? $m_s[1]:$m_s);
				$s = intval(($s_s[0]=='0')? $s_s[1]:$s_s);	
			}		
		}
		return $h*60*60 + $m*60 + $s;
	}

	private static function getConnect(){
		$dbLink = new DB_Sql();
		$dbLink->appname = APP_NAME;
		$dbLink->technicalemail = TECH_EMAIL;
		$dbLink->reporterror = DEBUG;

		/*conneсtion*/
		$dbLink->server		= DB_SERVER_MASTER;
		$dbLink->user		= DB_USER;
		$dbLink->password	= DB_PASSWORD;
		$dbLink->database	= DB_NAME;
		$dbLink->connect(DB_SERVER_MASTER, DB_USER, DB_PASSWORD);	
		return $dbLink;
	}

	private static function checkTimeCache(){
		//if(!isset($_SESSION['shift_length_time'])){
			$link = self::getConnect();
			$ar = $link->query_first(
			"SELECT
				const_first_shift_start_time_val() AS shift_start_time,
				const_shift_length_time_val() AS shift_length_time"
			);
			$_SESSION['shift_start_time'] = self::timeStrToSec($ar['shift_start_time']);
			$_SESSION['shift_length_time'] = self::timeStrToSec($ar['shift_length_time']);
		//}
	}

	/**
	 * returns shift start time in ms
	 */
	public static function shiftStartTime(){
		self::checkTimeCache();
		return $_SESSION['shift_start_time'];
	}
	
	/**
	 * returns shift length time in ms
	 */
	public static function shiftLengthTime(){
		self::checkTimeCache();
		return $_SESSION['shift_length_time'];
	
	}
	
}

?>
