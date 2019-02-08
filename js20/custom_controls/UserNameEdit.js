/* Copyright (c) 2016
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
*/
/** Requirements
 * @requires core/extend.js
 * @requires controls/EditSelect.js
*/

/* constructor
@param object options{
	@param string modelDataStr
}
*/
function UserNameEdit(id,options){
	options = options || {};

	options.labelCaption = "Наименование:",
	options.placeholder = "Краткое наименование пользователя",
	options.required = true;
	options.maxlength = 50;
	
	UserNameEdit.superclass.constructor.call(this,id,options);
	
}
extend(UserNameEdit,EditString);

