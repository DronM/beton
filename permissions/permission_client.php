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
		
			$permissions['User_Controller_logout_html']=TRUE;
		
			$permissions['User_Controller_get_profile']=TRUE;
		
			$permissions['User_Controller_update']=TRUE;
		
			$permissions['Captcha_Controller_get']=TRUE;
		
				$permissions['VariantStorage_Controller_insert']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_filter_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_col_visib_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_col_order_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_all_data']=TRUE;
			
				$permissions['VariantStorage_Controller_update']=TRUE;
			
				$permissions['VariantStorage_Controller_delete']=TRUE;
			
				$permissions['VariantStorage_Controller_get_list']=TRUE;
			
				$permissions['VariantStorage_Controller_get_object']=TRUE;
			
				$permissions['VariantStorage_Controller_get_filter_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_visib_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_order_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_all_data']=TRUE;
			
			$permissions['Constant_Controller_get_values']=TRUE;
		
			$permissions['Weather_Controller_get_current']=TRUE;
		
			$permissions['ConcreteType_Controller_get_for_client_list']=TRUE;
		
			$permissions['Destination_Controller_get_for_client_list']=TRUE;
		
			$permissions['Shipment_Controller_get_list_for_client']=TRUE;
		
			$permissions['Shipment_Controller_get_list_for_order']=TRUE;
		
			$permissions['Order_Controller_get_list_for_client']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>