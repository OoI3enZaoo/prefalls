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
    <div class="panel"><font class="fs17">Assessment Log<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel">
    <table id="example" class="table table-striped table-bordered" cellspacing="0" width="100%">
  	<thead>
  		<tr class="success">
  		    <th>Date</th>
  		    <th>Assessment type</th>
            <th>Assessment result</th>
  		</tr>
  	</thead>
  	<tbody>
    <%
        dbm.createConnection();
        try {

            String sql = "SELECT DATE_FORMAT(MobilityTest.start,'%Y-%m-%d %H:%i:%s') as date , MobilityTest.time_total , testtype.type_name FROM `MobilityTest`, `testtype` WHERE MobilityTest.type_id = testtype.type_id AND MobilityTest.SSSN = '"+sssn+"'";
            ResultSet rs = dbm.executeQuery(sql);
            
            int count=0;
            while((rs!=null) && (rs.next())){
            String result = "";
            if(rs.getDouble("time_total")>=20.5){
               result = "High fall risk ";
                
            } else if(rs.getDouble("time_total")>=13.5){
                result = "Fall risk";
            } else {
                result = "Normal";
            }
            %>
            <tr onclick=myFunction(<%=count%>) style="cursor: pointer;">
                <td id=<%=count%>><%= rs.getString("date")%></td>
                <td><%= rs.getString("type_name")%></td>
                <td><%=result%></td>
            </tr>     
            <% count++;}
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
    function myFunction(id) {
        var date = document.getElementById(id).firstChild.nodeValue;
        var url = "http://sysnet.utcc.ac.th/mobilise/mobility/mobility.jsp?date=" + date ;
        window.location.assign(url);
    }
	$(document).ready(function() {
	    $('#example').DataTable();
	} );

</script>
<!-- JS Main File -->
<script src="../js/bootstrap.min.js"></script>
</body>
</html>