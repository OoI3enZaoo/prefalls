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

   		dbm.closeConnection();

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
<script type="text/javascript" src="../js/jquery.min.js"></script>
<script src="../js/amcharts/amcharts.js"></script>
<script src="../js/amcharts/xy.js"></script>
<script src="../js/amcharts/themes/light.js"></script>
<script src="https://www.amcharts.com/lib/3/gauge.js"></script>
<script src="../js/bootstrap-notify.min.js"></script>
<link rel="stylesheet" href="../css/animate.min.css">




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
    <div class="panel"><font class="fs17">History > <span id="date"></span><span id="patient" class="right"></span></font></div>
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
                        <div class="fs20">Date : <font id="date"></font> 10/5/2017 , Time : 12.50 </div>
                    </div>
                </div>
      <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img style="margin-top:10px;" src="https://image.flaticon.com/icons/svg/149/149060.svg" width="30" height="30" ></div>
                        <div class="fs20">Location : <font id="location"></font></div>
                    </div>
                </div>
      <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/130/130160.svg" width="30" height="30"></div>
                        <div class="fs20">Type of Falling : <font id="type_of_falling"></font>Falling to front</div>
                    </div>
                </div>
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/109/109394.svg" width="30" height="30"></div>
                        <div class="fs20">Speed before falling : <font id="speed_before"></font>50 km/hr</div>
                    </div>
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/353/353990.svg" width="30" height="30"></div>
                        <div class="fs20">Additional info : <font id="additional">Test ADditional Data for testing once</font></div>
                    </div>
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
  <script type="text/javascript">
  //varible google map
  var lat = 13.664336;
  var lng = 100.387573;


  function initMap() {
    var myLatLng = {lat:lat, lng: lng};

    var map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: myLatLng
    });

    var marker = new google.maps.Marker({
      position: myLatLng,
      map: map,
      title: 'Hello World!'
    });
  }



  $(function(){


  		var canvas = document.getElementById("canvas1");
     var ctx = canvas.getContext("2d");
     ctx.fillStyle = '#fa2e13';
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
  ctx.fillStyle = '#a2d6f9';
  ctx.fillRect(0, 0, 80, 80);
  var canvas = document.getElementById("canvas6");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#d4f145';
  ctx.fillRect(0, 0, 80, 80);
  var canvas = document.getElementById("canvas7");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = '#0983d2';
  ctx.fillRect(0, 0, 80, 80);
  });

  </script>

  <script async defer
  src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFdI5SnLF-CIQ5lRKo_lEqaR6yPN4g7sk&callback=initMap">
  </script>
