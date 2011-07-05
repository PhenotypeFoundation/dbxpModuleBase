<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<% /*
	This layout can be used as a base for your module. It loads jquery, jquery-ui and jquery-datatables. It also
	loads javascripts for the top navigation and pagination in datatables (see documentation below about pagination).

	You can use this layout in your projects by setting

		<meta name="layout" content="module">

	This way you will use the default layout. However, that way you have to set the to navigation bar in each view. You can 
	also create your own layout and extend the module layout. This can be done like the following example. 

	<g:applyLayout name="module">
		<html>
		<head>
	        <title><g:layoutTitle default="dbXP test module | dbNP"/></title>
			<g:layoutHead />
		</head>
		<body>
			<content tag="topnav">
				<!-- Insert only li tags for the top navigation, without surrounding ul -->
				<li><a href="${resource(dir: '')}">Home</a></li>
				<li>
					<a href="#" onClick="return false;">GSCF</a>
					<ul class="subnav">
						<li><g:link url="${org.codehaus.groovy.grails.commons.ConfigurationHolder.config.gscf.baseURL}">Go to GSCF</g:link></li>
					</ul>
				</li>
			</content>
			<g:layoutBody/>
		</body>
		</html>
	</g:applyLayout>

	You have to add the li's for the topnav list in between <content tag="topnav"> and </content>. You can also
	add additional javascripts, css files or content to the page, just as you are used to.
*/ %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-EN" xml:lang="en-EN">
	<head>
		<title><g:layoutTitle default="${ConfigurationHolder.config.module.name} | dbXP"/></title>
		<link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico', plugin: 'dbxpModuleBase' )}" type="image/x-icon"/>
		
		<% /* Make sure the module javascript always knows their baseUrl */ %>
		<script type="text/javascript">
			var baseUrl = '${resource(dir: '')}';
		</script>

		<% /* Import stylesheets for basic look and feel */ %>
		<link rel="stylesheet" href="${resource(dir: 'css', file: 'module.css', plugin: 'dbxpModuleBase' )}"/>
		
		<% /* Import jquery, jquery UI and jquery DataTables */ %>
		<g:javascript library="jquery" plugin="jquery" />
		<jqui:resources theme="cupertino" themeCss="${resource(dir: 'css/cupertino', file: 'jquery-ui-1.8.13.custom.css', plugin: 'dbxpModuleBase' )}" />
		<jqDT:resources jqueryUI="${true}" />
		
		<% /* Import datatables style sheet */ %>
		<link rel="stylesheet" href="${resource(dir: 'css', file: 'datatables.css', plugin: 'dbxpModuleBase')}"/>
					
		<% /* Import javascript for top navigation */ %>
		<script type="text/javascript" src="${resource(dir: 'js', file: 'topnav.js', plugin: 'dbxpModuleBase')}"></script>

		<% /* 
			Import javascripts and stylesheets for pagination and common buttons
		
			Usage:
		
			Use a 'paginate' class on a table to create a paginated table using datatables plugin.
		
				<table id='samples' class="paginate">
					<thead>
						<tr><th>Name</th><th># samples</th></tr>
					</thead>
					<tbody>
						<tr><td>Robert</td><td>182</td></tr>
						<tr><td>Siemen</td><td>418</td></tr>
					</tbody>
				</table>
		
			will automatically create a paginated table, without any further actions. The pagination
			buttons will only appear if there is more than 1 page.
		
			
			Serverside tables:
			
			When you have a table with lots of rows, creating the HTML table can take a while. You can also 
			create a table where the data for each page will be fetched from the server. This can be done using
			  
				<table id='samples' class="paginate serverside" rel="/url/to/ajaxData">
					<thead>
						<tr><th>Name</th><th># samples</th></tr>
					</thead>
				</table>
			
			Where the /url/to/ajaxData is a method that returns the proper data for this table. See 
			http://www.datatables.net/examples/data_sources/server_side.html for more information about this method.		 
				
		*/ %>
		<script type="text/javascript" src="${resource(dir: 'js', file: 'paginate.js', plugin: 'dbxpModuleBase')}"></script>
		<link rel="stylesheet" href="${resource(dir: 'css', file: 'buttons.css', plugin: 'dbxpModuleBase')}"/>
		
		<g:layoutHead/>
	
	</head>
	<body>
		<div id="header">
			<div id="logo">${ConfigurationHolder.config.module.name}</div>
		    <ul class="topnav">
				<% /* Include topnav as specified by the page */ %>
				<g:pageProperty name="page.topnav" />
				<li class="user_info">
					<g:if test="${session?.user}">
						Hello ${session?.user?.username}&nbsp;&nbsp;|&nbsp;
			        	<g:link controller="logout" action="index">sign out</g:link>
			        </g:if>
			        <g:else>
			        	Hello Guest&nbsp;&nbsp;|&nbsp;
			        	<g:link controller="login" action="index">sign in</g:link>
			        </g:else>
				</li>	
			</ul>				
			<br clear="all" />
		</div>
		<div class="container">
			<div id="content">
				<g:if test="${flash.message}">
					<p class="message">${flash.message.toString()}</p>
				</g:if>
				<g:if test="${flash.error}">
					<p class="error">${flash.error.toString()}</p>
				</g:if>
				
				<g:layoutBody/>
			</div>

			<div id="footer">
				Copyright &copy; 2010 - <g:formatDate format="yyyy" date="${new Date()}"/>. All rights reserved.
			</div>
		</div>
	</body>
</html>
