/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends GridAjx
 * @requires core/extend.js
 * @requires controls/GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MatTotalGrid(id,options){
	options = options || {};	
	
	this.m_matModel = options.modelMaterial;
	
	var contr = new RawMaterial_Controller();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	
	CommonHelper.merge(options,{
		"keyIds":["date_time"],
		"readPublicMethod":contr.getPublicMethod("total_list"),
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":false,
			"cmdEdit":true,
			"cmdDelete":false,
			"cmdFilter":false,
			"filters":null,
			"cmdSearch":false,
			"variantStorage":null,
			"cmdAllCommands":false,
			"cmdPrint":false
		}),
		"popUpMenu":popup_menu,
		"head":null,
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":0,//constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"navigate":false,
		"navigateClick":false,
		"focus":true
	});	
	
	MatTotalGrid.superclass.constructor.call(this,id,options);
}

extend(MatTotalGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
MatTotalGrid.prototype.onGetData = function(resp){
	var model_mat;
	if(resp){
		model_mat = resp.getModel("material_list");
		this.m_model = resp.getModel("total_list");
	}
	else{
		//init
		model_mat = this.m_matModel;
	}
	
	var options = {
		"materials":[],
		"dates":[],
		"quant_shipment":0
	};
	
	var mat_indexes = {};
	var i=0;
	while(model_mat.getNextRow()){
		options.materials.push({
			"mat_id":model_mat.getFieldValue("id"),
			"mat_name":model_mat.getFieldValue("name"),
			"mat_avg_cons":model_mat.getFieldValue("avg_cons"),
			"mat_class":( (i==0||i%2==0)? "mat_even":"mat_odd" ),
			"quant_procur":0,
			"quant_consump":0
		});
		mat_indexes["mat_"+model_mat.getFieldValue("id")] = i;
		i++;
	}
	var cur_bal_date = DateHelper.format(DateHelper.time(),"d/m/Y");
	var cur_date,prev_mat_ind;
	this.m_model.reset();
	while(this.m_model.getNextRow()){
		if(!cur_date||cur_date!=this.m_model.getFieldValue("date_time_descr")){
			//new date
			cur_date = this.m_model.getFieldValue("date_time_descr");
			var q = parseFloat(this.m_model.getFieldValue("quant_shipment"));
			if(isNaN(q))q=0.0;
			var date_data = {
				"date_descr":this.m_model.getFieldValue("date_time_descr"),
				"quant_shipment":q.toFixed(2),
				"cur_date":(cur_date==cur_bal_date),
				"date_materials":[]
			}
			
			options.quant_shipment+= q;
			
			for(var i=0;i<options.materials.length;i++){
				date_data.date_materials.push({
					"mat_id":options.materials[i].mat_id,
					"dt":this.m_model.getFieldValue("date_time"),
					"mat_class":( (i==0||i%2==0)? "mat_even":"mat_odd"),
					"quant_consump_editted":(parseFloat(this.m_model.getFieldValue("quant_correct"))!=0),
					"quant_beg":0,
					"quant_procur":0,
					"quant_consump":0,
					"quant_end":0
				})
			
			}
			options.dates.push(date_data);
		}
		var mat_ind = mat_indexes["mat_"+this.m_model.getFieldValue("material_id")];
		
		date_data.date_materials[mat_ind].quant_beg = (Math.round(parseFloat(this.m_model.getFieldValue("quant_beg"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].quant_procur = (Math.round(parseFloat(this.m_model.getFieldValue("quant_procur"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].quant_consump = (Math.round(parseFloat(this.m_model.getFieldValue("quant_consump"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].quant_end = (Math.round(parseFloat(this.m_model.getFieldValue("quant_end"))*1000)/1000).toFixed(3);
		
		//totals
		options.materials[mat_ind].quant_procur+= parseFloat(date_data.date_materials[mat_ind].quant_procur);
		options.materials[mat_ind].quant_consump+= parseFloat(date_data.date_materials[mat_ind].quant_consump);
		
	}
	options.quant_shipment = (Math.round(options.quant_shipment*100)/100).toFixed(2);
	
	for(var i=0;i<options.materials.length;i++){
		options.materials[i].quant_procur = (Math.round(options.materials[i].quant_procur*1000)/1000).toFixed(3);
		options.materials[i].quant_consump = (Math.round(options.materials[i].quant_consump*1000)/1000).toFixed(3);
	}
	this.setTemplateOptions(options);
	
	this.setTemplate(window.getApp().getTemplate("MatTotalGridInner"));
	
	//this.setSelection();
	
	var self = this;
	$(".quant_consump_editable").dblclick(function(){
		if(self.m_editMode)return;
		self.m_editMode = true;
		self.onEditCons.call(self,this,this.getAttribute("mat_id"),this.getAttribute("dt"));
	});
}

MatTotalGrid.prototype.onEditCons = function(n,matId,dt){
	var self = this;
	var val = n.textContent;
	this.m_editCell = n;
	this.m_oldEditval = val;
	this.m_matEdit = new EditFloat("mat_inplace_edit",{
		"inline":true,
		"cmdOpen":true,
		"precision":"3",
		"unsigned":false,
		"value":val,
		"events":{
			"keydown":function(event){
				event = EventHelper.fixMouseEvent(event);
				var key_code = (event.charCode) ? event.charCode : event.keyCode;
				if (key_code==13){
					self.onSaveCons(matId,dt);
				}
				else if (key_code==27){//esc
					this.setValue(self.m_oldEditval);
					self.onEditConsComplete();
				}		
			
			}
		}
	});
	n.textContent="";
	this.m_matEdit.toDOM(n);
	this.m_matEdit.m_node.focus();
	this.m_matEdit.m_node.setSelectionRange(0,val.length,"backward");
	
}

MatTotalGrid.prototype.onEditConsComplete = function(){
	var val = this.m_matEdit.getValue();
	this.m_matEdit.delDOM();
	delete this.m_matEdit;
	this.m_editCell.textContent = (Math.round(val*1000)/1000).toFixed(3);
	this.m_editMode = false;
}

MatTotalGrid.prototype.onSaveCons = function(matId,dt){
	var val = this.m_matEdit.getValue();
	if (val!=this.m_matEdit.m_oldVal){
		/*console.log("Setting matId="+matId+" dt="+DateHelper.strtotime(dt)+" quant="+val)
		DOMHelper.addClass(this.m_editCell,"quant_consump_editted");
		this.onEditConsComplete();
		*/
		var self = this;
		var pm = (new RawMaterial_Controller()).getPublicMethod("correct_consumption");
		pm.setFieldValue("material_id",matId);
		pm.setFieldValue("date",DateHelper.strtotime(dt));
		pm.setFieldValue("quant",val);
		pm.run({
			"all":function(){
				DOMHelper.addClass(self.m_editCell,"quant_consump_editted");
				//self.onEditComplete();
				self.m_editMode = false;
				self.onRefresh();//totals
			}
		});
	}
	else{
		//same value
		this.onEditComplete();
	}

}
