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
		
			$permissions['User_Controller_login_ext']=TRUE;
		
			$permissions['User_Controller_logged']=TRUE;
		
			$permissions['User_Controller_logout']=TRUE;
		
			$permissions['User_Controller_logout_html']=TRUE;
		
			$permissions['User_Controller_get_profile']=TRUE;
		
			$permissions['User_Controller_update']=TRUE;
		
			$permissions['Captcha_Controller_get']=TRUE;
		
			$permissions['Shipment_Controller_get_list_for_veh_owner']=TRUE;
		
			$permissions['Shipment_Controller_get_pump_list_for_veh_owner']=TRUE;
		
			$permissions['Shipment_Controller_owner_set_agreed']=TRUE;
		
			$permissions['Shipment_Controller_owner_set_pump_agreed']=TRUE;
		
			$permissions['Vehicle_Controller_get_list']=TRUE;
		
			$permissions['Vehicle_Controller_get_object']=TRUE;
		
			$permissions['Vehicle_Controller_vehicles_with_trackers']=TRUE;
		
			$permissions['Vehicle_Controller_get_current_position']=TRUE;
		
			$permissions['Vehicle_Controller_get_current_position_all']=TRUE;
		
			$permissions['Vehicle_Controller_get_track']=TRUE;
		
			$permissions['Vehicle_Controller_get_stops_at_dest']=TRUE;
		
			$permissions['Vehicle_Controller_complete']=TRUE;
		
			$permissions['PumpVehicle_Controller_get_list']=TRUE;
		
			$permissions['PumpVehicle_Controller_get_object']=TRUE;
		
			$permissions['PumpVehicle_Controller_get_work_list']=TRUE;
		
			$permissions['Constant_Controller_get_values']=TRUE;
		
			$permissions['Weather_Controller_get_current']=TRUE;
		
			$permissions['ConcreteType_Controller_get_list']=TRUE;
		
			$permissions['ConcreteType_Controller_complete']=TRUE;
		
			$permissions['Destination_Controller_complete_dest']=TRUE;
		
			$permissions['Driver_Controller_get_list']=TRUE;
		
			$permissions['ProductionSite_Controller_get_list']=TRUE;
		
			$permissions['OrderPump_Controller_get_list']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>