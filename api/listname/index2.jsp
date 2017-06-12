<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	int sismobile = 0;
%>

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../");
	}

	
	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String ssuid = (String)session.getAttribute("ssuid");
	String sstypeid = (String)session.getAttribute("sstypeid");


	if(sstypeid.equals("3")){
		
		dbm.createConnection();
		
		try {

			String sql = "select * from supervise,caregiver where caregiver.type_id = '"+sstypeid+"' and caregiver.UID = supervise.UID";
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();
				response.sendRedirect("../activity.jsp?SSSN="+rs.getString("SSSN"));
   
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
			
   
   if(sstypeid.equals("2")) {
   %>

        
	<%		
			}
	%>
        
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
        
		
					<%
						if (un.next()){
							sismobile = un.getInt("SISMOBILE");
							double mobilityindex = Math.round((((sismobile * 3)/864)+0.00001)*100)/100;
					%>		

					<%
	    			    }
	    			%>
					
		<script>

			var myHandler<%=sssn%> =
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

		           	type = message.getAttribute('type');
				   	console.log("type var = "+type);
				   	if(type == 5 || type == 6){
				   		document.getElementById("icon_<%=sssn%>").innerHTML='<img src="Heart.png" hight="30" width="30">';
				   	}else if(type == 2){
				   		document.getElementById("icon_<%=sssn%>").innerHTML='<img src="turn.png" hight="40" width="40">';
				   	}else{
				   		document.getElementById("icon_<%=sssn%>").innerHTML="";
				   	}


		        },	
		        myId: 'userID<%=sssn%>',
		        myDestination: 'topic://<%=sssn%>_alert',
		        myDestination: 'topic://<%=sssn%>_pred'
		      }
		 
			amq.addListener(myHandler<%=sssn%>.myId, myHandler<%=sssn%>.myDestination,myHandler<%=sssn%>.rcvMessage);

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
</head>
<body>
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
	            <li><a href="../logout.jsp">ออกจากระบบ</a></li>
	        </ul>
	    </div>
	</div>
</nav>
<div class="container">
	<div class="container-header col-md-12 line">
        <a href='add.jsp'><button type='button' class='btn btn-primary glyphicon glyphicon-plus'>เพิ่มผู้สูงอายุ</button></a>
        <font class="s20">รายชื่อผู้สูงอายุ</font>
    </div>
    <div class="container">
        <div class="row line">
			<a href="#" onclick="id<%=sssn%>()" class="ccc">
				<div class="col-xs-4 col-md-2">
				    <img class="mpic" src="../images/patients/<%=imgpath%>">
				</div>
				<div class="col-xs-4 col-md-6">
					<p><%=fname%> <%=lname%></p>
                    <div class="progress" >
	  				<div class="progress-bar progress-bar-success" id="Mo_<%=sssn%>" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width:<%=mobilityindex%>% ">
	    			<p style="color: #000000;"><%=mobilityindex%>%</p>
	    			<div id="Mo_<%=sssn%>">
	    			</div>
					</div>
					</div>
                    <div><div id="icon_<%=sssn%>"></div></div>
				</div>
			</a>
        </div>	
    </div>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
            
    
    
    <form id="target" action="../activity.jsp" method="post" style="display:none;">
            <input name="SSSN" value="<%=sssn%>">
            <input name="fname" value="<%=fname%>">
            <input name="lname" value="<%=lname%>">
            <input id="<%=sssn%>" type="submit">
        </form> 