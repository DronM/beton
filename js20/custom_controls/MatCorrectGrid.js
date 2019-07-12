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
function MatCorrectGrid(id,options){
	options = options || {};	
	
	this.m_matModel = options.modelMaterial;
	
	var contr = new RawMaterial_Controller();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	
	CommonHelper.merge(options,{
		"keyIds":["shift"],
		"readPublicMethod":contr.getPublicMethod("correct_list"),
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
			"cmdAllCommands":false
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
	
	MatCorrectGrid.superclass.constructor.call(this,id,options);
}

extend(MatCorrectGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
MatCorrectGrid.prototype.onGetData = function(resp){
	var model_mat;
	if(resp){
		model_mat = resp.getModel("material_list");
		this.m_model = resp.getModel("correct_list");
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
			"mat_class":( (i==0||i%2==0)? "mat_even":"mat_odd" ),
			"norm":0,
			"corrected":0,
			"obnul":0,
			"balance":0
		});
		mat_indexes["mat_"+model_mat.getFieldValue("id")] = i;
		i++;
	}
	var cur_bal_date = DateHelper.format(DateHelper.time(),"d/m/Y");
	var cur_date,prev_mat_ind;
	this.m_model.reset();
	while(this.m_model.getNextRow()){
		if(!cur_date||cur_date!=this.m_model.getFieldValue("shift_descr")){
			//new date
			cur_date = this.m_model.getFieldValue("shift_descr");
			var date_data = {
				"date_descr":this.m_model.getFieldValue("shift_descr"),
				"cur_date":(cur_date==cur_bal_date),
				"date_materials":[]
			}
			
			for(var i=0;i<options.materials.length;i++){
				date_data.date_materials.push({
					"mat_id":options.materials[i].mat_id,
					"dt":this.m_model.getFieldValue("shift"),
					"mat_class":( (i==0||i%2==0)? "mat_even":"mat_odd"),
					"corrected_editted":false,
					"obnul_editted":(parseFloat(this.m_model.getFieldValue("obnul"))!=0),
					"norm":0,
					"corrected":0,
					"obnul":0,
					"balance":0
				})
			
			}
			options.dates.push(date_data);
		}
		var mat_ind = mat_indexes["mat_"+this.m_model.getFieldValue("material_id")];
		
		date_data.date_materials[mat_ind].norm = (Math.round(parseFloat(this.m_model.getFieldValue("norm"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].corrected = (Math.round(parseFloat(this.m_model.getFieldValue("corrected"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].obnul = (Math.round(parseFloat(this.m_model.getFieldValue("obnul"))*1000)/1000).toFixed(3);
		date_data.date_materials[mat_ind].balance = (Math.round(parseFloat(this.m_model.getFieldValue("balance"))*1000)/1000).toFixed(3);
		
		//totals
		options.materials[mat_ind].norm+= parseFloat(date_data.date_materials[mat_ind].norm);
		options.materials[mat_ind].corrected+= parseFloat(date_data.date_materials[mat_ind].corrected);
		options.materials[mat_ind].obnul+= parseFloat(date_data.date_materials[mat_ind].obnul);
		options.materials[mat_ind].balance+= parseFloat(date_data.date_materials[mat_ind].balance);
	}
	options.quant_shipment = (Math.round(options.quant_shipment*100)/100).toFixed(2);
	
	for(var i=0;i<options.materials.length;i++){
		options.materials[i].norm = (Math.round(options.materials[i].norm*1000)/1000).toFixed(3);
		options.materials[i].corrected = (Math.round(options.materials[i].corrected*1000)/1000).toFixed(3);
		options.materials[i].obnul = (Math.round(options.materials[i].obnul*1000)/1000).toFixed(3);
		options.materials[i].balance = (Math.round(options.materials[i].balance*1000)/1000).toFixed(3);
	}
	this.setTemplateOptions(options);
	
	this.setTemplate(window.getApp().getTemplate("MatCorrectGridInner"));
	
	//this.setSelection();
	
	var self = this;
	$(".quant_consump_editable").dblclick(function(){
		if(self.m_editMode)return;
		self.m_editMode = true;
		self.onEditCons.call(self,this,this.getAttribute("mat_id"),this.getAttribute("dt"));
	});
}

MatCorrectGrid.prototype.onEditCons = function(n,matId,dt){
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

MatCorrectGrid.prototype.onEditConsComplete = function(){
	var val = this.m_matEdit.getValue();
	this.m_matEdit.delDOM();
	delete this.m_matEdit;
	this.m_editCell.textContent = (Math.round(val*1000)/1000).toFixed(3);
	this.m_editMode = false;
}

MatCorrectGrid.prototype.onSaveCons = function(matId,dt){
	var val = this.m_matEdit.getValue();
	if (val!=this.m_matEdit.m_oldVal){
		/*console.log("Setting matId="+matId+" dt="+DateHelper.strtotime(dt)+" quant="+val)
		DOMHelper.addClass(this.m_editCell,"quant_consump_editted");
		this.onEditConsComplete();
		*/
		var meth = (DOMHelper.hasClass(this.m_editCell,"obnul"))? "correct_obnul":"correct_consumption";
		var self = this;
		var pm = (new RawMaterial_Controller()).getPublicMethod(meth);
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
