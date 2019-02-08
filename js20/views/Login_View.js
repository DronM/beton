/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function Login_View(id,options){	

	Login_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	this.addElement(new ErrorControl(id+":error"));
	
	var check_for_enter = function(e){
		e = EventHelper.fixKeyEvent(e);
		if (e.keyCode==13){
			self.login();
		}
	};
					
	this.addElement(new EditString(id+":user",{				
		"placeholder":this.CTRL_USER_LAB,
		"editContClassName":"form-group",
		"focus":true,
		"cmdClear":false,
		"events":{"keydown":check_for_enter}
	}));	
	
	this.addElement(new EditPassword(id+":pwd",{
		"placeholder":this.CTRL_PWD_LAB,
		"editContClassName":"form-group",
		"events":{"keydown":check_for_enter}
	}));	

	/*
	this.addElement(new EditCheckBox(id+":rememberMe",{
		"html":"<input/>"
	}));	
	*/
	
	this.addElement(new Button(id+":submit_login",{
		"caption":this.CTRL_SBM_CAP,
		"onClick":function(){
			self.login();
		}
	}));
	
	//Commands
	var contr = new User_Controller();
	var pm = contr.getPublicMethod("login");
	
	this.addCommand(new Command("login",{
		"publicMethod":pm,
		"control":this.getElement("submit_login"),
		"async":false,
		"bindings":[
			new DataBinding({"field":pm.getField("name"),"control":this.getElement("user")}),
			new DataBinding({"field":pm.getField("pwd"),"control":this.getElement("pwd")})
			//,new DataBinding({"field":pm.getField("rememberMe"),"control":this.getElement("rememberMe")})
		]		
	}));

}
extend(Login_View,ViewAjx);

Login_View.prototype.setError = function(s){
	this.getElement("error").setValue(s);
}

Login_View.prototype.login = function(){
	var self = this;
	this.execCommand("login",
		function(){
			document.location.href = window.getApp().getHost();
		},
		function(resp,errCode,errStr){
			if (errCode==100){
				self.setError(self.ER_LOGIN);
			}
			else{
				self.setError((errCode!=undefined)? (errCode+" "+errStr):errStr);
			}
		}
	);
}
