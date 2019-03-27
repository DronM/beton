/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjServer
  
 * @requires core/extend.js
 * @requires core/ControllerObjServer.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function SiteFeedBack_Controller(options){
	options = options || {};
	options.listModelClass = SiteFeedBackList_Model;
	SiteFeedBack_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.add_set_viewed();
		
}
extend(SiteFeedBack_Controller,ControllerObjServer);

			SiteFeedBack_Controller.prototype.addGetList = function(){
	SiteFeedBack_Controller.superclass.addGetList.call(this);
	
	
	
	var pm = this.getGetList();
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	var f_opts = {};
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldString("date_time_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "ФИО";
	pm.addField(new FieldText("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment",f_opts));
	var f_opts = {};
	f_opts.alias = "Email";
	pm.addField(new FieldText("email",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("viewed",f_opts));
	var f_opts = {};
	f_opts.alias = "Просмотрено";
	pm.addField(new FieldString("viewed_descr",f_opts));
}

			SiteFeedBack_Controller.prototype.add_set_viewed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_viewed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

		