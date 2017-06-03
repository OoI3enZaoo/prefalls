
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	String testdata = "";


dbm.createConnection();
try {

   String sql2 = "SELECT sssn, firstname , lastname  FROM patients";
   ResultSet rs = dbm.executeQuery(sql2);

  if(rs.next()){
  testdata = rs.getString("step");

  }

} catch (Exception e) {
  out.println(e.getMessage());
  e.printStackTrace();
}

dbm.closeConnection();

out.println("testdata: " + testdata);
%>
