/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function RawMaterialConsRateDateGridCmd(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	
	this.m_btn = new RawMaterialConsRateCalcBtn(id+"btn",{
		"cmd":true
	});
	
	options.controls = [
		this.m_btn
	]
	
	RawMaterialConsRateDateGridCmd.superclass.constructor.call(this,id,options);
		
}
extend(RawMaterialConsRateDateGridCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
RawMaterialConsRateDateGridCmd.prototype.setGrid = function(v){
	RawMaterialConsRateDateGridCmd.superclass.setGrid.call(this,v);
	
	this.m_btn.m_grid = v;
	this.m_grid = v;
}

