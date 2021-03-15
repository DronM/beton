/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ViewObjectAjx
 * @requires core/extend.js
 * @requires controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function DOCMaterialProcurementDialog_View(id,options){
	options = options || {};	
	
	options.controller = new DOCMaterialProcurement_Controller();
	options.model = options.models.DOCMaterialProcurementList_Model;
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new EditDate(id+":date_time",{
			"labelCaption":"Дата:",
			"placeholder":"Дата поступления",
			"title":"Если оставить пустым будет проставлено текущее время"
			//"editMask":"99/99/9999 99:99",
			//"dateFormat":"d/m/Y H:i"
		}));	
		
		this.addElement(new EditString(id+":number",{
			"labelCaption":"Номер:",
			"placeholder":"Номер накладной",
			"length":"11"
		}));	

		this.addElement(new SupplierEdit(id+":suppliers_ref",{
			"placeholder":"Поставщик материала",
			"labelCaption":"Поставщик:"
		}));	
	
		this.addElement(new SupplierEdit(id+":carriers_ref",{
			"placeholder":"Перевозчик материала",
			"labelCaption":"Перевозчик:"
		}));	

		var ac_model_dr = new DOCMaterialProcurementDriverList_Model();
		this.addElement(new EditString(id+":driver",{
			"placeholder":"ФИО водителя",
			"labelCaption":"Водитель:",
			"maxLength":"50",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			"acController":options.controller,
			"acModel":ac_model_dr,
			"acPublicMethod":options.controller.getPublicMethod("complete_driver"),
			"acPatternFieldId": "driver",
			"acKeyFields":[ac_model_dr.getField("driver")],
			"acDescrFields":[ac_model_dr.getField("driver")],
			"acICase":"1",
			"acMid": "1"			
		}));			
		
		var ac_model_v = new DOCMaterialProcurementVehicleList_Model();
		this.addElement(new EditString(id+":vehicle_plate",{
			"placeholder":"Гос.номер ТС",
			"labelCaption":"Гос.номер:",
			"maxLength":"10",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			"acController":options.controller,
			"acModel":ac_model_v,
			"acPublicMethod":options.controller.getPublicMethod("complete_vehicle_plate"),
			"acPatternFieldId": "vehicle_plate",
			"acKeyFields":[ac_model_v.getField("vehicle_plate")],
			"acDescrFields":[ac_model_v.getField("vehicle_plate")],
			"acICase":"1",
			"acMid": "1"			
		}));			
		
		this.addElement(new MaterialSelect(id+":materials_ref",{
			"labelCaption":"Материал:"
		}));	

		this.addElement(new CementSiloEdit(id+":cement_silos_ref",{
			"labelCaption":"Силос (для цемента):",
			"title":"Указывается только для материалов, учитываемых в силосах (цемент,добавки)"
		}));	
		var ac_model_st = new DOCMaterialProcurementStoreList_Model();
		this.addElement(new EditString(id+":store",{
			"placeholder":"Место хранения материала",
			"labelCaption":"Склад:",
			"maxLength":"100",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			"acController":options.controller,
			"acModel":ac_model_st,
			"acPublicMethod":options.controller.getPublicMethod("complete_store"),
			"acPatternFieldId": "store",
			"acKeyFields":[ac_model_st.getField("store")],
			"acDescrFields":[ac_model_st.getField("store")],
			"acICase":"1",
			"acMid": "1"			
		}));			

		this.addElement(new EditFloat(id+":quant_net",{
			"precision":"2",
			"length":"19",
			"labelCaption":"Вес нетто:",
			"title":"Вес нетто, чистый вес"
		}));	
		
		this.addElement(new EditFloat(id+":quant_gross",{
			"precision":"2",
			"length":"19",
			"labelCaption":"Вес брутто:",
			"title":"Вес брутто, общий вес"
		}));	
		
	}
		
	DOCMaterialProcurementDialog_View.superclass.constructor.call(this,id,options);
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("number")})
		,new DataBinding({"control":this.getElement("suppliers_ref")})
		,new DataBinding({"control":this.getElement("carriers_ref")})
		,new DataBinding({"control":this.getElement("cement_silos_ref")})
		,new DataBinding({"control":this.getElement("materials_ref")})
		,new DataBinding({"control":this.getElement("driver")})
		,new DataBinding({"control":this.getElement("vehicle_plate")})
		,new DataBinding({"control":this.getElement("store")})		
		,new DataBinding({"control":this.getElement("quant_net")})
		,new DataBinding({"control":this.getElement("quant_gross")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("number")})
		,new CommandBinding({"control":this.getElement("suppliers_ref"),"fieldId":"supplier_id"})
		,new CommandBinding({"control":this.getElement("carriers_ref"),"fieldId":"carrier_id"})
		,new CommandBinding({"control":this.getElement("cement_silos_ref"),"fieldId":"cement_silos_id"})
		,new CommandBinding({"control":this.getElement("materials_ref"),"fieldId":"material_id"})
		,new CommandBinding({"control":this.getElement("driver")})
		,new CommandBinding({"control":this.getElement("vehicle_plate")})
		,new CommandBinding({"control":this.getElement("store")})
		,new CommandBinding({"control":this.getElement("quant_net")})
		,new CommandBinding({"control":this.getElement("quant_gross")})
	]);
	
}
//ViewObjectAjx,ViewAjxList
extend(DOCMaterialProcurementDialog_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

