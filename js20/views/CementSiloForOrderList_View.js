/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Control
 * @requires core/extend.js
 * @requires controls/Control.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function CementSiloForOrderList_View(id,options){
	options = options || {};	
	
	this.m_listView = options.listView;
	this.setData(options.model);
	options.templateOptions = this.getTemplateOptions();
	
	CementSiloForOrderList_View.superclass.constructor.call(this,id,"TEMPLATE",options);
	
	this.fillSilos();
}
//ViewObjectAjx,ViewAjxList
extend(CementSiloForOrderList_View,Control);

/* Constants */


/* private members */
CementSiloForOrderList_View.prototype.m_silos;

/* protected*/


/* public methods */

CementSiloForOrderList_View.prototype.setData = function(model){
	
	/** !!!перересовка только с случае, если изменился состав силосов, иначе просто отрисовка наполненности!!!
	 * т.е. либо m_silos еще не инициализирована, либо надо проверять новый набор данных...
	 */
	var is_init = (this.m_silos==undefined);	
	var redraw = false;
	
	if(!is_init){
		var silo_cnt = 0;
		var silo_id;
		while(model.getNextRow()){
			silo_id = model.getFieldValue("id"); 
			if(!this.m_silos["silo_"+silo_id]
			||!document.getElementById("silo_canvas_"+silo_id)
			){
				redraw = true;
			}
			else if(this.m_silos["silo_"+silo_id]){
				
				this.m_silos["silo_"+silo_id].balance = parseFloat(model.getFieldValue("balance"),10);
				if(isNaN(this.m_silos["silo_"+silo_id].balance)){
					this.m_silos["silo_"+silo_id].balance = 0;
				}
			}
			silo_cnt++;
		}
		//for(p in this.m_silos)silo_cnt++;
		if(!redraw && (model.getRowCount()!=silo_cnt)){
			//console.log("this.m_silos.length="+silo_cnt)
			//console.log("model.getRowCount()="+model.getRowCount())
			redraw = true;
		}
		model.reset();
	}	
//console.log("is_init="+is_init)
//console.log("redraw="+redraw)		
	if(is_init || redraw){
		this.m_silos = [];//reinitialize
		var templ_opts = {
			"productionSites":[]
		};
		var prod_site,cur_prod_site;
		while(model.getNextRow()){
			var s_name = model.getFieldValue("name");
			var s_id = model.getFieldValue("id");
		
			cur_prod_site = model.getFieldValue("production_sites_ref");
		
			if(!prod_site || prod_site.productionSiteId!=cur_prod_site.getKey("id")){
				prod_site = {
					"productionSiteName":cur_prod_site.getDescr(),
					"productionSiteId":cur_prod_site.getKey("id"),
					"silos":[]
				};
				templ_opts.productionSites.push(prod_site);
			}
			prod_site.silos.push({
				"siloName":s_name,
				"siloId":s_id
			});

			this.m_silos["silo_"+s_id] = {
				"name":s_name,
				"id":s_id,
				"balance":model.getFieldValue("balance"),
				"load_capacity":model.getFieldValue("load_capacity")
			}
		}
		this.setTemplateOptions(templ_opts);		
	}
		
	if(redraw){
		/*
		var parent = this.getNode().parentNode;
		this.delDOM();
		this.toDOM(parent);
		*/
		this.setTemplate(window.getApp().getTemplate("CementSiloForOrderList_View"));
	}
	
	if(!is_init){
		this.fillSilos();
	}
}

CementSiloForOrderList_View.prototype.fillSilos = function(){	
	for(var silo_id in this.m_silos){
		var silo_n = document.getElementById("silo_canvas_"+this.m_silos[silo_id].id);
		var silo_cont_n = document.getElementById("silo_cont_"+this.m_silos[silo_id].id);
		if(silo_n && silo_cont_n){
			var percent = (!this.m_silos[silo_id].load_capacity
					||isNaN(this.m_silos[silo_id].load_capacity)
					||!this.m_silos[silo_id].balance
					||isNaN(this.m_silos[silo_id].balance)
				)?
				0:Math.floor((this.m_silos[silo_id].balance / this.m_silos[silo_id].load_capacity * 100));
			if(percent>100){
				percent=100;
			}
			else if(isNaN(percent)){
				percent = 0;
			}
			//console.log("Silo "+this.m_silos[silo_id].id+" Capac:"+this.m_silos[silo_id].load_capacity+" balance="+this.m_silos[silo_id].balance+" percent="+percent)
			
			silo_n.title = "Остаток:"+((this.m_silos[silo_id].balance && !isNaN(this.m_silos[silo_id].balance))? this.m_silos[silo_id].balance:0);//+", двойной клик для обнуления."
			if(this.m_silos[silo_id].load_percent!=percent){
				silo_n.setAttribute("silo_id",this.m_silos[silo_id].id);				
				this.m_silos[silo_id].load_percent = percent;
				//console.log("Redraw silo №"+silo_id)
				this.drawSilo(silo_n,silo_cont_n,0,0,percent);
				var self = this;
				EventHelper.add(silo_n,"dblclick",function(e){
					self.onCorrectQuant(e.target.getAttribute("silo_id"));
				});
			}
		}
	}
}

CementSiloForOrderList_View.prototype.drawSilo = function(siloNode,siloContNode,posLeft,posTop,fillPercent){
	var silo_height = 100;
	var silo_cone_height_k = 0.25;// 1/5		
	var silo_cone_width = 8;//point part width
	var silo_width = 56;// 56/8=7 cone parts (even!!!)
	var fill_tolerance = 2;//2

	var silo_cone_height = silo_height * silo_cone_height_k;
	var silo_cone_parts = Math.floor(silo_width / silo_cone_width);//must be even!
	var silo_cone_parts_one_side = (silo_cone_parts-1) / 2;
	
	var fill_style = "grey";//#ff0000
	var cx = siloNode.getContext("2d");		
	cx.clearRect(posLeft, posTop,silo_width,silo_height+silo_height*silo_cone_height_k);
	cx.lineWidth = "2";
	cx.beginPath();
	cx.moveTo(posLeft, posTop);
	cx.lineTo(posLeft, posTop + silo_height);
	cx.lineTo(posLeft  + silo_cone_width * silo_cone_parts_one_side , posTop + silo_height + silo_cone_height);
	cx.lineTo(posLeft  + silo_cone_width * (silo_cone_parts_one_side+1) , posTop + silo_height + silo_cone_height);
	cx.lineTo(posLeft  + silo_cone_width * silo_cone_parts , posTop + silo_height);
	cx.lineTo(posLeft  + silo_cone_width * silo_cone_parts , posTop);
	cx.lineTo(posLeft , posTop);
	cx.stroke(); 
	
	// filling
	var extra_height = Math.floor( silo_cone_height * silo_cone_width * silo_cone_parts_one_side / silo_width );
	var fill_main_h = Math.floor( (silo_height + silo_cone_height) * fillPercent / 100) + extra_height - fill_tolerance;
	var fill_main_top = posTop + silo_height + silo_cone_height - fill_main_h;
	/*
	console.log("fill_main_h="+fill_main_h)
	console.log("extra_height="+extra_height)
	console.log("fill_main_top="+fill_main_top)
	console.log("cone_part_end="+(posTop+silo_height-fill_tolerance*2))
	*/
	if(fill_main_top>posTop+silo_height+silo_cone_height-fill_tolerance*2){
		//no filling
		return;
	}
	
	cx.fillStyle = fill_style;
	cx.lineWidth = "0.5";
	cx.beginPath();
	var main_part = (fill_main_h>silo_cone_height);
	if(main_part){
		//main figure part
		cx.moveTo(posLeft + fill_tolerance, fill_main_top + fill_tolerance);//posTop + fill_tolerance
		cx.lineTo(posLeft + fill_tolerance, posTop + silo_height - fill_tolerance);
	}
	else{
		//cone part
		//y = mx + b
		//where m - slope (y2-y1)/(x2-x1)
		//and b - y-intercept
		//x = (y-b)/m
		var m = silo_cone_height / (silo_cone_width * silo_cone_parts_one_side);
		var b = (posTop + silo_height + silo_cone_height) - (m * (posLeft  + silo_cone_width * silo_cone_parts_one_side) );
		var cone_pos_y = fill_main_top + fill_tolerance;
		var cone_pos_x = Math.floor( ( cone_pos_y - b) / m );			
		cx.moveTo(cone_pos_x+fill_tolerance, cone_pos_y+fill_tolerance);
		//console.log("TOP="+cone_pos_y+" LEFT="+cone_pos_x)
	}		
	cx.lineTo(posLeft  + silo_cone_width * silo_cone_parts_one_side, posTop + silo_height - fill_tolerance + silo_cone_height);
	cx.lineTo(posLeft + silo_cone_width * (silo_cone_parts_one_side+1) , posTop + silo_height - fill_tolerance + silo_cone_height);		
	
	if(main_part){
		cx.lineTo(posLeft - fill_tolerance + silo_cone_width * silo_cone_parts , posTop + silo_height-fill_tolerance);
		cx.lineTo(posLeft - fill_tolerance + silo_cone_width * silo_cone_parts , fill_main_top + fill_tolerance*2);	
		cx.lineTo(posLeft + fill_tolerance , fill_main_top + fill_tolerance*2);
	}
	else{
		var n = (posLeft - fill_tolerance + silo_cone_width * silo_cone_parts_one_side) - cone_pos_x;
		var n2 = posLeft + silo_cone_width * (silo_cone_parts_one_side+1) - fill_tolerance + n;
		cx.lineTo( n2  , cone_pos_y+fill_tolerance);
	}
	
	cx.fill();
	//cx.stroke(); 
	
	DOMHelper.delAllChildren(siloContNode);
	
	//text percent
	DOMHelper.setText(siloContNode,fillPercent+"%");
	siloContNode.style = "position:relative;top:-"+( (silo_height+silo_cone_height)/2 + 20)+"px;left:"+( (silo_width+silo_cone_width)/2-25)+"px";
	/*
	var t_div = document.createElement("DIV");
	t_div.style="position:relative;top:"+(posTop + (silo_height+silo_cone_height)/2)+"px;left:"+(posLeft + (silo_width+silo_cone_width)/2-15)+"px";
	var t_node = document.createTextNode(fillPercent+"%"); 
	t_div.appendChild(t_node);
	siloNode.appendChild(t_div);
	*/
	
	//if(vehicle.vehicles_ref){
		/*
		var img = document.createElement("IMG");
		img.src = "img/wait-sm.gif";
		img.style="position:absolute;top:"+(posTop+fill_tolerance*2+10)+"px;left:"+(posLeft + (silo_width+silo_cone_width)/2-7)+"px";
		siloContNode.appendChild(img);
		*/
		
		//download
		//var img_download_top = (silo_height+silo_cone_height+10-32);
		/*
		var img_dl = document.createElement("IMG");
		img_dl.src = "img/cement_download.gif";
		img_dl.height = "32";
		img_dl.width = "32";
		img_dl.style="position:relative;top:50px;left:-5px";
		siloContNode.appendChild(img_dl);
		*/
		/*
		//mixer
		var img = document.createElement("IMG");
		img.src = "img/mixer.png";
		img.style="position:relative;top:"+(img_download_top+img_dl.height-5)+"px;left:"+(posLeft + (silo_width+silo_cone_width)/2-10)+"px";
		siloNode.appendChild(img);
		*/
	//}
}
	
CementSiloForOrderList_View.prototype.setCorrectionOnServer = function(newValues,fieldValues){
	var self = this;
	var pm = (new CementSilo_Controller()).getPublicMethod("reset_balance");
	pm.setFieldValue("cement_silo_id",fieldValues.silo_id);
	pm.setFieldValue("comment_text",newValues.comment_text);
	pm.run({
		"ok":function(){
			window.showTempNote(fieldValues.silo_descr+": остаток обнулен",null,5000);				
			self.closeCorrection();
			self.m_listView.refresh();
		}
	})	
}
	
CementSiloForOrderList_View.prototype.onCorrectQuant = function(siloId){
	if(!siloId || !parseInt(siloId,10))return;
	var elem_id = "silo_"+siloId;
	
	if(!this.m_silos[elem_id].balance){
		throw new Error("Нет остатка в силосе "+this.m_silos[elem_id]["name"]);
	}
	
	this.closeCorrection();
	
	var self = this;
	this.m_view = new EditJSON("CorrectQuant:cont",{
		"elements":[
			new ControlContainer("CorrectQuant:cont:text","DIV",{
				"className":"alert alert-info alert-styled-left alert-bordered"
				,"elements":[
					new Control("CorrectQuant:cont:text:p","DIV",{
						"className":"no-margin text-semibold",
						"value":"Количество по данному силосу будет обнулено, для продолжение нажмите ОК"
					})
				]
				
			})
			,new EditText("CorrectQuant:cont:comment_text",{
				"labelCaption":"Комментарий:",
				"rows":3,
				"focus":true
			})
		]
	});
	this.m_form = new WindowFormModalBS("CorrectQuant",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Обнуление силоса "+this.m_silos[elem_id]["name"],
		"onClickCancel":function(){
			self.closeCorrection();
		},
		"onClickOk":function(){
			var res = self.m_view.getValueJSON();
			self.setCorrectionOnServer(res,self.m_view.fieldValues);
		}
	});
	this.m_view.fieldValues = {
		"silo_id":siloId,
		"silo_descr":this.m_silos[elem_id]["name"]
	}
	
	this.m_form.open();
	
}

CementSiloForOrderList_View.prototype.closeCorrection = function(){
	if(this.m_view)this.m_view.delDOM()
	if(this.m_form)this.m_form.delDOM();
	if(this.m_view)delete this.m_view;
	if(this.m_form)delete this.m_form;			
}

