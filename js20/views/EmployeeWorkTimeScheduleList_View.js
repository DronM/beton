/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function EmployeeWorkTimeScheduleList_View(id,options){	

	EmployeeWorkTimeScheduleList_View.superclass.constructor.call(this,id,options);

	var model = options.models.EmployeeWorkTimeScheduleList_Model;
	
	var self = this;
	var init_dt;
	if(options.models&&options.models.InitDate&&options.models.InitDate.getNextRow()){
		init_dt = DateHelper.strtotime(options.models.InitDate.getFieldValue("dt"));
	}
	var per_select = new EditPeriodMonth(id+":period_filter",{
		"dateFrom":init_dt,
		"onChange":function(dateTime){
			
			var grid = self.getElement("grid");
			grid.setFilter({
				"field":"day",
				"sign":"ge",
				"val":DateHelper.format(dateTime,"Y-m-d")
			});
			grid.setFilter({
				"field":"day",
				"sign":"le",
				"val":DateHelper.format(DateHelper.monthEnd(dateTime),"Y-m-d")
			});
			window.setGlobalWait(true);
			
			grid.onRefresh(function(){
				window.setGlobalWait(false);
			});
			
		}
	});
	this.addElement(per_select);	
	//EmployeeWorkTimeScheduleGrid
	this.addElement(new EmployeeWorkTimeScheduleGrid(id+":grid",{
		"model":model
	}));	
	
}
extend(EmployeeWorkTimeScheduleList_View,ViewAjx);
