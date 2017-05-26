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
	
	try {

		String sql = "SELECT DATE(A.START) AS TSTAMP1, ALERT_TYPE, B.SISMOBILE FROM alerts A, (SELECT DATE(TSTAMP) AS TSTAMP2, count(*) * 3 AS SISMOBILE FROM archive_"+sssn+" GROUP BY DATE(TSTAMP)) B WHERE (SSSN = \""+sssn+"\") AND (DATE(A.START) = TSTAMP2) ";
		ResultSet rs = dbm.executeQuery(sql);
			 
		while((rs!=null) && (rs.next())){	
            
			dateMobility = rs.getString("TSTAMP1");
			sec = rs.getString("SISMOBILE");
            String strtype = rs.getString("ALERT_TYPE");
            int type = Integer.parseInt(strtype);;
            int mobility = Integer.valueOf(sec);
            mobility = 100*mobility/86400;
            //mobility=30000
            out.print(dateMobility);
			String progress ="";

			if (mobility <= 25){

				progress = "progress-bar progress-bar-danger";

			} 

			else if (mobility <= 50){

				progress = "progress-bar progress-bar-warning";

			}

			else {

				progress = "progress-bar progress-bar-success";
			}


			String srcImg ="";

			if (type == 1){
				srcImg = "";
			}else if(type == 2) {
				srcImg = "<img src=\"../images/icons/turn.png\" style= \"width:25px;\">";
			}else if(type == 3) {
				srcImg = "<img src=\"../images/icons/turn.png\" style= \"width:25px;\">";
			}else if(type == 4) {
				srcImg = "";
			}else{
				srcImg = "<img src=\"../images/icons/hr.png\" style= \"width:25px;\">";
			}

			event +="{" +
					"id:'"+dateMobility+"'," +
            		"start:'"+dateMobility+"'," +
                    "url:'show.jsp?date="+dateMobility+"'" +
            		//"url:'javascript:OpenInNewTab(\"show.jsp?date="+dateMobility+"\")'"+
        			"}," ;
        	icons +="if(event.id == '"+dateMobility+"'){"+
						"if(event.allDay){"+
						"$(element).find('span:first').prepend('<div class=\"progress\">"+
  						"<div class=\""+progress+"\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" style= \"width:"+mobility+"%;\">"+
    					""+mobility+"%"+
  						"</div>"+
						"</div>"+
                        ""+srcImg+"');"+
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
<nav class="navbar navbar-default navbar-static-top">
   <div class="container-fluid">
      <div class="navbar-header">
         <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>  
         </button>
         <a class="header-brand" href="../listname/"><img src="../images/logo.png"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav">
            <li><a href="../activity.jsp">กิจกรรมประจำวัน</a></li>
            <li class="active"><a href="../history/">ประวัติกิจกรรม</a></li>
            <li><a href="../notifications/">บันทึกการแจ้งเตือน</a></li>
            <li><a href="../mobility.jsp">บันทึกผลการทดสอบ</a></li>
            <li><a href="../profile/">ข้อมูลส่วนตัว</a></li>
            <li class="end"><a href="../setting/">ตั้งค่า</a></li>
         </ul>
         <ul class="nav navbar-nav navbar-right">
            <li><a><%=ssfn%></a></li>
            <li><a href="../logout.jsp">ออกจากระบบ</a></li>
         </ul>
      </div>
   </div>
</nav>
<div class="container">
    <div class="panel"><font class="fs17">ประวัติกิจกรรม<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel">
        <div id='calendar'></div>
    </div>
</div>
<!-- JS Main File -->
<script src="../js/bootstrap.min.js"></script>
</body>
</html>