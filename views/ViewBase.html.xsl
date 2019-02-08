<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:variable name="BASE_PATH" select="/document/model[@id='ModelVars']/row[1]/basePath"/>
<xsl:variable name="VERSION" select="/document/model[@id='ModelVars']/row[1]/scriptId"/>
<xsl:variable name="TITLE" select="/document/model[@id='ModelVars']/row[1]/title"/>
<xsl:variable name="TOKEN">
	<xsl:choose>
		<xsl:when test="not(/document/model[@id='ModelVars']/row[1]/token='')"><xsl:value-of select="concat('&amp;token=',/document/model[@id='ModelVars']/row[1]/token)"/></xsl:when>
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
	
	
<!--************* Main template ******************** -->		
<xsl:template match="/document">
<html>
	<head>
		<xsl:call-template name="initHead"/>
		
		<title>Package manager</title>
		
		<script>
			function pageLoad(){				
				<xsl:call-template name="initApp"/>
				<xsl:if test="not(//menuitem[@default='TRUE']) or concat(//menuitem[@default='TRUE']/@t,'_Model')!=model[not(@sysModel='1')]/@id">
					<xsl:call-template name="modelFromTemplate"/>
				</xsl:if>
				
				<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
					throw Error(CommonHelper.longString(function () {/*
					<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>
					*/}));
				</xsl:if>	
			}
		</script>
	</head>
	<body onload="pageLoad();">
		<!--  -->
		<!--<button onclick="alert(DateHelper.strtotime('2016-12-06T06:30:00'));">1111111111</button>-->
		<div id="wrapper">
			<xsl:call-template name="initMenu"/>
			
			<!-- Page Content -->
			<div id="page-wrapper">
			    <div class="container-fluid">
				<div class="row">
				    <div id="windowData" class="col-lg-12">
				    	<xsl:apply-templates select="model[@htmlTemplate='TRUE']"/>
				    </div>
				    <!-- /.col-lg-12 -->
				    <div class="windowMessage hidden">
				    </div>
				</div>
				<!-- /.row -->
			    </div>
			    <!-- /.container-fluid -->
			</div>
			<!-- /#page-wrapper -->
		</div>
		<!-- /#wrapper -->
	    
		<xsl:call-template name="initJS"/>
	</body>
</html>		
</xsl:template>


<!--************* Javascript files ******************** -->
<xsl:template name="initJS">
	<!-- bootstrap resolution-->
	<div id="users-device-size">
	  <div id="xs" class="visible-xs"></div>
	  <div id="sm" class="visible-sm"></div>
	  <div id="md" class="visible-md"></div>
	  <div id="lg" class="visible-lg"></div>
	</div>

	<div id="waiting">
		<div>Ждите</div>
		<img src="img/loading.gif"/>
	</div>
	
	<!--ALL js modules -->
	<xsl:apply-templates select="model[@id='ModelJavaScript']/row"/>
	
	<script>
		var dv = document.getElementById("waiting");
		if (dv!==null){
			dv.parentNode.removeChild(dv);
		}
	</script>
</xsl:template>


<!--************* Application instance ******************** -->
<xsl:template name="initApp">
	
	var application = new AppCustom({
		servVars:{
			<xsl:for-each select="model[@id='ModelVars']/row/*">
			<xsl:if test="position() &gt; 1">,</xsl:if>"<xsl:value-of select="local-name()"/>":'<xsl:value-of select="node()"/>'
			</xsl:for-each>
		}
		<xsl:if test="model[@id='ConstantValueList_Model']">
		,"constantXMLString":CommonHelper.longString(function () {/*
				<xsl:copy-of select="model[@id='ConstantValueList_Model']"/>
		*/})
		</xsl:if>
		<!--	
		<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
			,
			"error":"<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>"
		</xsl:if>	
		-->
	});
	<xsl:call-template name="initAppWin"/>
		
	<!-- [@default='FALSE']-->
	<xsl:variable name="def_menu_item" select="//menuitem[@default='TRUE']"/>
	<xsl:if test="$def_menu_item">
	if(window.location.href.indexOf("?") &lt; 0 || window.location.href.indexOf("token=") &gt;=0) {
		var iRef = DOMHelper.getElementsByAttr("true", CommonHelper.nd("side-menu"), "defaultItem",true,"A")[0];
		application.showMenuItem(iRef,'<xsl:value-of select="$def_menu_item/@c"/>','<xsl:value-of select="$def_menu_item/@f"/>','<xsl:value-of select="$def_menu_item/@t"/>');
	}
	</xsl:if>
	
</xsl:template>

<!--************* Window instance ******************** -->
<xsl:template name="initAppWin">	
	var applicationWin = new AppWin({
		"bsCol":("col-"+$('#users-device-size').find('div:visible').first().attr('id')+"-"),
		"app":application
		<!--
		<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
			,"error":"<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>"
		</xsl:if>	
		-->
	});
	/*
	function showMenuItem(c,f,t,extra){
		window.getApp().showMenuItem(c,f,t,extra);
	}
	*/
</xsl:template>

<!--************* Page head ******************** -->
<xsl:template name="initHead">
	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
	<xsl:apply-templates select="model[@id='ModelVars']"/>
	<xsl:apply-templates select="model[@id='ModelStyleSheet']/row"/>
	<link rel="icon" type="image/png" href="img/favicon.png"/>
</xsl:template>


<!-- ************** Main Menu ******************** -->
<xsl:template name="initMenu">
	<xsl:if test="model[@id='MainMenu_Model']">
	<!-- Navigation -->
	<nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
	    <div class="navbar-header">
		<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
		    <span class="sr-only">Toggle navigation</span>
		    <span class="icon-bar"></span>
		    <span class="icon-bar"></span>
		    <span class="icon-bar"></span>
		</button>
		<a class="navbar-brand" href="index.php">Package manager</a>
	    </div>
	    <!-- /.navbar-header -->

	    <ul class="nav navbar-top-links navbar-right">
		<li class="dropdown">
		    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
		        <i class="fa fa-user fa-fw"></i>
		        <xsl:apply-templates select="/document/model[@id='ModelVars']/row/user_name"/>
		        <i class="fa fa-caret-down"></i>
		    
		    </a>
		    <ul class="dropdown-menu dropdown-user">
		        <li><a href="index.php?c=User_Controller&amp;f=get_profile&amp;t=UserProfile{$TOKEN}"
		        onclick="window.getApp().showMenuItem(this,'User_Controller','get_profile','UserProfile{$TOKEN}');return false;">
		        		<i class="fa fa-user fa-fw"></i> Профиль
		        	</a>
		        </li>
		        <li>
		        	<a href="#" onclick="window.getApp().showAbout();return false;"><i class="fa fa-info fa-fw"></i> О программе</a>
		        </li>		        
		        <li class="divider"></li>
		        <li><a href="index.php?c=User_Controller&amp;f=logout_html{$TOKEN}"><i class="fa fa-sign-out fa-fw"></i> Выход</a>
		        </li>
		    </ul>
		    <!-- /.dropdown-user -->
		</li>
		<!-- /.dropdown -->
	    </ul>
	    <!-- /.navbar-top-links -->

	    <div class="navbar-default sidebar" role="navigation">
		<div class="sidebar-nav navbar-collapse">
		    <ul class="nav" id="side-menu">
		        <xsl:apply-templates select="/document/model[@id='MainMenu_Model']"/>
		       
		        <xsl:if test="/document/model[@id='ModelVars']/row/role_id='admin'">
			<!-- service -->
			<li>
				<a href="#"><i class="fa fa-fw fa-wrench"></i> Сервис<span class="fa arrow"></span></a>
				<ul class="nav nav-second-level">
					<li>
						<a href="index.php?c=View_Controller&amp;f=get_list&amp;t=ViewList"
						onclick="window.getApp().showMenuItem(this,'View_Controller','get_list','ViewList');return false;">
							<i class="fa fa-fw"></i> Все формы
						</a>
					</li>		        				
				
					<li>
						<a href="index.php?c=Constant_Controller&amp;f=get_list&amp;t=ConstantList"
						onclick="window.getApp().showMenuItem(this,'Constant_Controller','get_list','ConstantList');return false;">
							<i class="fa fa-fw"></i> Константы
						</a>
					</li>		        				
				
					<li>
						<a href="index.php?c=MainMenuConstructor_Controller&amp;f=get_list&amp;t=MainMenuConstructorList"
						onclick="window.getApp().showMenuItem(this,'MainMenuConstructor_Controller','get_list','MainMenuConstructorList');return false;">
							<i class="fa fa-fw"></i> Конструктор меню
						</a>
					</li>		        				
					<li>
						<a href="#" onclick="window.getApp().showAbout();return false;">
							<i class="fa fa-fw"></i> О программе
						</a>
					</li>
					
				</ul>						
			</li>
		       </xsl:if>
		        
			<li>
			    <a href="index.php?c=User_Controller&amp;f=get_profile&amp;t=UserProfile{$TOKEN}"
			    onclick="window.getApp().showMenuItem(this,'User_Controller','get_profile','UserProfile{$TOKEN}');return false;">
			    <i class="fa fa-user fa-fw"></i> Профиль пользователя </a>
			</li>					        
			<li>
			    <a href="index.php?c=User_Controller&amp;f=logout_html{$TOKEN}"><i class="fa fa-sign-out fa-fw"></i> Выход </a>
			</li>					        
		    </ul>
		</div>
		<!-- /.sidebar-collapse -->
	    </div>
	    <!-- /.navbar-static-side -->
	</nav>
	</xsl:if>
</xsl:template>


<!--************* Menu item ******************-->
<xsl:template match="menuitem">
	<xsl:choose>
		<xsl:when test="menuitem">			
			<!-- multylevel-->
			<li>
				<a href="#">
					<xsl:if test="@glyphclass">
					<i class="{@glyphclass}"></i>
					</xsl:if>
					<xsl:value-of select="concat(' ',@descr)"/>
					<span class="fa arrow"></span>
				</a>
				<ul class="nav nav-second-level">
					<xsl:apply-templates select="menuitem"/>
				</ul>						
			</li>
		</xsl:when>
		<xsl:otherwise>
			<!-- one level-->
			<li>
			    <a href="index.php?c={@c}&amp;f={@f}&amp;t={@t}{$TOKEN}"
			    onclick="window.getApp().showMenuItem(this,'{@c}','{@f}','{@t}{$TOKEN}');return false;"
			    defaultItem="{@default='TRUE'}">
				<xsl:if test="@glyphclass">
				<i class="{@glyphclass}"></i>
				</xsl:if>
				<xsl:value-of select="concat(' ',@descr)"/>
			    </a>
			</li>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--*************** templates ********************* -->
<xsl:template match="model[@templateId]">
<xsl:copy-of select="*"/>
</xsl:template>

<xsl:template name="modelFromTemplate">
	
	<!-- All data models to namespace -->
	var models = {};
	<xsl:for-each select="model[not(@sysModel='1')]">
	<xsl:variable name="m_id" select="@id"/>
	models.<xsl:value-of select="$m_id"/> = new <xsl:value-of select="$m_id"/>({
		"data":CommonHelper.longString(function () {/*
			<xsl:copy-of select="/document/model[@id=$m_id]"/>
		*/})
	});
	</xsl:for-each>
	
	<xsl:for-each select="model[@templateId]">
		var v_<xsl:value-of select="@templateId"/> = new <xsl:value-of select="@templateId"/>_View("<xsl:value-of select="@templateId"/>",{
			"models":models,
			"template":CommonHelper.longString(function () {/*
			<xsl:copy-of select="./*"/>
			*/}),
			"variantStorage":{
				"name":"<xsl:value-of select="@templateId"/>"
				<xsl:if test="/document/model[@id='VariantStorage_Model']">
				,"model":models.VariantStorage_Model
				</xsl:if>			
			}			
		});
		v_<xsl:value-of select="@templateId"/>.toDOM(CommonHelper.nd("windowData"));	
	</xsl:for-each>
</xsl:template>


<!-- ERROR 
<xsl:template match="model[@id='ModelServResponse']/row/result='1'">
throw Error(CommonHelper.longString(function () {/*
<xsl:value-of select="descr"/>
*/}));
</xsl:template>
-->

<!--System variables -->
<xsl:template match="model[@id='ModelVars']/row">
	<xsl:if test="author">
		<meta name="Author" content="{author}"></meta>
	</xsl:if>
	<xsl:if test="keywords">
		<meta name="Keywords" content="{keywords}"></meta>
	</xsl:if>
	<xsl:if test="description">
		<meta name="Description" content="{description}"></meta>
	</xsl:if>
	
</xsl:template>

<!-- CSS -->
<xsl:template match="model[@id='ModelStyleSheet']/row">	
	<link rel="stylesheet" href="{concat(href,'?',$VERSION)}" type="text/css"/>
</xsl:template>

<!-- Javascript -->
<xsl:template match="model[@id='ModelJavaScript']/row">
	<script src="{concat(href,'?',$VERSION)}"></script>
</xsl:template>

<!-- Error
<xsl:template match="model[@id='ModelServResponse']/row">
	<xsl:if test="result/node()='1'">
	<div class="error"><xsl:value-of select="descr"/></div>
	</xsl:if>
</xsl:template>
 -->

</xsl:stylesheet>
