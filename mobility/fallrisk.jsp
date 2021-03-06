<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>

<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%


	String test_lat = "";
	String test_lon = "";

   if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
  dbm.createConnection();



  String stab_mean = null;
  String stab_3mean = null;
  String sym_mean = null;
  String sym_3mean = null;
  float sta_index = 0.0f;
  float sym_index = 0.0f;
  int step_index = 0;
  int stride_index = 0;
  double dist_index = 0.0;
  int step_frq_index = 0;
  int step_len_index = 0;
  double spd_index = 0.0;
  String tstamp = "2017-06-01 19:10:04";
  String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + fname + " " + lname + " ";
 tstamp = (String)request.getParameter("date");
    String ssfn = (String)session.getAttribute("ssfn");
	   String ssln = (String)session.getAttribute("ssln");
	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}
String sssn = (String)session.getAttribute("SSSN");
if(request.getParameter("stab_3mean") != null){
  stab_mean = (String) session.getAttribute("stab_mean");
  stab_3mean = (String) session.getAttribute("stab_3mean");
  sym_mean = (String) session.getAttribute("sym_mean");
  sym_3mean = (String) session.getAttribute("sym_3mean");
}else{
  try {
    String sql ="SELECT cast(stab_mean  as decimal(16,2)) as stab_mean , cast(stab_3mean  as decimal(16,2)) as stab_3mean , cast(sym_mean  as decimal(16,2))  as sym_mean, cast(sym_3mean  as decimal(16,2)) as sym_3mean FROM `gait_criterion`";
    ResultSet rs = dbm.executeQuery(sql);
    if (rs.next()){
      stab_mean  = rs.getString("stab_mean");
      stab_3mean  = rs.getString("stab_3mean");
      sym_mean = rs.getString("sym_mean");
      sym_3mean = rs.getString("sym_3mean");
      session.setAttribute("stab_mean",stab_mean);
      session.setAttribute("stab_3mean",stab_3mean);
      session.setAttribute("sym_mean",sym_mean);
      session.setAttribute("sym_3mean",sym_3mean);
    }
    } catch (Exception e) {
      out.println(e.getMessage());
      e.printStackTrace();
    }
  }
  try{
    String sql = "select stab, sym, step,stride, dist,step_frq ,step_len,spd from archive_"+sssn+" where tstamp = '"+tstamp+"'";
    ResultSet rs = dbm.executeQuery(sql);
    if (rs.next()){
      sta_index = rs.getFloat("stab");
      sym_index = rs.getFloat("sym");
      step_index = rs.getInt("step");
      stride_index = rs.getInt("stride");
      dist_index = rs.getDouble("dist");
      step_frq_index = rs.getInt("step_frq");
      step_len_index = rs.getInt("step_len");
      spd_index = rs.getDouble("spd");
    }
    } catch (Exception e) {
      out.println(e.getMessage());
      e.printStackTrace();
    }


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


 		dbm.closeConnection();
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
  <script src="../js/amcharts/amcharts.js"></script>
  <script src="../js/amcharts/xy.js"></script>
  <script src="../js/amcharts/themes/light.js"></script>
  <script src="https://www.amcharts.com/lib/3/gauge.js"></script>
  <script src="../js/bootstrap-notify.min.js"></script>
  <link rel="stylesheet" href="../css/animate.min.css">
        <script type="text/javascript">
		var lat = <%=test_lat%>;
		var lng = <%=test_lon%>;



        var stab_mean = <%=stab_mean%>;
        var stab_3mean = <%=stab_3mean%>;
        var sym_mean = <%=sym_mean%>;
        var sym_3mean = <%=sym_3mean%>;
        stab_mean = parseFloat(stab_mean);
        stab_3mean = parseFloat(stab_3mean);
        sym_mean = parseFloat(sym_mean);
        sym_3mean = parseFloat(sym_3mean);
        var sta_index = <%=sta_index%>;
        var sym_index = <%=sym_index%>;
        var step_index = <%=step_index%>;
        var stride_index = <%=stride_index%>;
        var dist_index = <%=dist_index%>;
        var step_frq_index = <%=step_frq_index%>;
        var step_len_index = <%=step_len_index%>;
        var spd_index = <%=spd_index%>;
        var timegauge = setInterval(setValueInGauge,1);
        console.log("sta_index: " + sta_index);
        console.log("sym_index: " + sym_index);
        console.log("step_index: " + step_index);
        console.log("stride_index: " + stride_index);
        console.log("dist_index: " + dist_index);
        console.log("step_frq_index: " + step_frq_index);
        console.log("step_len_index: " + step_len_index);
        console.log("spd_index: " + spd_index);


window.onload = function() {

	document.getElementById("speed").innerHTML=spd_index;
   document.getElementById("StepAvg").innerHTML=step_frq_index;
   document.getElementById("EstLengh").innerHTML=step_len_index;

}

		if(sta_index == 0 && sym_index == 0 && step_index == 0 && stride_index == 0 && dist_index == 0 && step_frq_index == 0 && step_len_index == 0 && spd_index == 0){
          console.log("no data");
          $.notify({
          	title: '<strong>Unsuccessful</strong>',
          	message: 'Data not found'
          },{
          	type: 'danger'
          });
        }else{
          $.notify({
          	title: '<strong>Successful</strong>',
          	message: ''
          },{
          	type: 'success'
          });
        }

				var gaugeChartSta = AmCharts.makeChart( "chart-sta", {
					"type": "gauge",
					"theme": "light",
					"axes": [ {
						"axisThickness": 1,
						"axisAlpha": 0.2,
						"tickAlpha": 0.2,
						"valueInterval": 0.4,
						"bands": [ {
							"color": "#84b761",
							"endValue": stab_mean,
							"startValue": 0
						}, {
							"color": "#fdd400",
							"endValue": stab_3mean,
							"startValue": stab_mean
						}, {
							"color": "#cc4748",
							"endValue": stab_3mean *2,
							"innerRadius": "95%",
							"startValue":stab_3mean
						} ],
						"bottomText": "0",
						"bottomTextYOffset": 10,
						"endValue": stab_3mean *2,

						"bottomTextFontSize" : 15,

					} ],
					"arrows": [ {} ],
					"export": {
						"enabled": true
					}
				} );




				var gaugeChartSym = AmCharts.makeChart( "chart-sym", {
					"type": "gauge",
					"theme": "light",
					"axes": [ {
						"axisThickness": 1,
						"axisAlpha": 0.2,
						"tickAlpha": 0.2,
				"valueInterval": 0.4,

						"bands": [ {
							"color": "#84b761",
							"endValue": sym_mean,
							"startValue": 0
						}, {
							"color": "#fdd400",
							"endValue": sym_3mean,
							"startValue": sym_mean
						}, {
							"color": "#cc4748",
							"endValue": sym_3mean *2,
							"innerRadius": "95%",
							"startValue": sym_3mean
						} ],
						"bottomText": "0",
						"bottomTextYOffset": 10,
						"endValue": sym_3mean *2,
						"bottomTextFontSize" : 15,

					} ],
					"arrows": [ {} ],
					"export": {
						"enabled": true
					}
				} );


function setValueInGauge(){
  if ( gaugeChartSta ) {
    if ( gaugeChartSta.arrows ) {
      if ( gaugeChartSta.arrows[ 0 ] ) {
        if ( gaugeChartSta.arrows[ 0 ].setValue ) {
          gaugeChartSta.arrows[ 0 ].setValue( sta_index );
          var level;
          if(sta_index> stab_3mean){
            level = "Danger";
          }
          else if(sta_index > stab_mean){
            level = "Warning";
          }else{
            level = "Normal";
          }
          gaugeChartSta.axes[ 0 ].setBottomText(sta_index + "\n\n Stability Level : "+level );
          //console.log("stagauge");
        }
      }
    }
  }
  var level;
  if(sym_index >sym_3mean){
    level = "Dangerous";
  }else if(sym_index > sym_mean){
    level = "Warning";
  }else {
    level = "Normal";
  }
  if ( gaugeChartSym ) {
    if ( gaugeChartSym.arrows ) {
      if ( gaugeChartSym.arrows[ 0 ] ) {
        if ( gaugeChartSym.arrows[ 0 ].setValue ) {
          gaugeChartSym.arrows[ 0 ].setValue( sym_index );
          gaugeChartSym.axes[ 0 ].setBottomText( sym_index + "\n\n Symmetry Level : "+level);
        }
      }
    }
  }
  //clearInterval(timegauge);
}

function randomValue() {

  if ( gaugeChartSta ) {
    if ( gaugeChartSta.arrows ) {
      if ( gaugeChartSta.arrows[ 0 ] ) {
        if ( gaugeChartSta.arrows[ 0 ].setValue ) {
          gaugeChartSta.arrows[ 0 ].setValue( 50 );
          gaugeChartSta.axes[ 0 ].setBottomText( 50 + " km/h" );
        }
      }
    }
  }
}


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



</script>


	<script async defer
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFdI5SnLF-CIQ5lRKo_lEqaR6yPN4g7sk&callback=initMap">
   </script>

  <style media="screen">

  .icon { float:left; margin-right:10px; }

    .chart { width:100%; height:300px; }
    #map {
          position: relative;
          width: 100%;
          height: 45vh;
          margin: 0;
          padding: 0;
      }

  </style>
  <body>
<%@include file="../include/nav.jsp"%>



  <div class="container">
  <div class="panel" style="margin-left:15px;margin-right:15px;"><font class="fs17">Fall History<span class="right"><%=name%></span></font></div>

  <div class="row">

    <div id="tab0default" class="tab-pane fade in active">
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="margin-left:5px;margin-right:5px;">
						<div id="map" style="height:300px;"></div>
                    </div>
                </div>
				<div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img src="https://image.flaticon.com/icons/svg/148/148976.svg" width="30" height="30"></div>
                        <div class="fs20">Date : <font id="date"> <%=tstamp%></font></div>
                    </div>
                </div>
				<div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                        <div class="icon"><img style="" src="https://image.flaticon.com/icons/svg/149/149060.svg" width="30" height="30" ></div>
                        <div class="fs20">Location : <font id="location"><script>getLocation('<%=test_lat%>','<%=test_lon%>');</script></font></div>
                    </div>
                </div>
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
						<div class="icon"><img style="" src="../images/icons/marker.png" width="30" height="30" ></div>
						<div class="fs20">AVG Speed : <font id="speed"></font> m/s</div>
                    </div>
                </div>
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
						<div class="icon"><img style="" src="../images/icons/walk.png" width="30" height="30" ></div>
						<div class="fs20">AVG step frequency : <font id="StepAvg"></font> steps/s</div>
                    </div>
                </div>
                <div class="col-md-6 col-xs-12">
                    <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
						<div class="icon"><img style="" src="../images/icons/step_length.png" width="30" height="30" ></div>
						<div class="fs20">Estimated step lengh : <font id="EstLengh"></font> CM.</div>
                    </div>
                </div>
              </div>
            </div>

    <div class="row" style="margin-left:0px;margin-right:0px;">
      <div class="col-md-12 col-xs-12">
        <div class="panel" style="margin-left:0px;margin-right:0px;">
          <div class="row" style="margin-left:0px;margin-right:0px;">
            <div class="col-md-6 col-xs-12">
              <div class="fs20 text-primary text-center" style="margin-top: 10px">Stability Index</div>
              <div id="chart-sta" class="chart" width="400px"></div>
            </div>
            <div class="col-md-6 col-xs-12">
              <div class="fs20 text-primary text-center" style="margin-top: 10px">Symmetry Index</div>
              <div id="chart-sym" class="chart" width="400px" ></div>
            </div>
          </div>
        </div>
      </div>
    </div>



          </div>


        </body>
