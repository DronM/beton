<?php
/**
	DO NOT MODIFY THIS FILE!	
	Its content is generated automaticaly from template placed at build/permissions/permission_php.tmpl.	
 */
function method_allowed($contrId,$methId){
$permissions = array();

			$permissions['User_Controller_login']=TRUE;
		
			$permissions['User_Controller_login_html']=TRUE;
		
			$permissions['User_Controller_login_k']=TRUE;
		
			$permissions['User_Controller_login_ks']=TRUE;
		
			$permissions['User_Controller_login_ext']=TRUE;
		
			$permissions['User_Controller_logged']=TRUE;
		
			$permissions['User_Controller_logout']=TRUE;
		
			$permissions['Captcha_Controller_get']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>