<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" media="screen" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
<link href="https://eonasdan.github.io/bootstrap-datetimepicker/css/prettify-1.0.css" rel="stylesheet">
<link href="https://eonasdan.github.io/bootstrap-datetimepicker/css/base.css" rel="stylesheet">
<link href="https://cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/build/css/bootstrap-datetimepicker.css" rel="stylesheet">

<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.9.0/moment-with-locales.js"></script>
<script src="https://cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/src/js/bootstrap-datetimepicker.js"></script>

</head>
<body>
    <div>
        <%
        dbm.createConnection();
        String data = "";
        String startTime=request.getParameter("startTime");
        String endTime=request.getParameter("endTime");
        String Type=request.getParameter("Type");
        String Lavel=request.getParameter("Lavel");
        try {

            String sql = "SELECT * FROM `alerts` WHERE `datetimeEvent` BETWEEN '"+startTime+"' AND '"+endTime+"'";
            ResultSet rs = dbm.executeQuery(sql);
        %>
        <table class="table table-hover">
        <%
            ResultSetMetaData resMetaData = rs.getMetaData();
            int nCols = resMetaData.getColumnCount();
        %>
        <tr>
        <%
            for (int kCol = 1; kCol <= nCols; kCol++) {
                out.print("<td class=\"success\"><b>" + resMetaData.getColumnName(kCol) + "</b></td>");
            }
        %></tr>
        <% 
                while (rs.next()){ 
        %>
        <tr>
        <%
                    for (int kCol = 1; kCol <= nCols; kCol++) {
                        out.print("<td>" + rs.getString(kCol) + "</td>");
                    }
        %>
        </tr>
        <%
                }
        %>
        </table>
        <%
        }catch(Exception ex){
        out.println("Unable to connect to database"+ex);
        }
        dbm.closeConnection();
        %>
    </div>
</body>
</html>
