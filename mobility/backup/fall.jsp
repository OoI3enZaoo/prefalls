<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
  String tstamp = "2017-06-01 19:10:04";

   if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
  dbm.createConnection();
  tstamp = (String)request.getParameter("date");
     String ssfn = (String)session.getAttribute("ssfn");
 	   String ssln = (String)session.getAttribute("ssln");

 	if(request.getParameter("SSSN") != null){
 		session.setAttribute("SSSN",request.getParameter("SSSN"));
 	}
String sssn = (String)session.getAttribute("SSSN");
String fall_history_json = "\'{\"falling\": [";
String test_lat = "";
String test_lon = "";

String impact_force ="";	
	
	try {

		String sql = "SELECT tstamp , hr , act_type FROM archive_"+sssn+" WHERE tstamp BETWEEN SUBTIME('"+tstamp+"' , '0:30:00') AND ADDTIME('"+tstamp+"' , '0:30:00') ORDER BY tstamp";
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
		//out.println(tstamp);
		//out.println(fall_history_json);

		
	try {


		String sql = "SELECT lat , lon FROM archive_"+sssn+" WHERE tstamp = DATE_FORMAT('"+tstamp+"','%Y-%m-%d %H:%i:%s')";
		ResultSet rs = dbm.executeQuery(sql);
		
		while((rs!=null) && (rs.next())){
			test_lat = String.valueOf(rs.getDouble("lat"));
			test_lon = String.valueOf(rs.getDouble("lon"));
		}


		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}	
		
	//out.println(test_lat +"m"+ test_lon);
	
	
	try {

		String sql = "SELECT pace FROM archive_"+sssn+" WHERE tstamp ='"+tstamp+"'";
		ResultSet rs = dbm.executeQuery(sql);
		while((rs!=null) && (rs.next())){
			impact_force = String.valueOf(rs.getInt("pace"));
		}

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

		//out.println("pace = " + impact_force);
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



<script>
	var lat = <%=test_lat%>;
	var lng = <%=test_lon%>;
	var fall_history = <%=fall_history_json%>;
	var json_fall_history = JSON.parse(fall_history);


    function Generator_Activity() {
    var Data = [];
	var color_code = "";
	var heartrate_random = Math.floor((Math.random() *100)+1);
    for (i = 0; i < json_fall_history.falling.length; i++) {
		var now_time = moment('<%=tstamp%>').format('YYYY-MM-D hh:mm:ss');
		var json_time = json_fall_history.falling[i].start;
		
		var d1 = new Date (now_time);
		var d2 = new Date (json_time);
				
				if(parseInt(json_fall_history.falling[i].act) == 2){color_code = "#C0C0C0";}
				else if(parseInt(json_fall_history.falling[i].act) == 1){color_code = "#e98529";}
				else if(parseInt(json_fall_history.falling[i].act) == 3){color_code = "#d4f145";}
				else if(parseInt(json_fall_history.falling[i].act) == 4){color_code = "#5bda47";}
				else if(parseInt(json_fall_history.falling[i].act) == 5){color_code = "#003300";}
				else if(parseInt(json_fall_history.falling[i].act) == 8){color_code = "#0983d2";}
				else if(parseInt(json_fall_history.falling[i].act) == 6){color_code = "#e448e7";}
				
				if(d1.getTime() === d2.getTime()){
					Data.push({
					lineColor: "#FF0000",
					heartrate: json_fall_history.falling[i].value,
					date: json_fall_history.falling[i].start
				});
				}
				else{
					Data.push({
					lineColor: color_code,
					heartrate: json_fall_history.falling[i].value,
					date: json_fall_history.falling[i].start
				});
				}

    }
    return Data;
	}

	var chart_realtime = AmCharts.makeChart("chartdivactivity", {
     "type": "serial",
    "theme": "light",
    "marginRight": 80,
	"dataProvider": Generator_Activity()
    /*"dataProvider": [{
           "lineColor": "#b7e021",
        "date": "2017-06-02 14:50:29",
        "heartrate": 408
    },{
			"lineColor": "#b7e021",
      "date": "2017-06-02 14:50:30",
        "heartrate": 208
    }, {
        "lineColor": "#FFFF00",
      "date": "2017-06-02 14:50:31",
         "heartrate": 482
    }, {
        "lineColor": "#FFFF00",
      "date": "2017-06-02 14:50:32",
         "heartrate": 562
    }, {
        "lineColor": "#FFFF00",
      "date": "2017-06-02 14:50:33",
         "heartrate": 379
    }, {
		        "lineColor": "#FFFF00",
      "date": "2017-06-02 14:50:34",
         "heartrate": 640
    }, {
		"lineColor": "#2498d2",
      "date": "2017-06-02 14:50:35",
         "heartrate": 379
    }, {
      "date": "2017-06-02 14:50:36",
	  "heartrate": 640
    },{
		"lineColor": "#FF0000",
      "date": "2017-06-02 14:50:37",
         "heartrate": 379
    }, {
      "date": "2017-06-02 14:50:38",
         "heartrate": 640
    }, {
      "date": "2017-06-02 14:50:39",
         "heartrate": 140
    }, {
      "date": "2017-06-02 14:50:40",
         "heartrate": 240
    }]
*/
	,
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
/*
		var i_realtime =1;
	setInterval( function() {
  // normally you would load new datapoints here,
  // but we will just generate some random values
  // and remove the value from the beginning so that
  // we get nice sliding graph feeling

  // remove datapoint from the beginning
  //chart_realtime.dataProvider.shift();

  // add new one at the end

	var stringdate = "2017-06-01 18:30:00";
	var momentdate = moment(stringdate);
	
	console.log("show i =" + i_realtime);
	var date_test = moment(momentdate).add(3*i_realtime,'s').format('YYYY-MM-D k:mm:ss');
	var heartrate_random = Math.floor((Math.random() *100)+1);
	var color_text = "";
	if (heartrate_random > 60){
		color_text = "#b7e021";
	}
	else if (heartrate_random >20){
		color_text = "#FF0000";
	}
	else {
		color_text = "#FF00FF";
	}

	console.log(date_test);
	console.log(heartrate_random);
	console.log(color_text);

	chart_realtime.dataProvider.push( {

	lineColor: color_text,
	date: date_test,
	heartrate: heartrate_random

	} );
	chart_realtime.validateData();
	
	i_realtime++;
	}, 3000 );
*/

    function initMap() {
        var myLatLng = {lat:lat, lng: lng};

        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 16,
          center: myLatLng,
		  draggable: false
		  
        });

        var marker = new google.maps.Marker({
          position: myLatLng,
          map: map,
          title: 'Hello World!'
        });
    }
	  
	function getLocation (lat , lng){
		if(lat == 0 || lng == 0){
			$("#location").text("N/A");
		}else{
			$.getJSON("http://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng+"&sensor=false", function(result){
            $("#location").text(result.results[0].formatted_address);
			console.log("print location = "  + result.results[0].formatted_address);
			});
		}
		
	}



	
	$(function(){
      document.getElementById("patient").innerHTML = "Patient Name : " + name;

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
var canvas = document.getElementById("canvas8");
var ctx = canvas.getContext("2d");
ctx.fillStyle = '#FF0000';
ctx.fillRect(0, 0, 80, 80);
});

 </script>
 
     <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFdI5SnLF-CIQ5lRKo_lEqaR6yPN4g7sk&callback=initMap">
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
  #map {
        position: relative;
        width: 100%;
        height: 45vh;
        margin: 0;
        padding: 0;
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

    <div id="tab0default" class="tab-pane fade in active">
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="margin-left:5px;margin-right:5px;">
          <!--<img src=https://image.flaticon.com/icons/svg/148/148976.svg>-->
           <div id="map" style="height:268px;"></div>
                    </div>
                </div>
       <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/148/148976.svg" width="30" height="30"></div>
                        <div class="fs20">Date : <font id="date"></font><%=tstamp%></div>
                    </div>
                </div>
      <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img style="margin-top:10px;" src="https://image.flaticon.com/icons/svg/149/149060.svg" width="30" height="30" ></div>
                        <div class="fs20">Location : <font id="location"><script>getLocation('<%=test_lat%>','<%=test_lon%>');</script></font></div>
                    </div>
                </div>
     <!-- <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/130/130160.svg" width="30" height="30"></div>
                        <div class="fs20">Type of Falling : <font id="type_of_falling"></font>Falling to front</div>
                    </div>
                </div>-->
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/109/109394.svg" width="30" height="30"></div>
                        <div class="fs20">Impact Force : <font id="speed_before"></font><%=impact_force%> m/s</div>
                    </div>
                    <!--<div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/353/353990.svg" width="30" height="30"></div>
                        <div class="fs20">Additional info : <font id="additional">Test ADditional Data for testing once</font></div>
                    </div>-->
                </div>
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
                          <h5 class="text-primary legend" style="margin-top: 120px">Stair Climbing</h5>
                    <br> <br>
            </div>
            <div class="col-md-4 col-xs-6">
              <canvas id="canvas4" width="100" height="30"></canvas>
                <h5 class="text-primary legend" style="">Sleeping</h5>
                <br><br>
                <canvas id="canvas5" width="100" height="30"></canvas>
                  <h5 class="text-primary legend" style="margin-top: 65px">Walking</h5>
                  <br> <br>
				<canvas id="canvas8" width="100" height="30"></canvas>
                  <h5 class="text-primary legend" style="margin-top: 120px">Start of time</h5>
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

