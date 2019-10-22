/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjServer
  
 * @requires core/extend.js
 * @requires core/ControllerObjServer.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function RawMaterialConsRate_Controller(options){
	options = options || {};
	options.listModelClass = RawMaterialConsRateList_Model;
	options.objModelClass = RawMaterialConsRateList_Model;
	RawMaterialConsRate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_raw_material_cons_report();
		
}
extend(RawMaterialConsRate_Controller,ControllerObjServer);

			RawMaterialConsRate_Controller.prototype.addUpdate = function(){
	RawMaterialConsRate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("rate_date_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_rate_date_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_concrete_type_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("concrete_type_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat1_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat2_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat3_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat4_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat5_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat6_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat7_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat8_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat9_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("mat10_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat1_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat2_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat3_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat4_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat5_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat6_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat7_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat8_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat9_rate",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("mat10_rate",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldInt("mat1_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat2_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat3_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat4_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat5_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat6_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat7_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat8_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat9_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("mat10_id",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat1_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat2_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat3_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat4_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat5_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat6_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat7_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat8_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat9_rate",options));
	
		var options = {};
				
		pm.addField(new FieldFloat("mat10_rate",options));
	
	
}

			RawMaterialConsRate_Controller.prototype.addDelete = function(){
	RawMaterialConsRate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("rate_date_id",options));
	var options = {"required":true};
	options.alias = "Марка бетона";	
	pm.addField(new FieldInt("concrete_type_id",options));
	var options = {"required":true};
	options.alias = "Материал";	
	pm.addField(new FieldInt("raw_material_id",options));
}

			RawMaterialConsRate_Controller.prototype.addGetList = function(){
	RawMaterialConsRate_Controller.superclass.addGetList.call(this);
	
	
	
	var pm = this.getGetList();
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	var f_opts = {};
	
	pm.addField(new FieldInt("rate_date_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("concrete_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("concrete_type_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat1_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat2_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat3_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat4_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat5_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat6_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat7_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat8_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat9_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mat10_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat1_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat2_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat3_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat4_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat5_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat6_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat7_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat8_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat9_rate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("mat10_rate",f_opts));
}

			RawMaterialConsRate_Controller.prototype.addGetObject = function(){
	RawMaterialConsRate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("rate_date_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldInt("concrete_type_id",f_opts));
		var options = {};
						
		pm.addField(new FieldInt("mat1_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat2_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat3_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat4_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat5_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat6_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat7_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat8_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat9_id",options));
	
		var options = {};
						
		pm.addField(new FieldInt("mat10_id",options));
	
	
	pm.addField(new FieldString("mode"));
}

			RawMaterialConsRate_Controller.prototype.add_raw_material_cons_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('raw_material_cons_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("grp_fields",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("agg_fields",options));
	
			
	this.addPublicMethod(pm);
}

		