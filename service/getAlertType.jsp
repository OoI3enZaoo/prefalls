<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	//request.setCharacterEncoding("UTF-8");
	
		dbm.createConnection();
		try {
			

			String sql = "SELECT * FROM alerttypename";
										
			ResultSet rs = dbm.executeQuery(sql);

			String output = "[";			
			boolean c = true;
			while((rs!=null) && (rs.next())) {
				String type = rs.getString("alert_type");
				String name = rs.getString("alert_name");
				if(c){
					output += "{\"alert_type\":\""+type+"\",\"alert_name\":\""+name+"\"}";	
					c = false;
				} else {
					output += ",{\"alert_type\":\""+type+"\",\"alert_name\":\""+name+"\"}";	
				}								
			}
			
			output += "]";
			out.print(output);			
		
		} catch (Exception e) {System.out.println("Exception e: "+e);}	
		dbm.closeConnection();

	
%>