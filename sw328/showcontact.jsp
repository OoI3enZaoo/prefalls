<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.text.DecimalFormat" %>
<%@page import="java.util.*" %>
<%@include file="../config.jsp"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
dbm.createConnection();
String result = "";
try {
		String sql = "SELECT * FROM sw328contact";
		ResultSet rs= dbm.executeQuery(sql);
		result = "[";
		while(rs.next())
        {
			result = result + "{";
			result = result + "\"id\": \"" + rs.getString("contactID") + "\", ";
            result = result + "\"name\": \"" + rs.getString("name") + "\", ";
			result = result + "\"company\": \"" + rs.getString("company") + "\", ";
			result = result + "\"email\": \"" + rs.getString("email") + "\"}, ";
            String clientOrigin = request.getHeader("origin");
            response.setHeader("Access-Control-Allow-Origin", clientOrigin);
            response.setHeader("Access-Control-Allow-Methods", "POST");
            response.setHeader("Access-Control-Allow-Headers", "Content-Type");
            response.setHeader("Access-Control-Max-Age", "86400");
        }
		result = result.substring(0, result.length() - 2) + "]";
        out.print(result);
}catch(Exception ex){
out.println("Unable to connect to database "+ex);
}
dbm.closeConnection();
%>