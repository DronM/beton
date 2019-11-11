/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function PumpVehicleList_View(id,options){	

	PumpVehicleList_View.superclass.constructor.call(this,id,options);

	var model = options.models.PumpVehicleList_Model;
	var contr = new PumpVehicle_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var is_v_owner = (window.getApp().getServVar("role_id")=="vehicle_owner");
	
	var filters = {
		"make":{
			"binding":new CommandBinding({
				"control":new MakeEdit(id+":filter-ctrl-make",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("make")}),
			"sign":"e"		
		}
		,"owner":{
			"binding":new CommandBinding({
				"control":new VehicleOwnerEdit(id+":filter-ctrl-owner",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("vehicle_owner_id")}),
			"sign":"e"		
		}
		,"feature":{
			"binding":new CommandBinding({
				"control":new FeatureEdit(id+":filter-ctrl-feature",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("feature")}),
			"sign":"e"		
		}

	}
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"cmdDelete":!is_v_owner,
			"cmdInsert":!is_v_owner,
			"cmdCopy":!is_v_owner,
			"cmdEdit":!is_v_owner			
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:pump_vehicles_ref",{
							"value":"Автомобиль",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_vehicles_ref"),
									/*"formatFunction":function(f){
										var res = "";
										var v = f.pump_vehicles_ref.getValue();
										if(v&&!v.isNull()){
											res = v.getDescr();
											v = f.owner.getValue();
											if(v){
												res = res + " ("+v+")";
											}
										}
										return res;
									},*/
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"
								})
							],
							"sort":"asc",
							"sortable":true
						})
						,is_v_owner? null:new GridCellHead(id+":grid:head:vehicle_owner",{
							"value":"Владелец",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_owners_ref"),
									"ctrlClass":VehicleOwnerEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sortable":true
						})						
						/*
						,new GridCellHead(id+":grid:head:phone_cel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("phone_cel")
									})
							]
						})
						*/						
						,new GridCellHead(id+":grid:head:phone_cels",{
							"value":"Телефоны",
							"columns":[
								new GridColumn({
									"field":model.getField("phone_cels"),
									"ctrlClass":TelListGrid,
									"ctrlOptions":{
									},
									"formatFunction":function(fields,cell){
										var cell_n = cell.getNode();
										
										var v = fields.phone_cels.getValue();
										if(v&&v.rows){
											for(var j=0;j<v.rows.length;j++){
												var tel = v.rows[j].fields.tel;
												var tel_m = tel;
												if(tel_m && tel_m.length==10){
													tel_m = "+7"+tel;
												}
												else if(tel_m && tel_m.length==11){
													tel_m = "+7"+tel.substr(1);
												}
												
												var t_tag = document.createElement("A");
												t_tag.className = "tel_in_list";
												t_tag.setAttribute("href","tel:"+tel_m);												
												if(window.getWidthType()!="sm"){
													t_tag.setAttribute("tel",tel_m);
													EventHelper.add(t_tag,"click",function(e){
														e.preventDefault();
														window.getApp().makeCall(this.getAttribute("tel"));
														/*
														var pm = (new Caller_Controller()).getPublicMethod("call");
														pm.setFieldValue("tel",this.getAttribute("tel"));
														var tel_el = this;
														pm.run({
															"ok":function(resp){
																window.showTempNote("Пытаемся позвонить на номер: "+tel_el.getAttribute("tel"),null,10000);
															}
														})
														*/
													});
												}
												t_tag.textContent = CommonHelper.maskFormat(tel,window.getApp().getPhoneEditMask());
												t_tag.setAttribute("title","Позвонить на номер "+t_tag.textContent);
												cell_n.appendChild(t_tag);
											}
										}
										return "";
									}									
								})
							]
						})
						
						,is_v_owner? null:new GridCellHead(id+":grid:head:pump_prices",{
							"value":"Ценовые схемы",
							"columns":[
								new GridColumn({
									"field":model.getField("pump_prices"),
									"formatFunction":function(fields){
										var res = "";
										var v = fields.pump_prices.getValue();
										if(v&&v.rows){
											for(var j=0;j<v.rows.length;j++){
												res+= (res=="")? "":", ";
												res+=  v.rows[j].fields.pump_price.getDescr();
											}
										}
										return res;
									},
									"ctrlClass":PumpVehiclePriceListGrid,//PumpPriceEdit
									"ctrlOptions":{
										"labelCaption":"",
										"contTagName":"TD"
									},
									"ctrlBindFieldId":"pump_prices"
								})
							]
						})
						,new GridCellHead(id+":grid:head:pump_length",{
							"value":"Длина подачи",
							"columns":[
								new GridColumn({
									"field":model.getField("pump_length"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"labelCaption":""
									}									
								})
							]
						})						
						,is_v_owner? null:new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text"),
									"ctrlClass":EditString,
									"ctrlBindFieldId":"comment_text",
									"ctrlOptions":{
										"maxLength":"100"
									}
								})
							]
						})						
												
						,is_v_owner? null:new GridCellHead(id+":grid:head:deleted",{
							"value":"Удален",
							"columns":[
								new GridColumnBool({
									"field":model.getField("deleted"),
									"showFalse":false,
									"ctrlClass":EditCheckBox,
									"ctrlBindFieldId":"deleted"
								})
							]
						})						
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(PumpVehicleList_View,ViewAjxList);
