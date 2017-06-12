<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<% 
Vector<String> alert_type = new Vector<String>();
Vector<String> alert_name = new Vector<String>();


dbm.createConnection();

try {

	String sql = "SELECT alert_type , alert_name FROM alerttypename";

		ResultSet rs = dbm.executeQuery(sql);
	
    
	   while (rs.next()) {	
   
        alert_type.addElement(rs.getString("alert_type"));
		alert_name.addElement(rs.getString("alert_name"));

        
	
	  }
		
			
			
}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();

String jsonStr = "[";
for(int i=0; i<alert_type.size(); i++){
	jsonStr += "{\"alertType\":\""+ alert_type.elementAt(i) +"\",";
	jsonStr += "\"alertName\":\""+ alert_name.elementAt(i) +"\"}";

 

		if((i+1) != alert_type.size()){
		jsonStr += ",";
	}
}
		jsonStr += "]";


		out.print(jsonStr);


%>