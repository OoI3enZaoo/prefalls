<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Locale"%>
<%@ page import="java.sql.*" %>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%	
	String sssn = (String)session.getAttribute("SSSN");
	String comment = request.getParameter("comment");

	Date dNow = new Date();
   	SimpleDateFormat ft = new SimpleDateFormat ("yyyy.MM.dd HH:mm:ss");
   	String date = ft.format(dNow);

dbm.createConnection();
		
		try {

			String sql = "INSERT INTO `comment_"+sssn+"`(`date`, `comment`) VALUES ('"+date+"','"+comment+"')";
			dbm.executeUpdate(sql);
			out.print(sql);
			
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
dbm.closeConnection();

response.sendRedirect("./");
%>