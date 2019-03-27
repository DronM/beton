/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ShipmentGridCmdPrintInvoice(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	
	this.m_btn = new PrintInvoiceBtn(id+"btn",{
		"cmd":true
	});
	
	options.controls = [
		this.m_btn
	]
	
	/*
	options.glyph = "glyphicon-print";
	options.title="Напечатать накладную";
	options.caption = "Накладная ";
	*/
	ShipmentGridCmdPrintInvoice.superclass.constructor.call(this,id,options);
		
}
extend(ShipmentGridCmdPrintInvoice,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ShipmentGridCmdPrintInvoice.prototype.setGrid = function(v){
	ShipmentGridCmdPrintInvoice.superclass.setGrid.call(this,v);
	
	this.m_btn.m_grid = v;
	this.m_grid = v;
}

