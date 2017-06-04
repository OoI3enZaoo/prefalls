<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.GregorianCalendar" %>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%

   if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}


	String tstamp = (String)request.getParameter("date");
	//varible from session
    String ssfn = (String)session.getAttribute("ssfn");
 	String ssln = (String)session.getAttribute("ssln");
	String sssn = (String)session.getAttribute("SSSN");
	String name = "\'" + session.getAttribute("fname") + " " + session.getAttribute("lname") + "\'";

	//tstamp = "2017-06-03 14:20:04";

	Calendar c = Calendar.getInstance();
	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	String currentDate = df.format(c.getTime());
	out.println("<br>Current Date : " + currentDate);

	String fall_history_json = "\'{\"falling\": [";


 	if(request.getParameter("SSSN") != null){
 		session.setAttribute("SSSN",request.getParameter("SSSN"));
 	}

		dbm.createConnection();
	try {

		String sql = "SELECT tstamp , hr , act_type FROM archive_"+sssn+" WHERE tstamp BETWEEN SUBTIME('"+currentDate+"' , '1:00:00') AND '"+currentDate+"' ";
		ResultSet rs = dbm.executeQuery(sql);
		if((rs!=null) && (rs.next())){
			fall_history_json = fall_history_json + "{\"start\":\"" + rs.getString("tstamp") + "\" , \"value\":\"" + rs.getFloat("hr") + "\" , \"act\":\"" + rs.getInt("act_type") + "\"}";
		}
		while((rs!=null) && (rs.next())){
			fall_history_json = fall_history_json + ", {\"start\":\"" + rs.getString("tstamp") + "\" , \"value\":\"" + rs.getFloat("hr") + "\" , \"act\":\"" + rs.getInt("act_type") + "\" }";
		}
			fall_history_json = fall_history_json + "]}\'";

	} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		//out.println(fall_history_json);
		//out.println(tstamp);

   		dbm.closeConnection();

    %>

<!doctype html>
<head>
<title>mobilise</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<!-- CSS Main File-->
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<!-- JS amCharts File -->
<script type="text/javascript" src="../js/jquery-1.4.2.min.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/amcharts.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/serial.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/gantt.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/plugins/export/export.min.js"></script>
<link rel="stylesheet" href="../bower_components/amcharts/dist/amcharts/plugins/export/export.css" type="text/css" media="all" />
<script src="../bower_components/amcharts/dist/amcharts/themes/light.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/pie.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/xy.js"></script>
<script type="text/javascript" src="../js/moment.min.js"></script>


<!--javascript_message_server-->
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>

<script type="text/javascript">
    var i_realtime =1;
	var message_act;
	var message_ts;
	var message_hr;
	var fall_history = <%=fall_history_json%>;
	var json_fall_history = JSON.parse(fall_history);
	console.log(json_fall_history);

	function Generator_Activity() {
    var Data = [];
	var color_code = "";

    for (var i = 0; i < json_fall_history.falling.length; i++) {

				if(parseInt(json_fall_history.falling[i].act) == 2){color_code = "#C0C0C0";}
				else if(parseInt(json_fall_history.falling[i].act) == 1){color_code = "#e98529";}
				else if(parseInt(json_fall_history.falling[i].act) == 3){color_code = "#d4f145";}
				else if(parseInt(json_fall_history.falling[i].act) == 4){color_code = "#5bda47";}
				else if(parseInt(json_fall_history.falling[i].act) == 5){color_code = "#003300";}
				else if(parseInt(json_fall_history.falling[i].act) == 8){color_code = "#0983d2";}
				else if(parseInt(json_fall_history.falling[i].act) == 6){color_code = "#e448e7";}


				//console.log("show data json act = " + json_fall_history.falling[i].act);
				//console.log("show data json start = " + json_fall_history.falling[i].start);
				//console.log("show data json hr = " + json_fall_history.falling[i].value);

				Data.push({
					lineColor: color_code,
					heartrate: json_fall_history.falling[i].value,
					date: json_fall_history.falling[i].start
				});



    }
    return Data;
	}


var chart_realtime = AmCharts.makeChart("chartdivactivity", {
     "type": "serial",
    "theme": "light",
    "marginRight": 80,
	"dataProvider": Generator_Activity(),
    "balloon": {
        "cornerRadius": 6,
        "horizontalPadding": 15,
        "verticalPadding": 10
    },
  "valueAxes": [{
        "id": "heartrateAxis",
        "axisAlpha": 0,
        "gridAlpha": 0,
        "position": "left",
        "title": "heartrate1"
    }],
    "graphs": [{
        "bullet": "square",
        "bulletBorderAlpha": 1,
        "bulletBorderThickness": 1,
        "fillAlphas": 0.3,
        "fillColorsField": "lineColor",
        "legendValueText": "[[value]]",
        "lineColorField": "lineColor",
        "valueField": "heartrate",
		"valueAxis": "heartrateAxis"
    }],
	"chartScrollbar": {

    },
    "chartCursor": {
        "categoryBalloonDateFormat": "JJ:NN:SS, DD MMMM YYYY",
        "cursorPosition": "mouse"
    },
    "categoryField": "date",
	"dateFormat": "YYYY-MM-DD HH:NN:SS",
    "categoryAxis": {
        "minPeriod": "ss",
        "parseDates": true
    },
    "export": {
        "enabled": true
    },
});


chart_realtime.addListener("dataUpdated", zoomChart_realtime);

function zoomChart_realtime() {
    chart_realtime.zoomToIndexes(chart_realtime.endIndex-20,chart_realtime.endIndex);
}

$(function(){


  		var canvas = document.getElementById("canvas1");
     var ctx = canvas.getContext("2d");
     ctx.fillStyle = '#C0C0C0';
     ctx.fillRect(0, 0, 80, 80);
     var canvas = document.getElementById("canvas2");
    var ctx = canvas.getContext("2d");
    ctx.fillStyle = '#5bda47';
    ctx.fillRect(0, 0, 80, 80);
    var canvas = document.getElementById("canvas3");
   var ctx = canvas.getContext("2d");
   ctx.fillStyle = '#e448e7';
   ctx.fillRect(0, 0, 80, 80);
   var canvas = document.getElementById("canvas4");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#e98529';
  ctx.fillRect(0, 0, 80, 80);
  var canvas = document.getElementById("canvas5");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#003300';
  ctx.fillRect(0, 0, 80, 80);
  var canvas = document.getElementById("canvas6");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#d4f145';
  ctx.fillRect(0, 0, 80, 80);
  var canvas = document.getElementById("canvas7");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#0983d2';
  ctx.fillRect(0, 0, 80, 80);

  document.getElementById("patient").innerHTML = "Patient Name : " + name;
  });


setInterval( function() {
  // normally you would load new datapoints here,
  // but we will just generate some random values
  // and remove the value from the beginning so that
  // we get nice sliding graph feeling

  // remove datapoint from the beginning
  //chart_realtime.dataProvider.shift();

  // add new one at the end
  var color_text ="";
	if(message_act == 2){color_text = "#C0C0C0"}
			else if(message_act == 1){color_text = "#e98529";}
			else if(message_act == 3){color_text = "#d4f145";}
			else if(message_act == 4){color_text = "#5bda47";}
			else if(message_act == 5){color_text = "#003300";}
			else if(message_act == 8){color_text = "#0983d2";}
			else if(message_act == 6){color_text = "#e448e7";}

	//console.log(date_test);
	//console.log(heartrate_random);
	//console.log(color_text);

	console.log("show real time message_act = " + message_act);
	console.log("show real time message_hr = " + message_hr);
	console.log("show real time message_ts = " + message_ts);

	chart_realtime.dataProvider.push( {

	lineColor: color_text,
	date: message_ts,
	heartrate: message_hr

	} );
	chart_realtime.validateData();

	}, 3000 );

</script>
<script>

  var amq = org.activemq.Amq;
    amq.init({
     uri: '../amq',
     logging: true,
     timeout: 20
    });


var myHandler =
      {
        rcvMessage: function(message)
        {
            message_act = parseInt(message.getAttribute("act_type"));
			message_hr = parseInt(message.getAttribute("hr"));
			message_ts = moment(parseInt(message.getAttribute("ts"))).format("YYYY-MM-DD HH:mm:ss");

			console.log("show message_act = " + message_act);
			console.log("show message_hr = " + message_hr);
			console.log("show message_ts = " + message_ts);
        },
        myId: 'test66',
        myDestination: 'topic://<%=sssn%>_pred'
      };

  amq.addListener(myHandler.myId, myHandler.myDestination,myHandler.rcvMessage);

</script>


<style media="screen">

.chart { width:100%; height:500px; }
.icon { float:left; margin-right:10px; }
.col-md-6 { padding-left:5px; padding-right:5px; }

@media (min-width:1000px){

	.chart { height:450px; }
	.asd { margin:10px; padding-bottom:5px; font-size:20px; }
    .connn { height:500px; border-left: solid 1px #e1e1e1; }

}

    #chartdivactivity {
    	width		: 100%;
    	height		: 500px;
    	font-size	: 11px;
    }
    .amcharts-export-menu-top-right {
      top: 10px;
      right: 0;
    }
    .legend{
    	position: absolute; top:0;
    	 margin-top: 5px;
    	 margin-left: 100px;
    }
</style>
<body>
<%@include file="../include/nav.jsp"%>
<div class="container">
    <div class="panel"><font class="fs17">Fall History > <span id="date"></span><span id="patient" class="right"></span></font></div>
	<div class="row">
		<div class="col-md-12">

					 <div class="col-md-12 col-xs-12">
					    <div class="panel" style="margin-left:0px;margin-right:0px;">
                            <div id="chartdivactivity"></div>
                        </div>
					</div>
					<div class="col-md-12 col-xs-12">
					    <div class="panel" style="margin-left:0px;margin-right:0px;">
							<%-- <div> <img style="margin-left:100px;margin-top:25px;" src="../images/description1.png"></div> --%>
							<div class="row" style= "margin-left: 5px; margin-top: 10px; margin-right: 10px; ">

							  <div class="col-md-4 col-xs-6">

							    <canvas id="canvas1" width="100" height="30"></canvas>
							      <h5 class="text-primary legend" style="">Lying</h5>
							    <br> <br>
							    <canvas id="canvas2" width="100" height="30"></canvas>
							          <h5 class="text-primary legend" style="margin-top: 65px">Standing</h5>
							          <br> <br>
							          <canvas id="canvas3" width="100" height="30"></canvas>
							                <h5 class="text-primary legend" style="margin-top: 125px">Stair Climbing</h5>
  											<br> <br>
							  </div>
							  <div class="col-md-4 col-xs-6">
							    <canvas id="canvas4" width="100" height="30"></canvas>
							      <h5 class="text-primary legend" style="">Sleeping</h5>
							      <br><br>
							      <canvas id="canvas5" width="100" height="30"></canvas>
							        <h5 class="text-primary legend" style="margin-top: 65px">Walking</h5>
											<br> <br>
							  </div>
							  <div class="col-md-4 col-xs-6">
							    <canvas id="canvas6" width="100" height="30"></canvas>
							      <h5 class="text-primary legend" style="">Sitting</h5>
							      <br><br>
							      <canvas id="canvas7" width="100" height="30"></canvas>
							        <h5 class="text-primary legend" style="margin-top: 65px">Running</h5>
											<br> <br>

							  </div>
							</div>

                        </div>
					</div>
        </div>
	</div>
</div>
</body>
