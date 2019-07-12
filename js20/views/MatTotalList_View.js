/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MatTotalList_View(id,options){
	options = options || {};	
	
	MatTotalList_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	this.addElement(new EditPeriodMonth(id+":period",{
		"onChange":function(dFrom,dTo){
			dFrom = DateHelper.getStartOfShift(new Date(dFrom.getTime()+24*60*60*1000));
			dTo = DateHelper.getEndOfShift(new Date(dTo.getTime()+24*60*60*1000));
			var f_from = new FieldDateTime("d_from",{"value":dFrom});
			var f_to = new FieldDateTime("d_to",{"value":dTo});
			
			var gr = self.getElement("grid");
			gr.setFilter({
				"field":"date_time",
				"sign":"ge",
				"val":f_from.getValueXHR()
			});
			gr.setFilter({
				"field":"date_time",
				"sign":"le",
				"val":f_to.getValueXHR()
			});
			
			window.setGlobalWait(true);
			gr.onRefresh(function(){
				window.setGlobalWait(false);
			});
		}
	}));
	
	this.addElement(new MatTotalGrid(id+":grid",{
		"model":options.models.total_list,
		"modelMaterial":options.models.material_list
	}));	
	
}
//ViewObjectAjx,ViewAjxList
extend(MatTotalList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

