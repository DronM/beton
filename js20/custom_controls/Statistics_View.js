/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends Control
 * @requires core/extend.js
 * @requires controls/Control.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Statistics_View(id,options){
	options = options || {};	
	
	options.className = this.CLASS_COLLAPSED;
	var self = this;
	options.events = {
		"click":function(){
			self.toggle();
		}
	}
	
	Statistics_View.superclass.constructor.call(this,id,"I",options);
}
//ViewObjectAjx,ViewAjxList
extend(Statistics_View,Control);

/* Constants */
Statistics_View.prototype.CLASS_COLLAPSED = "icon-plus3";
Statistics_View.prototype.CLASS_EXPANDED = "icon-minus3";

/* private members */

/* protected*/
Statistics_View.prototype.m_grid;

/* public methods */
Statistics_View.prototype.toggle = function(){
	if(DOMHelper.hasClass(this.m_node,this.CLASS_COLLAPSED)){
		var model = new ModelXML("get_vehicle_statistics",{
			"fields":["key","val"]
		});
		this.m_grid = new GridAjx(this.getId()+":grid",{
			"model":model,
			"keyIds":["key"],
			"className":OrderMakeList_View.prototype.TABLE_CLASS,
			"attrs":{"style":"width:100%;"},
			"readPublicMethod":(new Vehicle_Controller()).getPublicMethod("get_vehicle_statistics"),
			"editInline":false,
			"editWinClass":null,
			"commands":null,
			"popUpMenu":null,
			"head":new GridHead(this.getId+":grid:head",{
				"elements":[
					new GridRow(this.getId+":grid:head:row0",{
						"elements":[
							new GridCellHead(this.getId+":grid:key",{
								"value":"Показатель",
								"columns":[
									new GridColumn({"field":model.getField("key")})
								]
							})
							,new GridCellHead(this.getId+":grid:head:val",{
								"value":"Значение",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({"field":model.getField("val")})
								]
							})
						]
					})
				]
			}),
			"pagination":null,
			"autoRefresh":true,
			"refreshInterval":null,
			"rowSelect":false,
			"focus":false,
			"navigate":false,
			"navigateClick":false
		
		});
		DOMHelper.swapClasses(this.m_node,this.CLASS_EXPANDED,this.CLASS_COLLAPSED);
		this.m_grid.toDOM(this.m_node.parentNode);
	}
	else{
		DOMHelper.swapClasses(this.m_node,this.CLASS_COLLAPSED,this.CLASS_EXPANDED);
		this.m_grid.delDOM();
	}
}
