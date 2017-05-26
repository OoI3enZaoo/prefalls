<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	request.setCharacterEncoding("UTF-8");
	dbm.createConnection();
	try {
	
		String sssn = request.getParameter("sssn");
		
		String sql = "SELECT * FROM `comment_"+sssn+"` WHERE date=(SELECT MAX(date) FROM `comment_"+sssn+"`)";
		ResultSet rs = dbm.executeQuery(sql);
		
		String output ="";	
		if(!rs.next())
		{
			output += "-";

		} else {
			output += rs.getString("comment");
		}

		out.print(output);
		
	} catch (SQLException e) {System.out.println("Exception e: "+e);}	
	dbm.closeConnection();
%>