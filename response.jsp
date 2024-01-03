<%@page import="java.io.*"%>
<%@page import="java.net.*"%>
<%@page import="java.util.*"%>
<%@ page import="java.security.*" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="ru.bpc.ISslContextProvider" %>
<%@ page import="ru.bpc.TrustAllConnectionsManager" %>
<%@ page import="javax.crypto.Mac" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ include file="common.jsp" %>

<%
	String layer_pay_token_id = request.getParameter("layer_pay_token_id");
	String tranid= request.getParameter("tranid");
	String layer_order_amount= request.getParameter("layer_order_amount");
	String layer_payment_id= request.getParameter("layer_payment_id");
	String fallback_url= request.getParameter("fallback_url");
	String rec_hash= request.getParameter("hash");
	String errorstring="";
	String status = "Transaction successful...";
	JSONObject payment_data=null;
	
	try{
		JSONObject genhash = new JSONObject();
		genhash.put("amount",layer_order_amount);
		genhash.put("id",layer_pay_token_id);
		genhash.put("mtx",tranid);
		
		Layer layer = new Layer();
		if(!layer.verify_hash(genhash,rec_hash,accesskey,secretkey))
			errorstring = "Invalid payment response...";
		if(errorstring=="")
		{
			String resp = layer.get_payment_details(layer_payment_id,accesskey,secretkey,environment);
			if(resp=="" || resp == "{}")
				errorstring = "Empty response received...";
			else
				payment_data = new JSONObject(resp);
		}
		if(errorstring=="")
		{
			JSONObject tokendata = payment_data.getJSONObject("payment_token");
			if(!tokendata.getString("id").equals(layer_pay_token_id))
				errorstring="Layer: received layer_pay_token_id and collected layer_pay_token_id doesnt match";
			if(Float.parseFloat(payment_data.getString("amount")) != Float.parseFloat(layer_order_amount))
				errorstring="Layer: received amount and collected amount doesnt match";
			if(!tokendata.getString("status").equals("paid"))
				status = "Transaction failed..."+payment_data.getString("payment_error_description");
		}
		
	}catch(Exception e) {
		e.printStackTrace();
	}
	
    
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Layer payment JSP Kit</title>
</head>
<style type="text/css">
	.main {
		margin-left:30px;
		font-family:Verdana, Geneva, sans-serif, serif;
	}
	.text {
		float:left;
		width:180px;
	}
	.dv {
		margin-bottom:5px;
	}
</style>
<body>
<div class="main">
	<div>
    	<img src="./images/logo.png" />
    </div>
	<br />
	<br />
	<% if(errorstring!="") { %>
    <div class="dv">
		<%= errorstring %>
    </div>
	<% } else { %>
	<div class="dv">
		<%= status %>
    </div>
	<% } %>
	<br />
	<br />
	<div class="dv">
    <span class="text"><a href="./layer.jsp" alt="New Order">New Transaction</a></span>    
    </div>	
</div>
</body>
</html>