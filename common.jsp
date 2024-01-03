<%

String accesskey="";
String secretkey="";
String environment="test";
String remote_script="https://sandbox-payments.open.money/layer/js";

JSONObject sample_data = new JSONObject();
sample_data.put("amount","12.00");
sample_data.put("currency", "INR");
sample_data.put("name", "John Doe");
sample_data.put("email_id", "john.doe@dummydomain.com");
sample_data.put("contact_number","9831111111");
	

//Layer functions
class Layer {
	final String BASE_URL_SANDBOX = "https://sandbox-icp-api.bankopen.co/api";
	final String BASE_URL_UAT = "https://icp-api.bankopen.co/api";
	
	public String create_payment_token(JSONObject data,String accesskey,String secretkey,String environment){
		String response="";
		try {
			Iterator<String> iterator = data.keys();
			while (iterator.hasNext()) {
				String key = iterator.next();
				Object o = data.get(key);
				if (o == null || o == JSONObject.NULL) iterator.remove();
			}
			response = http_post(data,"payment_token",accesskey,secretkey,environment);			
		} catch (Exception e){			
			e.printStackTrace();
		} 
		return response;
	}

	public String get_payment_token(String payment_token_id,String accesskey,String secretkey,String environment){
		String response="";
		try {
			if(payment_token_id==null || payment_token_id.isEmpty()){
				response="{\"error\":\"payment_token_id cannot be empty\"}";				
			}
			response = http_get("payment_token/" + payment_token_id,accesskey,secretkey,environment);
		} catch (Exception e){
			e.printStackTrace();
		} 
		return response;
	}

	public String get_payment_details(String payment_id,String accesskey,String secretkey,String environment){
		String response="";
		try {
			JSONObject err = new JSONObject();
			if(payment_id==null || payment_id.isEmpty()){
				err.put ("error","payment_id cannot be empty");
				return err.toString();
			}
		
			return http_get("payment/"+payment_id,accesskey,secretkey,environment);
		} catch (JSONException e){
			e.printStackTrace();
		} 
		return response;
	}

	private String http_post(JSONObject data,String route,String accesskey,String secretkey,String environment){
		StringBuffer response = new StringBuffer();		
		OutputStreamWriter out = null;
		URL obj = null;
		HttpURLConnection 
		httpCon = null;
		BufferedReader in=null;
		BufferedReader er=null;
		try {		
			String url = BASE_URL_SANDBOX + "/" + route;
	
			if(environment == "live") url = BASE_URL_UAT + "/" + route;
		  
			obj = new URL(url);
			httpCon = (HttpURLConnection) obj.openConnection();
			httpCon.setDoOutput(true);
			httpCon.setRequestMethod("POST");
			httpCon.setRequestProperty("Authorization","Bearer "+accesskey+":"+secretkey);
			httpCon.setRequestProperty("Content-Type", "application/json");			
			
			out = new OutputStreamWriter(httpCon.getOutputStream());
			out.write(data.toString());
			out.flush();
			in = new BufferedReader(new InputStreamReader(httpCon.getInputStream()));
			String inputLine;
			while ((inputLine = in.readLine()) != null) 
				response.append(inputLine);
			
			if(response.toString() == null || response.toString() == ""){
				er = new BufferedReader(new InputStreamReader(httpCon.getErrorStream()));
				String errorLine;
				while ((errorLine = er.readLine()) != null) 
					response.append(errorLine);
			}
			out.close();
			in.close();
			er.close();
			httpCon.disconnect(); 
		} catch(Exception e)
		{
			e.printStackTrace();		
		}		
		
		return response.toString();
	}

	private String http_get(String route,String accesskey,String secretkey,String environment){
		StringBuffer response = new StringBuffer();
		OutputStreamWriter out = null;
		URL obj = null;
		HttpURLConnection 
		httpCon = null;
		BufferedReader in=null;
		BufferedReader er=null;
		try {		
			String url = BASE_URL_SANDBOX + "/" + route;
	
			if(environment == "live") url = BASE_URL_UAT + "/" + route;
		 
			obj = new URL(url);
			httpCon = (HttpURLConnection) obj.openConnection();
			httpCon.setDoOutput(true);
			httpCon.setRequestMethod("GET");
			httpCon.setRequestProperty("Content-Type", "application/json");			
			httpCon.setRequestProperty("Authorization","Bearer "+accesskey+":"+secretkey);
			
			in = new BufferedReader(new InputStreamReader(httpCon.getInputStream()));
			String inputLine;
			while ((inputLine = in.readLine()) != null) 
				response.append(inputLine);
			if(response.toString() == null || response.toString() == ""){
				er = new BufferedReader(new InputStreamReader(httpCon.getErrorStream()));
				String errorLine;
				while ((errorLine = er.readLine()) != null) 
					response.append(errorLine);
			}
			out.close();
			in.close();
			er.close();
			httpCon.disconnect(); 			
		} catch(Exception e)
		{
			e.printStackTrace();		
		}
		
		return response.toString();
	}

	public String create_hash(JSONObject data,String accesskey,String secretkey){
		byte[] hash=null;
		try {
			String pipeSeperatedString=accesskey+"|"+data.getString("amount")+"|"+data.getString("id")+"|"+data.getString("mtx");
			Mac mac = Mac.getInstance("HmacSHA256");
			SecretKeySpec secretKeySpec = new SecretKeySpec(secretkey.getBytes(), "HmacSHA256");
			mac.init(secretKeySpec);
			hash = mac.doFinal(pipeSeperatedString.getBytes());
		} 
		catch (JSONException e) {
			e.printStackTrace();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return Base64.getEncoder().encodeToString(hash);		
	}

	public Boolean verify_hash(JSONObject data,String rec_hash,String accesskey,String secretkey){
		String gen_hash = create_hash(data,accesskey,secretkey);
		if(gen_hash.equals(rec_hash)){
			return true;
		}
		return false;
	}

}

%>