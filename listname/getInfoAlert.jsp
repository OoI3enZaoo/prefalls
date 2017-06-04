
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />


<%
String sssn = request.getParameter("sssn");
String fname_alert = "";
String lname_alert = "";
String imgpath_alert = "";

dbm.createConnection();
try {
  String sql = "select firstname,lastname , imgPath from patients WHERE SSSN = '"+sssn+"'";
  ResultSet rs = dbm.executeQuery(sql);
      while(rs.next()){
          fname_alert = rs.getString("firstname");
          lname_alert = rs.getString("lastname");
          imgpath_alert = rs.getString("imgPath");
        }


        String jsonStr = "[";
        jsonStr += "{\"firstname\":\""+fname_alert+"\",";
         jsonStr += "\"lastname\":\""+lname_alert+"\",";
         jsonStr += "\"imgPath\":\""+imgpath_alert+"\"}";
          jsonStr += "]";

          out.print(jsonStr);

}catch (Exception e) {
    out.println(e.getMessage());
    e.printStackTrace();
}

dbm.closeConnection();


%>
