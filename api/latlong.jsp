<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<% 
Vector<String> lat = new Vector<String>();
Vector<String> lng = new Vector<String>();
Vector<String> tstamp = new Vector<String>();

String pid = request.getParameter("pid");

dbm.createConnection();

try {

	String sql = "SELECT lat,lon ,tstamp FROM `archive_"+pid+"` where lat not like '0' ORDER BY tstamp DESC limit 1";

		ResultSet rs = dbm.executeQuery(sql);
	
    
	   while (rs.next()) {	
    
        lat.addElement(rs.getString("lat"));
		lng.addElement(rs.getString("lon"));
		tstamp.addElement(rs.getString("tstamp"));
        
	
	  }
		
			
			
}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();

String jsonStr = "[";
for(int i=0; i<lat.size(); i++){
	jsonStr += "{\"lat\":\""+ lat.elementAt(i) +"\",";
	jsonStr += "\"lng\":\""+ lng.elementAt(i) +"\",";
	jsonStr += "\"tstamp\":\""+ tstamp.elementAt(i) +"\"}";

 

		if((i+1) != lat.size()){
		jsonStr += ",";
	}
}
		jsonStr += "]";


		out.print(jsonStr);


%>