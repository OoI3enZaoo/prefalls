<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	int sismobile = 0;
%>
<!doctype html>
<head>
<title>mobilise</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<script type="text/javascript" src="../js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>
<script type="text/javascript">
	var sismobile = 0;
	var type = 0;
	var mobilityIdx = 0;

    var amq = org.activemq.Amq;
    amq.init({ 
     uri: '../amq',
     logging: true,
     timeout: 20
    });
	
</script>
<style>

.c1 { width: 150px; float: left; margin-left: 20px; }
.c2 { float: left; }
.name { font-size: 20px; }
.icons img { width: 30px; }

@media (max-width:500px) {

	.progress { width:65%; }

}


</style>
</head>
<body>
<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../");
	}

	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String ssuid = (String)session.getAttribute("ssuid");
	String sstypeid = (String)session.getAttribute("sstypeid");
    String name = name = "\'" + session.getAttribute("ssfn") + " " + (String)session.getAttribute("ssln") + "\'";

	if(sstypeid.equals("3")){
		
		dbm.createConnection();
		
		try {

			String sql = "select * from supervise,caregiver where caregiver.type_id = '"+sstypeid+"' and caregiver.UID = supervise.UID";
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();
				response.sendRedirect("../activity/?SSSN="+rs.getString("SSSN"));
   
			}
			
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();
		
	} else {
		
		dbm.createConnection();
		
		try {
			
			String sql = "select * from supervise,patients where supervise.UID = '"+ssuid+"' and supervise.SSSN = patients.SSSN";
			
			ResultSet rs = dbm.executeQuery(sql);
			
	%>	
<nav class="navbar navbar-default navbar-static-top">
	<div class="container-fluid" >
	    <div class="navbar-header">
	        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
	            <span class="icon-bar"></span>
	            <span class="icon-bar"></span>
	            <span class="icon-bar"></span>
	        </button>
	        <a class="header-brand" href="#"><img src="../images/logo.png"></a>
	    </div>
	    <div id="navbar" class="navbar-collapse collapse">
	        <ul class="nav navbar-nav navbar-right">
	            <li><a><%=ssfn%></a></li>
	            <li><a href="../logout.jsp">Sign out</a></li>
	        </ul>
	    </div>
	</div>
</nav>
<div class="container">
	<div class="panel panel-default">
	<div class="panel-body">
	<div class="container-header col-md-12 line">
		
   <%
   if(sstypeid.equals("2")) {
   %>

        <a href='add.jsp'><button type='button' class='btn btn-primary glyphicon glyphicon-plus'>Add Petient</button></a>
	<%		
			}
	%>
        <font class="fs17">Petient list</font>
    </div>
	<%
       
	while(rs.next()){
		String sssn = rs.getString("SSSN");
		String fname = rs.getString("firstname");
		String lname = rs.getString("lastname");
		String imgpath = rs.getString("imgPath");
		int minHR = rs.getInt("minHeartRate");
		int maxHR = rs.getInt("maxHeartRate");
		String union = "SELECT SUM(ismobile) AS SISMOBILE FROM archive_" + sssn + " WHERE (DATE(tstamp) = CURRENT_DATE());";
		ResultSet un = dbm.executeQuery(union);
					
	%>
        <script>
            function id<%=sssn%>(){
                $('#<%=sssn%>').click();
            }
        </script>
        
        <form id="target" action="../activity/" method="post" style="display:none;">
            <input name="SSSN" value="<%=sssn%>">
            <input id="<%=sssn%>" type="submit">
        </form>  
        
		<div class="line">
			<div class="row">
			<a href="#" onclick="id<%=sssn%>()" class="ccc">
				<div class="c1">
				    <img class="mpic" src="../images/patients/<%=imgpath%>">
				</div>
				<div class="c2" style="width:300px;">
					<div class="name"><p><%=fname%> <%=lname%></p></div>
					<%
						if (un.next()){
							sismobile = un.getInt("SISMOBILE");
							double mobilityindex = Math.round((((sismobile * 3)/864)+0.00001)*100)/100;
					%>		
					<div class="progress" style=background-color:#B2B1AC;>
	  				<div class="progress-bar progress-bar-success" id="Mo_<%=sssn%>" role="progressbar" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100" style="width:<%=mobilityindex%>% ">
	    			<p style="color: #000000;"><%=mobilityindex%>%</p>
	    			<div id="Mo_<%=sssn%>">
	    			</div>
					</div>
					</div>
					<%
	    			    }
	    			%>
					<div class="icons">
						<span id="icon_<%=sssn%>">
						</span>
						<span id="icon2_<%=sssn%>">
						</span>
					</div>
				</div>
			</a>
			</div>	
		</div><br>
                
		<script>
			//xxxxxxxxxxxxxxxx  mobility index xxxxxxxxxxxxxx
			var myHandler<%=sssn%>_pred =
		      {
		        rcvMessage: function(message)
		        {	


		        	ismobile = message.getAttribute('ismobile');
				   	console.log("ismobile var = "+ismobile);
				   	if(ismobile == true){
				   		sismobile=sismobile+3;
				   		mobilityIdx =Math.round((((sismobile * 3)/864)+0.00001)*100)/100;
				   		document.getElementById("Mo_<%=sssn%>").innerHTML=mobilityIdx+"%";
				   		document.getElementById("Mo_<%=sssn%>").stlye.width=mobilityIdx+"%";
				   	}
 
		        },	
		        myId: 'userID<%=sssn%>_pred',
		        myDestination: 'topic://<%=sssn%>_pred'
		      }
		 
			amq.addListener(myHandler<%=sssn%>_pred.myId, myHandler<%=sssn%>_pred.myDestination,myHandler<%=sssn%>_pred.rcvMessage);

			//xxxxxxxxxxxxxxxx  alert  xxxxxxxxxxxxxx
			var myHandler<%=sssn%>_alert =
		      {
		        rcvMessage: function(message)
		        {	
		           	type = message.getAttribute('type');
				   	console.log("type var = "+type);
				   	if(type == 5){
				   		document.getElementById("icon_<%=sssn%>").innerHTML='<img src="Heart.png" hight="30" width="30"> <i>- low</i>';
						setTimeout(function(){
							document.getElementById("icon_<%=sssn%>").innerHTML="";
						}, 2000);
					}else if(type == 6){
						document.getElementById("icon_<%=sssn%>").innerHTML='<img src="Heart.png" hight="30" width="30"> <i>- high</i>';
						setTimeout(function(){
							document.getElementById("icon_<%=sssn%>").innerHTML="";
						}, 2000);
				   	}else if(type == 2){
				   		document.getElementById("icon2_<%=sssn%>").innerHTML='<img src="turn.png" hight="45" width="45"> <i>- turn the patient!</i>';
						setTimeout(function(){
							document.getElementById("icon2_<%=sssn%>").innerHTML="";
						}, 2000);
				   	}
		        },	
		        myId: 'userID<%=sssn%>_alert',
		        myDestination: 'topic://<%=sssn%>_alert',
		      }
		 
			amq.addListener(myHandler<%=sssn%>_alert.myId, myHandler<%=sssn%>_alert.myDestination,myHandler<%=sssn%>_alert.rcvMessage);

		</script>
	<%
	
	} 	
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();
		
	}

   	%>
   	</div>
   	</div>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>