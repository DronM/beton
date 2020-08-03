/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function RawMaterialDialog_View(id,options){	

	options = options || {};
	
	options.controller = new RawMaterial_Controller();
	options.model = options.models.RawMaterial_Model;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":"Наименование:",
			"required":true,
			"length":"100",
			"focus":true
		}));	

		this.addElement(new EditNum(id+":ord",{
			"labelCaption":"Порядок сортировки:",
			"required":true
		}));	
			
		this.addElement(new EditCheckBox(id+":concrete_part",{
			"labelCaption":"Используется для бетона:"
		}));	

		this.addElement(new EditCheckBox(id+":is_cement",{
			"labelCaption":"Учитывать в силосе:"
		}));	

		this.addElement(new EditNum(id+":max_fact_quant_tolerance_percent",{
			"labelCaption":"Максимальный % отклонения от подборов:"
		}));	

		this.addElement(new EditFloat(id+":min_end_quant",{
			"labelCaption":"Минимальный остаток,тонн:",
			"precision":"4"
		}));	

		this.addElement(new EditNum(id+":store_days",{
			"labelCaption":"Запас дней:"
		}));	

		this.addElement(new EditFloat(id+":supply_volume",{
			"labelCaption":"Объем транспортного средства завоза:",
			"precision":"4"
		}));		
		
		this.addElement(new EditNum(id+":supply_days_count",{
			"labelCaption":"Количество дней завоза:"
		}));	
		
		
		
		this.addElement(new RawMaterialPriceList_View(id+":price_list",{
			"detail":true
		}));		

		this.addElement(new RawMaterialPriceForNormList_View(id+":price_for_norm_list",{
			"detail":true
		}));		

		this.addElement(new RawMaterialProcurRateList_View(id+":procure_rate_list",{
			"detail":true
		}));		
						
	}
	
	RawMaterialDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("ord")})
		,new DataBinding({"control":this.getElement("concrete_part")})
		,new DataBinding({"control":this.getElement("is_cement")})
		,new DataBinding({"control":this.getElement("max_fact_quant_tolerance_percent")})
		,new DataBinding({"control":this.getElement("min_end_quant")})
		,new DataBinding({"control":this.getElement("store_days")})
		,new DataBinding({"control":this.getElement("supply_volume")})
		,new DataBinding({"control":this.getElement("supply_days_count")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("ord")})
		,new CommandBinding({"control":this.getElement("concrete_part")})
		,new CommandBinding({"control":this.getElement("is_cement")})
		,new CommandBinding({"control":this.getElement("max_fact_quant_tolerance_percent")})
		,new CommandBinding({"control":this.getElement("min_end_quant")})
		,new CommandBinding({"control":this.getElement("store_days")})
		,new CommandBinding({"control":this.getElement("supply_volume")})
		,new CommandBinding({"control":this.getElement("supply_days_count")})
	]);
	
	this.addDetailDataSet({
		"control":this.getElement("price_list").getElement("grid"),
		"controlFieldId":"raw_material_id",
		"fieldId":"id"
	});

	this.addDetailDataSet({
		"control":this.getElement("price_for_norm_list").getElement("grid"),
		"controlFieldId":"raw_material_id",
		"fieldId":"id"
	});

	this.addDetailDataSet({
		"control":this.getElement("procure_rate_list").getElement("grid"),
		"controlFieldId":"material_id",
		"fieldId":"id"
	});
		
}
extend(RawMaterialDialog_View,ViewObjectAjx);
