<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<% 
Vector<Integer> cnt =  new Vector<Integer>();
Vector<String> fname =  new Vector<String>();
Vector<String> lname =  new Vector<String>();
Vector<String> user_id =  new Vector<String>();
String user_email = request.getParameter("user_email");
String user_pwd = request.getParameter("user_pwd");

dbm.createConnection();

try {

String sql = "select count(*) as cnt , firstname,lastname from caregiver where email='"+user_email+"' and password='"+user_pwd+"'";
		ResultSet rs = dbm.executeQuery(sql);
	
    
	   while (rs.next()) {
        cnt.addElement(rs.getInt("cnt"));
		
        fname.addElement(rs.getString("firstname"));
        lname.addElement(rs.getString("lastname"));
        
	
	  }
		
			
			
}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();

String jsonStr = "[";
for(int i=0; i<cnt.size(); i++){
	jsonStr += "{\"cnt\":\""+cnt.elementAt(i)+"\",";
  jsonStr += "\"fname\":\""+fname.elementAt(i)+"\",";
	jsonStr += "\"lname\":\""+lname.elementAt(i)+"\"}";
  

		if((i+1) != cnt.size()){
		jsonStr += ",";
	}
}
		jsonStr += "]";


		out.print(jsonStr);


%>