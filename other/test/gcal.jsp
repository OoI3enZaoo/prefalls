<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	dbm.createConnection();
		String dateMobility ="";
		String mobility = "";
		String event = "";
		String icons = "";
		String urls = "DetialHT.jsp";
		try {

			String sql = "SELECT * FROM `TestHistory`";
			ResultSet rs = dbm.executeQuery(sql);
			
			 
			while((rs!=null) && (rs.next())){	
				dateMobility = rs.getString("Date");
				mobility = rs.getString("Mobility");
				event +=  	"{" +
								"id:'"+dateMobility+"'," +
            					"start:'"+dateMobility+"'," +
            					"url:'http://sysnet.utcc.ac.th/mobilise/test/"+urls+"'" +
        					"},"  ;
        		icons += "if(event.id == '"+dateMobility+"'){"+
								"if(event.allDay){"+
									"$(element).find('span:first').prepend('<div class=\"progress\">"+
  									"<div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" style= \"width:60%;\">"+
    								"60%"+
  									"</div>"+
									"</div>');"+

								"}else{"+
								"$(element).find('.fc-time').prepend('<div class=\"progress\">"+
  									"<div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" style= \"width:60%;\">"+
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
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<link href="fullcalendar.css" rel='stylesheet' />
<link href="fullcalendar.print.css" rel='stylesheet' media='print' />
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous">	
</script>
<script src="moment.min.js"></script>
<script src="jquery.min.js"></script>
<script src="fullcalendar.min.js"></script>
<script src="gcal.js"></script>
<script>

	$(document).ready(function() {
	
		$('#calendar').fullCalendar({
			events:[
			<%=event%>
			],
			eventTextColor: '#000000',
    		eventColor:'#FFFFFF',
			eventRender: function(event, element, view) {
				<%=icons%>
				/*if(event.id == '2016-01-01'){
					//$(element).find('span:first').prepend('<img src="http://icons.iconarchive.com/icons/arrioch/halloween/256/radioactive-icon.png" />');
						if(event.allDay){
							$(element).find('span:first').prepend('<img src=/*"https://pbs.twimg.com/media/Bt6riGxCQAAWVI0.jpg" width="150" height="150" /> 13%');
						}else{
							$(element).find('.fc-time').prepend('<img src="http://icons.iconarchive.com/icons/arrioch/halloween/256/radioactive-icon.png" width="50" height="50" /> 13%');
						}
				}*/
			},
			eventColor: '#378006',
			
			selectable: true,
			loading: function(bool) {
				$('#loading').toggle(bool);
			}
			
		});
    
	});

</script>
<style>

	body {
		margin: 40px 10px;
		padding: 0;
		font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
		font-size: 14px;
	}
		
	#loading {
		display: none;
		position: absolute;
		top: 10px;
		right: 10px;
	}

	#calendar {
		max-width: 900px;
		margin: 0 auto;
	}

</style>
</head>
<body>

	<div>Hello<%=dateMobility%>Hi<%=mobility%></div>
	<div><%=event%>
	</div>
	<form action="DetailHT.jsp" method="post">
	<input name="date" value="<%=dateMobility%>">
	<div id='calendar'></div>
	</form>
	<div class="progress">
  		<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width:<%=mobility%>;">
    	<%=mobility%>
  		</div>
	</div>

	

</body>
</html>
