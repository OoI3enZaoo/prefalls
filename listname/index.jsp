<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	int sismobile = 0;

%>
<!doctype html>
<head>
<title>PreFall</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<script type="text/javascript" src="../js/jquery.min.js"></script>
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>
<script src="../js/bootstrap-notify.min.js"></script>
<link rel="stylesheet" href="../css/animate.min.css">
	<script type="text/javascript" src="../js/moment.min.js"></script>

<script type="text/javascript">
var tstamp2 = "";
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
	String fname_alert = "";
	String lname_alert = "";
	String imgpath_alert = "";
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
	        <a class="header-brand" href="#"><img src="../images/logo.png" style = "width: 178px; height: 35px;   margin-top: 8px;"></a>
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
				var <%=sssn%>_isFall = false;
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
							<div class ="col-md-3">
										<a href="#" onclick="id<%=sssn%>()" class="ccc" ">
											<div class="c1">
				    							<img class="mpic" src="../images/patients/<%=imgpath%>">
											</div>
						   </div>
				       <div class = "col-md-5">
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

											<div class = "col-md-2">
														<span id = "icon3_<%=sssn%>"></span>
											</div>
											<div clsas = "col-md-2">
												<span id = "icon4_<%=sssn%>" </span>
											</div>
				</div>


		</div>

		<br>

<script>







			//xxxxxxxxxxxxxxxx  mobility index xxxxxxxxxxxxxx
			var myHandler<%=sssn%>_pred =
		      {
		        rcvMessage: function(message)
		        {


		        	ismobile = message.getAttribute('ismobile');
							tstamp2 = moment(parseInt(message.getAttribute("ts"))).format("YYYY-MM-DD HH:mm:ss");

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
							document.getElementById("icon2_<%=sssn%>").innerHTML='';
						}, 2000);
				   	}


						if(type == 7){
						var countIcon4 = 0;
						var interval4;
						if(<%=sssn%>_isFall == false){
							 interval4 = setInterval(function(){
								if(countIcon4 == 0){
									document.getElementById("icon4_<%=sssn%>").innerHTML = '<img src="../images/icons/alert/fall.png" width="50" height="50"><i>- fall!</i>';
									countIcon4 = 1;
								}else{
									document.getElementById("icon4_<%=sssn%>").innerHTML = '';
									countIcon4 = 0;
								}
								<%=sssn%>_isFall = true;
							},2000);
							checkAlert(type,message.getAttribute('pid'));
						}

						}
						if(type == 3 || type == 4 || type == 8 || type == 9){
							console.log("isfall2: " + <%=sssn%>_isFall);
							if(<%=sssn%>_isFall == false){
							document.getElementById("icon3_<%=sssn%>").innerHTML = '<img src="../images/icons/alert/warning_a.png" width="50" height="50"> <i>- fall risk!</i>';
							setTimeout(function(){
									document.getElementById("icon3_<%=sssn%>").innerHTML = '';

							},2000);

								  checkAlert(type,message.getAttribute('pid'));
									}
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



	}

   	%>
   	</div>
   	</div>
</div>




<script type="text/javascript">

var countsta = 0;
var countsym = 0;
var countfall = 0;
function checkAlert(type,uid){

console.log("checkAlert: " + type + " uid: " + uid);
console.log('<%= fname_alert %>');
	if(type == 3 || type == 4){
		countsta++;
		if(countsta == 1){
			countsta =0;
			if(type == 3){alert(1,1,uid);}else{alert(1,2,uid);}

		}
	}
	if(type == 8 || type == 9){
		countsym++;
		if(countsym == 1){
			countsym = 0;
			if(type == 8){alert(2,1,uid);}else{alert(2,2,uid);}

		}
	}

	if(type == 7){
		countfall++;
		if(countfall == 1){
			countfall = 0;
			alert(3,2,uid);

		}
	}

}
function alert(type , level,uid){
console.log("alert: " + type + " level: " +level + " uid: " + uid);
var mlevel;
var mMessage;
if(type == 1){
	if(level == 1){
			mMessage = "Stability index warning";
	}else{
		mMessage = "Stability index danger";
	}

}
else if(type == 3){
	mMessage = "Fall is detected";
}
else{
	if(level == 1){
	mMessage = "Symmetry index warning";
	}else{
	mMessage = "Symmetry index danger";
}

}
if(level == 1){

	mlevel = "warning";
}else{

	mlevel = "danger";
}

$.getJSON("http://sysnet.utcc.ac.th/prefalls/listname/getInfoAlert.jsp?sssn="+uid+"",function(result){
	var ftitle = "<span style = 'margin-left: 10px; font-weight: bold; margin-bottom: 5px; font-size: 15px; display:block;'>";
	var mtitle = result[0].firstname + " " + result[0].lastname;
	var ltitle = "</span>";
	var resTitle = ftitle + mtitle + ltitle;
	var res_url;
	console.log("typena : " + type);
	if(type == 3){
		//res_url = "http://sysnet.utcc.ac.th/prefalls/mobility/fall.jsp?date="+tstamp2;
		res_url = "http://sysnet.utcc.ac.th/prefalls/mobility/";

	}else{
		res_url = "../activity/?SSSN="+uid;
	}
	console.log("res_url: " + res_url);
	var resicon = "../images/patients/" + result[0].imgPath;

	$.notify({
	icon: resicon,
	title: resTitle,
	message: "<span style = 'margin-left: 10px;'>"+mMessage+"</span>",
	url: res_url,
	target: "_self",
	allow_dismiss: true
	},{
	type: mlevel,
	delay: 10000,
	icon_type: 'image',
	template: '<div data-notify="container" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
		'<button type="button" aria-hidden="true" class="close" data-notify="dismiss">×</button>' +
		'<img  data-notify="icon" class="img-circle pull-left" width= "55px" height = "55px"> ' +
		'<span data-notify="title">{1}</span>' +
		'<span data-notify="message">{2}</span>' +
		'<div class="progress" data-notify="progressbar">' +
			'<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
		'</div>' +
		'<a href="{3}" target="{4}" data-notify="url"></a>' +
	'</div>'
	});



});








}


  </script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
