/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Grid
 * @requires core/extend.js
 * @requires controls/.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MaterialMakeOrderGrid(id,options){
	options = options || {};	
	
	var model = options.model;
	
	CommonHelper.merge(options,
		{
			"attrs":{"style":"width:100%;"},
			"keyIds":["material_id"],
			"readPublicMethod":null,
			"editInline":false,
			"editWinClass":null,
			"commands":null,
			"popUpMenu":null,
			"head":new GridHead(id+":head",{
				"elements":[
					new GridRow(id+":head:row0",{
						"elements":[
							new GridCellHead(id+":head:material_descr",{
								"value":"Материал",
								"columns":[
									new GridColumn({"field":model.getField("material_descr")})
								]
							})
							,new GridCellHead(id+":head:quant_ordered",{
								"value":"Заявлено",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_ordered"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_procured",{
								"value":"Приход",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_procured"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_balance",{
								"value":"Ост.тек.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_balance"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_morn_balance",{
								"value":"Ост.утро",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_morn_balance"),
										"precision":3
									})
								]
							})
						]
					})
				]
			}),
			"pagination":null,
			"autoRefresh":false,
			"refreshInterval":null,
			"rowSelect":false,
			"focus":false,
			"navigate":false,
			"navigateClick":false
		}
	);
	
	MaterialMakeOrderGrid.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(MaterialMakeOrderGrid,Grid);

/* Constants */


/* private members */

/* protected*/


/* public methods */

