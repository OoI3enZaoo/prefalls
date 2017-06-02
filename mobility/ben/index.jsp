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
	
    int test_senverity = 12;
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
	<script>
		$(document).ready(function() {
			$('#example').DataTable( {
				"order": [[ 0, "desc" ]]
			} );
		} );

	</script>
	
	
	 <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFdI5SnLF-CIQ5lRKo_lEqaR6yPN4g7sk&callback=initMap">
    </script>
	
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
  		    <th>Location</th>
            <th>Notification Type</th>
            <th>Detail</th>
  		</tr>
  	</thead>
  	<tbody>
<%
        dbm.createConnection();
        try {

            String sql = "SELECT DATE_FORMAT(alerts.start,'%Y-%m-%d %H:%i:%s') as date , alerts.lat ,alerts.lon , alerts.alert_type, alerttypename.alert_name FROM `alerts`, `alerttypename` WHERE alerts.SSSN = '"+sssn+"' AND alerts.alert_type = alerttypename.alert_type ORDER BY alerts.id";

			ResultSet rs = dbm.executeQuery(sql);
            
            int count=0;
            while((rs!=null) && (rs.next())){
			Double lat = Double.parseDouble(rs.getString("lat"));
			Double lon = Double.parseDouble(rs.getString("lon"));
            %>
			
			<script>

	function getLocation(lat ,lon){
	var location_test = "";	
	$.getJSON("http://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lon+"&sensor=false", function(result){
       location_test = result.results[0].formatted_address;
	   console.log(lat , lon);
		console.log(""+location_test);
		$("#div<%=count%>").text(result.results[0].formatted_address);
    });

	}
	</script>
			
           <tr style="cursor: pointer;">
                <td id=<%=count%>><%= rs.getString("date")%></td>
                <td ><div id="div<%=count%>"></div></td>
                <td><%=rs.getString("alert_name")%></td>
				
				<td>
				<% if (rs.getString("alert_type").equals("7")){%>
						<center><img src="../images/icons/alert/fall.png" width="20px" height="20px"></center>
				<%}%>
				
				<% if (rs.getString("alert_type").equals("3")){%>
						<center><img src="../images/icons/alert/warning_a.png" width="20px" height="20px"></center>
				<%}%>
			
				<% if (rs.getString("alert_type").equals("4")){%>
						<center><img src="../images/icons/alert/warning_a.png" width="20px" height="20px"></center>
				<%}%>
				</td>
           
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