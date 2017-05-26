<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	request.setCharacterEncoding("UTF-8");

	
	String UserID = request.getParameter("UID");
	
		dbm.createConnection();
		try {
			

			String sql = "SELECT  id,SSSN,firstname,lastname,imgPath,DATE_FORMAT(`start`,'%m/%d/%Y %T') as start,DATE_FORMAT(now(),'%m/%d/%Y %T') as thisTime,alt.alert_type as altype,(select alert_name FROM alerttypename WHERE alert_type = altype) as alert_name "
										+" FROM alerts alt "
										+" NATURAL JOIN supervise s "
										+" NATURAL JOIN patients p "
										+" where id in (SELECT max(id) FROM alerts GROUP BY SSSN) and s.UID =  '"+UserID+"' ";
										
			ResultSet rs = dbm.executeQuery(sql);
			String output = "[";
			boolean c = true;
			while((rs!=null) && (rs.next())) {				
				String SSSN = rs.getString("SSSN");
				String firstname = rs.getString("firstname");
				String lastname = rs.getString("lastname");
				String imgPath = rs.getString("imgPath");
				String alert_name = rs.getString("alert_name");							   
				if(c){
					output += "{\"SSSN\":\""+SSSN+"\",\"firstname\":\""+firstname+"\",\"lastname\":\""+lastname+"\",\"imgPath\":\""+imgPath+"\",\"alert_name\":\""+alert_name+"\"}";	
					c = false;
				} else {
					output += ",{\"SSSN\":\""+SSSN+"\",\"firstname\":\""+firstname+"\",\"lastname\":\""+lastname+"\",\"imgPath\":\""+imgPath+"\",\"alert_name\":\""+alert_name+"\"}";
				}
			}
			output += "]";
			out.println(output);
			
		
		} catch (SQLException e) {System.out.println("Exception e: "+e);}	
		dbm.closeConnection();

	
%>