<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
	
<%
    if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
   
	String minHR = request.getParameter("minHR");
	String maxHR = request.getParameter("maxHR");
    String maxS = request.getParameter("maxS");
	String sssn = (String)session.getAttribute("SSSN");

	dbm.createConnection();
		
	try {
   
        String sql ="UPDATE `mobilise`.`patients` SET `minHeartRate` = '"+minHR+"', `maxHeartRate` = '"+maxHR+"',`maxStationary` = '"+maxS+"' WHERE `patients`.`SSSN` = '"+sssn+"'";
			
		dbm.executeUpdate(sql);
			
		response.sendRedirect("../setting/");
				  
	} catch (Exception e) {
		out.println(e.getMessage());
		e.printStackTrace();
	}
		
	dbm.closeConnection();

%>