<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
	
	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	
	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}
	
	dbm.createConnection();
	
	int sit = 0;
	int stand = 0;
	int walk = 0;
	int as = 0;
	int run = 0;
	int cycling =0;
	int step = 0;
	
	int avghr = 0;
	int count =0;	
	
	try {
		
		String sql = "select * from archive;" ;
		ResultSet rs = dbm.executeQuery(sql);
			 
		while((rs!=null) && (rs.next())){
			if(rs.getString("act_type").equals("1")){
				sit += 5;
			} else if(rs.getString("act_type").equals("2")){
				stand += 5;
			} else if(rs.getString("act_type").equals("3")){
				walk += 5;
			} else if(rs.getString("act_type").equals("4")){
				as += 5;
			} else if(rs.getString("act_type").equals("5")){
				run += 5;
			} else if(rs.getString("act_type").equals("6")){
				cycling += 5;
			}
			
			step += Integer.parseInt(rs.getString("steps"));
			avghr += Integer.parseInt(rs.getString("heartRateEvent"));
			count ++;
		}
		
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();
	
%>

<!doctype html>
<head>
<title>mobilise</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="images/icon.png"/>
<link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="js/amq.js"></script>
<script src="http://www.amcharts.com/lib/3/amcharts.js"></script>
<script src="http://www.amcharts.com/lib/3/pie.js"></script>
<script src="http://www.amcharts.com/lib/3/themes/light.js"></script>
<script type="text/javascript">
	
	var sit = <%=sit%>;
	var stand = <%=stand%>;
	var walk = <%=walk%>;
	var as = <%=as%>;
	var run = <%=run%>;
	var cycling =<%=cycling%>;
	
	var count =<%=count%>;	

	//<sensor-reading id='1' ts='1449342613' pid='MA36PB256Y' lat='13.779152' lng='100.556808' acc='20' alt='5.0' spd='10.45' dist='3.21' bearing='3.22' hr='87' steps='1' spo2='98' acl='{0,1.2,1.1,1.3,1.1}' act='1' />
	var lat = 0;
    var lng = 0;
	var hr = <%=avghr%>;
	var steps = <%=step%>;
	var spo2 = 0;
	var act = 0;

    var amq = org.activemq.Amq;
    amq.init({ 
     uri: 'amq',
     logging: true,
     timeout: 20
    });
	
	var myHandler =
      {
        rcvMessage: function(message)
        {
		   lat = message.getAttribute('lat');
           lng = message.getAttribute('lng');
           spo2 = message.getAttribute('spo2');
           
           steps += eval(message.getAttribute('steps'));
		   hr += eval(message.getAttribute('hr'));
		   act = eval(message.getAttribute('act'));
		   
		   if(act == 1){
			 sit++;
		   }else if(act == 2){
			 stand++;
		   }else if(act == 3){
			 walk++;
		   }else if(act == 4){
			   as++;
		   }else if(act == 5){
			   run++;
		   }else if(act == 6){
			   cycling++;
		   }
		   count++;
		   
		   var cal = (sit*1.6)+(stand*2.3)+(walk*5)+(as*14.1)+(run*11.6)+(cycling*10);
		   
		   document.getElementById("cal").innerHTML = cal;
		   document.getElementById("stationary").innerHTML = (sit+stand);
		   document.getElementById("active").innerHTML = (walk+as);
		   document.getElementById("highlyactive").innerHTML = (run+cycling);
		   document.getElementById("steps").innerHTML = (steps);
		   document.getElementById("hr").innerHTML = Math.round((hr/count));
		   
		   updateChart();
        },
        myId: 'test0',
        myDestination: 'topic://MA36PB256Y'
      };
 
	amq.addListener(myHandler.myId, myHandler.myDestination,myHandler.rcvMessage);

	
	//xxxxxxxxxxxxxxxx create chart xxxxxxxxxxxxxxxxxx
	var chart = AmCharts.makeChart( "chartdiv", {
	  "type": "pie",
	  "pullOutRadius": 0,
	  "theme": "light",

	  "allLabels": [{
        "text": "This is chart title",
        "align": "center",
        "bold": true,
        "y": 220
    },{
        "text": "Ans here's the subtitle as well",
        "align": "center",
        "bold": false,
        "y": 250
    }],

	  "dataProvider": [ {
		"title": "Sit",
		"value": sit
	  }, {
		"title": "Stand",
		"value": stand
	  } , {
		"title": "Walk",
		"value": walk
	  }, {
		"title": "Cycling",
		"value": cycling
	  }, {
			"title": "Run",
			"value": run
	   }, {
			"title": "Ascending stairs",
			"value": as
		  }],
	  "titleField": "title",
	  "valueField": "value",
	  "labelRadius": 5,

	  "radius": "42%",
	  "startEffect":">",
	  "innerRadius": "60%",
	  "labelText": "[[title]]",
	  "export": {
	  "enabled": true
	  }
	} );

	function updateChart(){
		//console.log("1111 -- "+chart.dataProvider[1].value);
		var chartData = [];
		chartData.push({"title": "Sit","value": sit});
		chartData.push({"title": "Stand","value": stand});
		chartData.push({"title": "Walk","value": walk});
		chartData.push({"title": "Cycling","value": cycling});
		chartData.push({"title": "Run","value": run});
		chartData.push({"title": "Ascending stairs","value": as});
		  
		chart.dataProvider = chartData;
		chart.validateData();
	}

</script>

<style>

.chart { width:100%; height:500px; }
.connn { height:auto; }
.asd { border-bottom: solid 1px #e1e1e1; margin:10px; padding-bottom:5px; }

@media (min-width:1000px){
	.chart { height:450px; }
	.asd { border-bottom: solid 1px #e1e1e1; margin:10px; padding-bottom:5px; font-size:20px; }
	.connn { height:500px; border-left: solid 1px #e1e1e1; }
}
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
         <a class="header-brand" href="./listname/"><img src="images/logo.png"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav">
            <li class="active"><a href="activity.jsp">กิจกรรมประจำวัน</a></li>
            <li><a href="./history/">ประวัติกิจกรรม</a></li>
            <li><a href="./notifications/">บันทึกการแจ้งเตือน</a></li>
            <li><a href="mobility.jsp">บันทึกผลการทดสอบ</a></li>
            <li><a href="./profile/">ข้อมูลส่วนตัว</a></li>
            <li class="end"><a href="setting.jsp">ตั้งค่า</a></li>
         </ul>
         <ul class="nav navbar-nav navbar-right">
            <li><a><%=ssfn%></a></li>
            <li><a href="logout.jsp">ออกจากระบบ</a></li>
         </ul>
      </div>
   </div>
</nav>
<div class="container">
   <div class="container-header line"><font class="s17">กิจกรรมประจำวัน</font></div>
   <div class="col-md-6 col-xs-12">
      <div id="chartdiv" class="chart"></div>
   </div>
   <div class="col-md-6 col-xs-12">
      <div class="connn">
      	
         <div class="asd"><img src="images/icons/hr.png" width="30" height="30">&nbsp;Avg heart rate&nbsp;:&nbsp;<font id="hr"><%out.print(avghr/count);%></font>&nbsp;bpm</div>
         <div class="asd"><img src="images/icons/step.png" width="30" height="30">&nbsp;Steps&nbsp;:&nbsp;<font id="steps"><%=step%></font></div>
         <div class="asd"><img src="images/icons/cal.png" width="30" height="30">&nbsp;Cal burn&nbsp;:&nbsp;<font id="cal"><%out.print((sit*1.6)+(stand*2.3)+(walk*5)+(as*14.1)+(run*11.6)+(cycling*10));%></font></div>
         <div class="asd"><img src="images/icons/stattime.png" width="30" height="30">&nbsp;Stationary time&nbsp;:&nbsp;<font id="stationary"><%out.print(sit+stand);%></font></div>
         <div class="asd"><img src="images/icons/active.png" width="30" height="30">&nbsp;Active time&nbsp;:&nbsp;<font id="active"><%out.print(walk+as);%></font></div>
         <div class="asd"><img src="images/icons/highlyactive.png" width="30" height="30">&nbsp;Highlyactive time&nbsp;:&nbsp;<font id="highlyactive"><%out.print(run+cycling);%></font></div>

      </div>
   </div>
</div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>