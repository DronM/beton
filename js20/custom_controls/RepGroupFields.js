/* Copyright (c) 2015 
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
*/
//ф
/** Requirements
 * @requires common/functions.js
*/

/* constructor */
function RepGroupFields(id,options){
	options = options ||{};

	options.commandPanel = new RepFieldsCommands(id+"_cmd");
	
	//Заголовок
	options.head = new GridHead();
	var row = new GridRow(id+"_head_row");	
	
	row.addElement(new GridDbHeadCell(id+"_col_group_names",{
		"value":"Наименование"}));
	row.addElement(new GridDbHeadCell(id+"_col_group_fields",{
		"value":"Поля"}));
		
	options.head.addElement(row);
	options.body = new GridBody();
		
	this.m_fields = clone2(options.fields);
	
	RepGroupFields.superclass.constructor.call(this,
		id,options);
		
}
extend(RepGroupFields,RepBaseFields);

RepGroupFields.prototype.editRow = function(rowNode,cellVals){	
	var self = this;
	this.m_modal_v = new RepGroupFields_View(uuid(),{
		"initVals":{"fields":cellVals[1],"name":cellVals[0]},
		"onClose":function(res){
			if (res){
				var name = self.m_modal_v.getControl(self.m_modal_v.getId()+"_name").getValue();			
				var fields = self.m_modal_v.getSelectedFields();
				var f_names = "";
				var f_cnt = 0;
				for (var i in fields){
					f_names+= (f_names=="")? "":", ";
					f_names+= fields[i].name;
					f_cnt++;
				}
				var row;
				if (rowNode){
					//редактирование					
					rowNode.setAttribute("fields",array2json(fields));
					rowNode.cells[0].innerHTML = name;
					rowNode.cells[1].innerHTML = f_names;
				}
				else if (f_cnt){
					//вставка
					var r_id = uuid();
					row = new GridRow(r_id,{"attrs":{"fields":array2json(fields)}});
					row.addElement(new GridCell(r_id+"_c0",{"value":name}));
					row.addElement(new GridCell(r_id+"_c1",{"value":f_names}));
				}
				if (row){
					row.toDOM(self.getBody().getNode());
				}
			}
			self.m_modal.removeDOM();										
		}
	});
	this.m_modal = new WindowFormModalBS(uuid(),{
		content:this.m_modal_v});
	this.m_modal.toDOM(document.body);
}

RepGroupFields.prototype.onInsert = function(){	
	for(var i=0;i<this.m_fields.length;i++){			
		this.m_fields[i].checked = false;
	}		
	this.editRow(null,["",this.m_fields]);
}
RepGroupFields.prototype.onEdit = function(rowId,keys){	
	var n = nd(rowId);
	if (n){
		var fields = json2obj(DOMHandler.getAttr(n,"fields"));
		
		for(var i=0;i<this.m_fields.length;i++){			
			this.m_fields[i].checked = !(fields[this.m_fields[i].id]==undefined);
		}		
		var cells = n.getElementsByTagName("td");
		this.editRow(n,[cells[0].textContent,this.m_fields]);
	}
}
/* перекрытый метод базового класса!!! Здесь идем по строкам DOM а не по внутреннему объекту!*/
RepGroupFields.prototype.getValueAsObj= function(){
	var data = {};
	var table = this.getBody().getNode();	
	var r=0;
	while(row=table.rows[r++]){
		data[row.id] = {
			"cells":{},
			"fields":json2obj(DOMHandler.getAttr(row,"fields")),
			"class":DOMHandler.getAttr(row,"class")
		};
	
	  	var c=0;
		while(cell=row.cells[c++]){
			data[row.id].cells[cell.id]={
				"html":cell.innerHTML,
				"class":DOMHandler.getAttr(cell,"class")
			};
		}
	}	
	return data;
}

RepGroupFields.prototype.setValueFromObj= function(obj){
	var table = this.getBody().getNode();	
	while(row=table.rows[0]){
		DOMHandler.removeNode(row);
	}
	//новая таблица
	for (var r_id in obj){
		var row = document.createElement("tr");
		row.id = r_id;
		DOMHandler.setAttr(row,"fields",array2json(obj[r_id].fields));
		DOMHandler.setAttr(row,"class",obj[r_id]["class"]);
		
		for (var c_id in obj[r_id].cells){
			var cell = document.createElement("td");
			cell.id = c_id;
			cell.innerHTML = obj[r_id].cells[c_id].html;
			cell.className = obj[r_id]["class"];
			row.appendChild(cell);
		}
		table.appendChild(row);
	}
}
RepGroupFields.prototype.getParams = function(filterStruc){
	var b = this.getBody();
	var groups = null;
	var rows = b.m_node.getElementsByTagName("tr");
	for (var i=0;i<rows.length;i++){
		if (rows[i].cells&&rows[i].cells.length){
			var fields = json2obj(DOMHandler.getAttr(rows[i],"fields"));
			
			if (!groups){
				groups = [];
			}
			var field_ids = "";
			var field_descrs = "";
			for (var fid in fields){
				field_ids+= ((field_ids=="")? "":",") +fid;
				field_descrs+= ((field_descrs=="")? "":",") + fields[fid]["name"];
			}
			
			var descr = "";
			if (rows[i].cells[0].textContent){
				descr = rows[i].cells[0].textContent;
			}
			else{
				descr = rows[i].cells[1].textContent;
			}
			
			groups.push({
				"descr":descr,
				"fields":field_ids,
				"fieldDescrs":field_descrs
			});
			
		}
	}
	filterStruc.groups = array2json(groups);
}

RepGroupFields.prototype.getSelectedCount = function(){
	return this.getBody().m_node.getElementsByTagName("tr").length;
}
