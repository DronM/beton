/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepCondFields(id,options){
	options = options ||{};

	//Заголовок
	options.head = new GridHead();
	var row = new GridRow(id+"_head_row");	
	var self = this;
	row.addElement(new GridDbHeadCell(id+"_col_field_names",{"value":"Колонки"}));	
	row.addElement(new GridDbHeadCell(id+"_col_filter",{
		"controlContainer":new EditCheckBox(id+"_col_filtered_toggle",{
			"labelCaption":"Фильтр",
			"attrs":{"title":"Фильтровать по значению колонки"},
			"className":"filtered_toggle",
			"labelAlign":"left",
			"events":{
				"onChange":function(elem){						
						self.onSetAll("filtered_toggle",elem.checked);
					}
				}
			})	
		}));
	row.addElement(new GridDbHeadCell(id+"_col_filter_vals",{
		"value":"Значения фильтра"}));
		
	options.head.addElement(row);
	options.body = new GridBody();
	
	RepCondFields.superclass.constructor.call(this,
		id,options);
}
extend(RepCondFields,RepBaseFields);

/*
	id
	name
	filtered
	filterControl
*/
RepCondFields.prototype.addField = function(fieldStruc){
	if (fieldStruc.filterControl){
		var row = new GridRow(this.getId()+"_row_"+fieldStruc.id,{
			"attrs":{"fieldId":fieldStruc.id}});
	
		//наименование
		row.addElement(new GridCell(this.getId()+"_"+fieldStruc.id+"_name",
			{"value":fieldStruc.name}
		));
	
		//фильтровать
		row.addElement(new GridCell(this.getId()+"_"+fieldStruc.id+"_filtered",
			{"controlContainer":new EditCheckBox(this.getId()+"_filtered_"+fieldStruc.id),
			"className":"filtered_toggle",
			"attrs":{"align":"center"}
			}
		));
	
		//значение фильтра
		row.addElement(new GridCell(this.getId()+"_"+fieldStruc.id+"_filterVal",
			{"controlContainer":fieldStruc.filterControl,
			"className":"input-group"
			}
		));
	
		this.m_body.addElement(row);
	}
}
RepCondFields.prototype.getParams = function(filterStruc){
	var b = this.getBody();
	var rows = b.m_node.getElementsByTagName("tr");
	
	filterStruc.field_sep = "@";
	for (var i=0;i<rows.length;i++){
		var r_id = rows[i].id;
		
		if (!b.m_elements[r_id])continue;
		
		var id = b.m_elements[r_id].getAttr("fieldId");
		
		if (b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_filtered"].m_controlContainer.getChecked()){
			//filtered Проверить галочку фильтр!
			var ctrl = b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_filterVal"].m_controlContainer;
			var f_val = ctrl.getValue();			
			if (f_val!="undefined"){
				if (ctrl.m_keyFieldIds){
					id = ctrl.m_keyFieldIds[0];
					f_val = ctrl.getFieldValue(id);					
				}
				//console.log("id="+id+" checked="+b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_filtered"].m_controlContainer.getChecked()+" val="+f_val);
				filterStruc.fields=(filterStruc.fields==null)? "":filterStruc.fields;
				filterStruc.fields+=((filterStruc.fields)? filterStruc.field_sep:"")+id;
			
				filterStruc.signs=(filterStruc.signs==null)? "":filterStruc.signs;
				filterStruc.signs+=((filterStruc.signs)? filterStruc.field_sep:"")+ (ctrl.filterSign || "e");
			
				filterStruc.vals=(filterStruc.vals==null)? "":filterStruc.vals;
				filterStruc.vals+=((filterStruc.vals)? filterStruc.field_sep:"")+f_val;
			};
		}		
	}	
}
RepCondFields.prototype.onSetAll = function(id,flag){
	var b = this.getBody();
	var rows = b.m_node.getElementsByTagName("tr");
	for (var i=0;i<rows.length;i++){
		var r_id = rows[i].id;
		var id = b.m_elements[r_id].getAttr("fieldId");
		b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_filtered"].m_controlContainer.setChecked(flag);
	}	
}
