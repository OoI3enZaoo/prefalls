<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../");
	}

	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String sssn = (String)session.getAttribute("SSSN");

	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}

	dbm.createConnection();
   
    String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + session.getAttribute("fname") + " " + (String)session.getAttribute("lname") + " ";
    String event = "";
	String icons = "";
    String dateMobility = "";
    String sec = "";
    String datealert = "";
    String strtype = "";
    int type = 0;
	
	try {

		String sql = "SELECT count(*) * 3 as sec,DATE_FORMAT(tstamp,'%Y-%m-%d') as date FROM `archive_"+sssn+"` WHERE tstamp < CURRENT_TIMESTAMP and `ismobile` = true group by DATE_FORMAT(tstamp,'%Y-%m-%d')";
		ResultSet rs = dbm.executeQuery(sql);
		try {
			String sqlal = "SELECT DATE_FORMAT(start,'%Y-%m-%d') AS Date,`alert_type` FROM `alerts`  WHERE SSSN=\""+sssn+"\" GROUP BY `alert_type`,`Date`";
            ResultSet al = dbm.executeQuery(sqlal);
            while(al.next()){
            datealert = al.getString("Date");
            strtype = al.getString("alert_type");
            int count = 0;
            type = Integer.parseInt(strtype);
	            if(type == 2 ){
	            	icons +="if(event.id == '"+datealert+"'){"+
							"if(event.allDay){"+
							"$(element).find('span:first').prepend('<img src=\"../images/icons/turn.png\" style= \"width:25px;\">"+
							"');"+
						"}else{"+
							"$(element).find('.fc-time').prepend('<img src=\"../images/icons/turn.png\" style= \"width:25px;\">"+
							"');"+
							"}"+
						"}";
				 }
				 if (type == 5){
				 	icons +="if(event.id == '"+datealert+"'){"+
							"if(event.allDay){"+
							"$(element).find('span:first').prepend('<img src=\"../images/icons/HRdown.png\" style= \"width:25px;\">"+
							"');"+
						"}else{"+
							"$(element).find('.fc-time').prepend('<img src=\"../images/icons/HRdown.png\" style= \"width:25px;\">"+
							"');"+
							"}"+
						"}";	
				}
				if (type == 6){
				 	icons +="if(event.id == '"+datealert+"'){"+
							"if(event.allDay){"+
							"$(element).find('span:first').prepend('<img src=\"../images/icons/HRup.png\" style= \"width:25px;\">"+
							"');"+
						"}else{"+
							"$(element).find('.fc-time').prepend('<img src=\"../images/icons/HRup.png\" style= \"width:25px;\">"+
							"');"+
							"}"+
						"}";	
				}
			 }
		} catch (Exception e) {
		out.print(e);
		}	 
		while(rs.next()){

			dateMobility = rs.getString("date");
			sec = rs.getString("sec");
            
            int mobility = Integer.valueOf(sec);
            mobility = 100*mobility/86400;
            //mobility=30000
            

          
			String progress ="";

			if (mobility <= 25){

				progress = "progress-bar progress-bar-danger";

			} 

			else if (mobility <= 50){

				progress = "progress-bar progress-bar-warning";

			}

			else if (mobility <= 100){

				progress = "progress-bar progress-bar-success";
			}

			event +="{" +
					"id:'"+dateMobility+"'," +
            		"start:'"+dateMobility+"'," +
                    "url:'show.jsp?date="+dateMobility+"'" +
            		//"url:'javascript:OpenInNewTab(\"show.jsp?date="+dateMobility+"\")'"+
        			"}," ;
        	icons +="if(event.id == '"+dateMobility+"'){"+
						"if(event.allDay){"+
						"$(element).find('span:first').prepend('<div class=\"progress\" style=background-color:#B2B1AC;>"+
  						"<div class=\""+progress+"\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" style= \"width:"+mobility+"%;\">"+
    					""+mobility+"%"+
  						"</div>"+
						"</div>"+
						"');"+
					"}else{"+
						"$(element).find('.fc-time').prepend('<div class=\"progress\">"+
  						"<div class=\""+progress+"\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" style= \"width:60%;\">"+
    					"60%"+
  						"</div>"+
						"</div>');"+
						"}"+
					"}";
		}

	} catch (Exception e) {
		out.print(e);
	}
		
	dbm.closeConnection();

%>

<!doctype html>
<head>
<title>mobilise</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<!-- CSS Main File -->
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<!-- CSS and JS FullCalendar File -->
<link href="../css/fullcalendar/fullcalendar.css" rel='stylesheet' />
<link href="../css/fullcalendar/fullcalendar.print.css" rel='stylesheet' media='print' />
<script src="../js/fullcalendar/moment.min.js"></script>
<script src="../js/fullcalendar/jquery.min.js"></script>
<script src="../js/fullcalendar/fullcalendar.min.js"></script>
<script src="../js/fullcalendar/gcal.js"></script>
<script>

	$(document).ready(function() {

		$('#calendar').fullCalendar({

			events:[

			<%=event%>

			],
			eventTextColor:'#000000',
    		eventColor:'#FFFFFF',
			eventRender: function(event, element, view) {

            <%=icons%>

    		},
			selectable: true,
			loading: function(bool) {
				$('#loading').toggle(bool);
			}
			
		});
    
	});

	function OpenInNewTab(url) {
		var win = window.open(url, '_blank');
		win.focus();
	}

</script>
<style>

#loading { display:none; position:absolute; top:10px;right: 10px; }
#calendar { max-width: 800px; margin: 0 auto; }

</style>
</head>
<body>

<%@include file="../include/nav.jsp"%>                
                
<div class="container">
    <div class="panel"><font class="fs17">History<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel">
        <div id='calendar'></div> 
    </div>
</div>
<!-- JS Main File -->
<script src="../js/bootstrap.min.js"></script>
</body>
</html>