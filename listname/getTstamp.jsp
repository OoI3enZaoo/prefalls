
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />


<%
String sssn = request.getParameter("sssn");
String tstamp = "";


dbm.createConnection();
try {
  String sql = "SELECT tstamp FROM archive_"+sssn+" ORDER BY tstamp  DESC limit 1";
  ResultSet rs = dbm.executeQuery(sql);
      while(rs.next()){
          tstamp = rs.getString("tstamp");
        }
        String jsonStr = "[";
        jsonStr += "{\"tstamp\":\""+tstamp+"\"}";
          jsonStr += "]";
          out.print(jsonStr);

}catch (Exception e) {
    out.println(e.getMessage());
    e.printStackTrace();
}

dbm.closeConnection();


%>
