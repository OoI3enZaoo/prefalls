<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
	
	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}
   
    String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String sssn = (String)session.getAttribute("SSSN");
    String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + session.getAttribute("fname") + " " + (String)session.getAttribute("lname") + " ";
	
%>

<!doctype html>
<head>
<title>mobilise</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<!-- CSS Main File-->
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<!--CSS and JS dataTables File -->
<link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap.min.css"/>
<script type="text/javascript" src="js/jquery-1.12.0.min.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="js/dataTables.bootstrap.min.js"></script>

</head>
<body>

<%@include file="../include/nav.jsp"%>
    
<div class="container">
    <div class="panel"><font class="fs17">Notifications<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel">
  <table id="example" class="table table-striped table-bordered" cellspacing="0" width="100%">
  	<thead>
  		<tr class="success">
  		    <th>Date</th>
  		    <th>Notification types</th>
  		    <th>Severity</th>
  		</tr>
  	</thead>
  	<tbody>

    <%
        dbm.createConnection();
        try {

            String sql = "SELECT a.start,b.alert_name,b.severity FROM alerts a LEFT JOIN alerttypename b ON a.alert_type=b.alert_type where SSSN = '"+sssn+"' GROUP BY a.start ORDER BY a.start";
            ResultSet rs = dbm.executeQuery(sql);
            
             
            while((rs!=null) && (rs.next())){%>
            <tr>
                <td><%= rs.getString("start")%></td>
                <td><%= rs.getString("alert_name")%></td>
                <td><% if(rs.getInt("severity")==3){
                        out.print("High");
                        }else if (rs.getInt("severity")==2){
                        out.print("Moderate");
                    }else{
                        out.print("Nomal");
                }
                        %>
                </td>
            </tr>        
            <%}
        } catch (Exception e) {
                out.print(e);
        }
            
        dbm.closeConnection();
    %>

  	</tbody>
  </table>
        </div>
</div>
<script type="text/javascript">

	$(document).ready(function() {
	    $('#example').DataTable();
	} );

</script>
<!-- JS Main File -->
<script src="../js/bootstrap.min.js"></script>
</body>
</html>