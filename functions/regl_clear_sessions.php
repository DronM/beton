<?php
require_once('db_con.php');

/*****  НЕРАБОТАЮЩИЕ ТРЭКЕРЫ ******* */
$dbLink->query("DELETE FROM sessions");

