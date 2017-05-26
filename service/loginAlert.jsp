<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	request.setCharacterEncoding("UTF-8");
	dbm.createConnection();
	try {
	
		String strUsername = request.getParameter("user");
		String strPassword = request.getParameter("pass"); 
		
		String sql = "SELECT * FROM caregiver WHERE email = '" + strUsername + "' AND " + " password = '" + strPassword + "'";
		ResultSet rs = dbm.executeQuery(sql);
		
		String output = "{";	
		if(!rs.next())
		{
			output += "\"status\":false";

		} else {
			output += "\"status\":true";
			output += ",\"UID\":\""+rs.getString("UID")+"\"";
		}
		output += "}";
		out.print(output);
		
	} catch (SQLException e) {System.out.println("Exception e: "+e);}	
	dbm.closeConnection();
%>