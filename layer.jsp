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
/*
Layer Payment SDK for JSP 
*/
	Random rand = new Random();
	int int1 = rand.nextInt(500);
	sample_data.put("mtx",String.valueOf(int1)); //txn id
	
	String errorstring="";
	String hash = "";		
	JSONObject layer_payment_token_data=null;
	JSONObject payment_token_data=null;
	try 
	{
		Layer layer = new Layer();
		String resp = layer.create_payment_token(sample_data,accesskey,secretkey,environment);
		
		if(resp=="" || resp == "{}")
			errorstring = "E55 Payment error. Token data empty.";
		else
			layer_payment_token_data = new JSONObject(resp);
		if(errorstring == "" && layer_payment_token_data.has("error"))
			errorstring = "E55 Payment error. "+layer_payment_token_data.getString("error");
		if(errorstring == "" && layer_payment_token_data.has("id")==false) 
			errorstring="Payment error. Layer token ID cannot be empty.";
		
		if(errorstring!=""){
			out.println(errorstring);
			return;
		}
		
		resp = layer.get_payment_token(layer_payment_token_data.getString("id"),accesskey,secretkey,environment);
		if(resp=="" || resp == "{}")
			errorstring = "E56 Payment error. Token data empty.";
		else
			payment_token_data = new JSONObject(resp);
		if(errorstring == "" && payment_token_data.has("error"))
			errorstring = "E56 Payment error. "+payment_token_data.getString("error");
		if(errorstring == "" && payment_token_data.has("id")==false) 
			errorstring="Payment error. Layer token ID cannot be empty.";
		if(errorstring == "" && payment_token_data.has("status") && payment_token_data.getString("status")=="paid") 
			errorstring="Layer: this order has already been paid.";
		if(errorstring == "" && !payment_token_data.getString("amount").equals(sample_data.getString("amount"))) 
			errorstring="Layer: an amount mismatch occurred.";
		if(errorstring!=""){
			out.println(errorstring);
			return;
		}
		
		JSONObject genhash = new JSONObject();
		genhash.put("amount",payment_token_data.getString("amount"));
		genhash.put("id",payment_token_data.getString("id"));
		genhash.put("mtx",sample_data.getString("mtx"));
		hash = layer.create_hash(genhash,accesskey,secretkey);					
	}
	catch(Exception e) {
		e.printStackTrace();		
	}	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>Layer Payment JSP Kit</title>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" >
	<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
	<script id="open_money_layer" src="<%= remote_script %>"></script>	
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
	<div class="dv">
		<label>Transaction ID:</label><%= sample_data.getString("mtx")  %>
	</div>
	<div class="dv">
		<label>Full Name:</label><%= sample_data.getString("name")  %>
	</div>
	<div class="dv">
		<label>E-mail:</label><%= sample_data.getString("email_id")  %>
	</div>
	<div class="dv">
		<label>Mobile Number: </label><%= sample_data.getString("contact_number")  %>
	</div>
	<div class="dv">
		<label>Amount:</label><%= sample_data.getString("currency")  %>&nbsp;<%= sample_data.getString("amount")  %>
	</div>		
	<div class="dv">
		<input id="submit" name="submit" value="Pay" type="button" onclick="triggerLayer();">
	</div>	
	
	<form action="response.jsp" method="post" style="display: none" name="layer_payment_int_form">
		<input type="hidden" name="layer_pay_token_id" value="<%= payment_token_data.getString("id") %>">
		<input type="hidden" name="tranid" value="<%= sample_data.getString("mtx") %>">
		<input type="hidden" name="layer_order_amount" value="<%= payment_token_data.getString("amount") %>">
		<input type="hidden" id="layer_payment_id" name="layer_payment_id" value="">
		<input type="hidden" id="fallback_url" name="fallback_url" value="">
		<input type="hidden" name="hash" value="<%= hash %>">
	</form>
	<script type="text/javascript">
		var layer_params = {payment_token_id:'<%= payment_token_data.getString("id") %>',accesskey:'<%= accesskey %>'};
	</script>
	<script type="text/javascript" src="layer_checkout.js"></script>
</div>
</body>
</html>