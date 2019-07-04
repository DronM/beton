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
function VehicleOwnerTotReport_View(id,options){
	options = options || {};	
	
	var self = this;
	options.addElement = function(){
		this.addElement(new EditPeriodMonth(id+":period",{
			"onChange":function(dFrom,dTo){
				self.makeReport(dFrom);
			}
		}));
		this.addElement(new Control(id+":report","DIV",{
		}));
		
	}
	
	VehicleOwnerTotReport_View.superclass.constructor.call(this,id,options);
	
	this.makeReport(this.getElement("period").getDateFrom());
}
//ViewObjectAjx,ViewAjxList
extend(VehicleOwnerTotReport_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */
VehicleOwnerTotReport_View.prototype.makeReport = function(d){
	window.setGlobalWait(true);
	var pm = (new VehicleOwner_Controller()).getPublicMethod("get_tot_report");
	pm.setFieldValue("date",d);
	pm.setFieldValue("templ","VehicleOwnerTotReport");
	var self = this;
	pm.run({
		"viewId":"ViewXSLT",
		"retContentType":"text",
		"ok":function(resp){
			self.getElement("report").getNode().innerHTML = resp;
		},
		"all":function(){
			window.setGlobalWait(false);
		}
	});
}
