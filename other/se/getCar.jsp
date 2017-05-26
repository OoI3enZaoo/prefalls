<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	request.setCharacterEncoding("UTF-8");
	dbm.createConnection();
	try {
	
		String id = request.getParameter("id");
		
		String sql = "SELECT id,carid , DATE_FORMAT(time_in,'%H:%i') as time FROM se WHERE status = 1;";
		ResultSet rs = dbm.executeQuery(sql);
		
		String output = "{";	
		output += "\"carin\":[";
		int i = 0;
		while(rs.next()){
			if(i==0){
				output += "{";
				output += "\"carid\":\""+rs.getString("carid")+"\"";
				output += ",\"id\":\""+rs.getString("id")+"\"";
				output += ",\"time\":\""+rs.getString("time")+"\"";
				output += "}";
				i++;
			} else {
				output += ",{";
				output += "\"carid\":\""+rs.getString("carid")+"\"";
				output += ",\"id\":\""+rs.getString("id")+"\"";
				output += ",\"time\":\""+rs.getString("time")+"\"";
				output += "}";
			}		
		}
		output += "]";
		
		sql = "SELECT COUNT(*) as free FROM `se` WHERE status = 0";
		rs = dbm.executeQuery(sql);			
		if(rs.next())
		{ 
			String free = rs.getString("free");
			output += ",\"free\":\""+free+"\"";
		}
		
		output += "}";
		out.print(output);
		
	} catch (SQLException e) {System.out.println("Exception e: "+e);}	
	dbm.closeConnection();
%>