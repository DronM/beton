/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewObjectAjx
 * @requires core/extend.js
 * @requires controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function AstIncomeCall_View(id,options){
	options = options || {};	
	
	if (options.models && options.models.active_call){
		
	}
	if (options.models && options.models.active_call && (options.models.active_call.getRowIndex()>=0 || options.models.active_call.getNextRow()) ){			
		var call_view_class;
		if(options.models.active_call.getFieldValue("client_id")){
			call_view_class = new AstUnknownCall_View;
		}
		else{
			call_view_class = new AstOldClientCall_View_View;
		}
		
		var call_view = new call_view_class(id+":client",{
			"models":options.models
		});
		
	
	AstIncomeCall_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(AstIncomeCall_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

