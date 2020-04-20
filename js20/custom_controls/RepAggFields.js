/* Copyright (c) 2012 
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
function RepAggFields(id,options){
	options = options ||{};

	options.commandPanel = new RepFieldsCommands(id+"_cmd",{
		"noInsert":true,"noEdit":true,"noDelete":true});
	
	//Заголовок
	options.head = new GridHead();
	var row = new GridRow(id+"_head_row");	
	
	row.addElement(new GridDbHeadCell(id+"_col_agg_fields",{
		"value":"Наименование"}));
	row.addElement(new GridDbHeadCell(id+"_col_agg_fn",{
		"value":"Функция"}));
		
	options.head.addElement(row);
	options.body = new GridBody();
	
	RepAggFields.superclass.constructor.call(this,
		id,options);	
}
extend(RepAggFields,RepBaseFields);

/*
	id
	name
*/
RepAggFields.prototype.addField = function(fieldStruc){
	var row = new GridRow(this.getId()+"_row_"+fieldStruc.id,{
		"attrs":{"fieldId":fieldStruc.id}});
		
	var type = new EditSelect(this.getId()+"_agg_"+fieldStruc.id,{
			"tableLayout":false});
	row.addElement(new GridCell(this.getId()+"_"+fieldStruc.id+"_agg_name",
		{"controlContainer":type,"value":fieldStruc.name}
	));
			
	type.addElement(new EditSelectOption("undefined",{
		"optionSelected":true,
		"optionDescr":"не рассчитывать",
		"optionId":"undefined"}));
	type.addElement(new EditSelectOption("sum",{
		"optionDescr":"сумма",
		"optionId":"sum"}));
	type.addElement(new EditSelectOption("avg",{
		"optionDescr":"среднее",
		"optionId":"avg"}));		
	type.addElement(new EditSelectOption("min",{
		"optionDescr":"минимум",
		"optionId":"min"}));		
	type.addElement(new EditSelectOption("max",{
		"optionDescr":"максисум",
		"optionId":"max"}));		
		
	row.addElement(new GridCell(this.getId()+"_"+fieldStruc.id+"_agg_fn",
		{"controlContainer":type}
	));
	
	this.m_body.addElement(row);
}
RepAggFields.prototype.getParams = function(filterStruc){
	var b = this.getBody();
	var rows = b.m_node.getElementsByTagName("tr");
	for (var i=0;i<rows.length;i++){
		var r_id = rows[i].id;
		var id = b.m_elements[r_id].getAttr("fieldId");
		var v = b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_agg_name"].m_controlContainer.getValue();
		if (v!="undefined"){
			filterStruc.agg_fields=(filterStruc.agg_fields==null)? "":filterStruc.agg_fields;
			filterStruc.agg_fields+=((filterStruc.agg_fields)? ",":"")+id;
			filterStruc.agg_types=(filterStruc.agg_types==null)? "":filterStruc.agg_types;
			filterStruc.agg_types+=((filterStruc.agg_types)? ",":"")+v;			
		}
	}	
}
RepAggFields.prototype.addFields = function(fields){
	if (fields){
		for (var i=0;i<fields.length;i++){
			if (fields[i].agg){
				this.addField(fields[i]);
			}
		}
	}			
}
RepAggFields.prototype.getSelectedCount = function(){
	var res = 0;
	var b = this.getBody();
	var rows = b.m_node.getElementsByTagName("tr");
	for (var i=0;i<rows.length;i++){

		var r_id = rows[i].id;
		var id = b.m_elements[r_id].getAttr("fieldId");
		var v = b.m_elements[r_id].m_elements[this.getId()+"_"+id+"_agg_name"].m_controlContainer.getValue();
		if (v!="undefined"){
			res++;
		}
	}	
	return res;	
}
