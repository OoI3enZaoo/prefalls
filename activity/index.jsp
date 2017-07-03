<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@include file="config.jsp"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.GregorianCalendar" %>
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

	int sleep = 0;
	int stationary = 0;
	int active = 0;
	int hactive = 0;

	int lsleep = 0;
	int lstationary = 0;
	int lactive = 0;
	int lhactive = 0;

	int sstep = 0;
	double sdistance = 0.0;
	double scalories = 0.0;
	int sismobile = 0;
  double sta_index = 0.0;
  double sym_index = 0.0;

  int step_index = 0;
  int stride_index = 0;
  double dist_index = 0.0;
  int step_frq_index = 0;
  int step_len_index = 0;
  double spd_index = 0.0;


  float stab_mean = 0.0f;
  float stab_3mean = 0.0f;
  float sym_mean = 0.0f;
  float sym_3mean = 0.0f;


	String acttype = "\'{\"activity\": [";
	String activity = "\'{\"allactivity\": [";

    String sssn = (String)session.getAttribute("SSSN");
	String name = "";
  Calendar c = Calendar.getInstance();
	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	String currentDate = df.format(c.getTime());

  SimpleDateFormat df2 = new SimpleDateFormat("yyyy-MM-dd");
	String currentDate2 = df2.format(c.getTime());




  String fall_history_json = "\'{\"falling\": [";
  Double last_lat = 0.0d;
  Double last_lon = 0.0d;


    try {
        String sql = "SELECT firstname,lastname FROM `patients` WHERE SSSN = '"+sssn+"';";
        ResultSet rs = dbm.executeQuery(sql);

        if (rs.next()){

            name = "\'" + rs.getString("firstname") + " " + rs.getString("lastname") + "\'";
            session.setAttribute("fname",rs.getString("firstname"));
            session.setAttribute("lname",rs.getString("lastname"));
		}

        } catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

	try {
		String sql = "SELECT act_group, COUNT(*) * " + String.valueOf(msgInterval) + "  AS SEC, MAX(long_sleep) AS LSLEEP, MAX(long_stationary) AS LSTATIONARY, MAX(long_active) AS LACTIVE, MAX(long_hactive) AS LHACTIVE FROM actgroup a, archive_" + sssn + " b WHERE (a.group_id = b.act_group) AND (DATE(tstamp) = CURRENT_DATE()) GROUP BY act_group;";
		ResultSet rs = dbm.executeQuery(sql);

		while((rs!=null) && (rs.next())){
			switch (rs.getInt("act_group")){
				case 1:
					sleep = rs.getInt("SEC");
					lsleep = rs.getInt("LSLEEP");
					break;
				case 2:
					stationary = rs.getInt("SEC");
					lstationary = rs.getInt("LSTATIONARY");
					break;
				case 3:
					active = rs.getInt("SEC");
					lactive = rs.getInt("LACTIVE");
					break;
				case 4:
					hactive = rs.getInt("SEC");
					lhactive = rs.getInt("LHACTIVE");
					break;
				default:
					out.println("Error case !!!");
			}
		}

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

	try {
		String sql = "SELECT SUM(step) AS SSTEP, SUM(calories) AS SCALORIES, SUM(ismobile) AS SISMOBILE, SUM(dist) AS SDISTANCE FROM archive_" + sssn + " WHERE (DATE(tstamp) = CURRENT_DATE());";
		ResultSet rs = dbm.executeQuery(sql);

		if (rs.next()){
			sstep = rs.getInt("SSTEP");
			scalories = rs.getDouble("SCALORIES");
			sismobile = rs.getInt("SISMOBILE");
			sdistance = rs.getDouble("SDISTANCE");
		}

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

	try {
		String sql = "SELECT act_type, act_name, group_name FROM acttype a, actgroup b WHERE (a.group_id = b.group_id);";
		ResultSet rs = dbm.executeQuery(sql);
		if (rs.next()){
			acttype = acttype + "{\"act_type\":\"" + rs.getInt("act_type") + "\" , \"act_name\":\"" + rs.getString("act_name") + "\", \"group_name\": \"" + rs.getString("group_name") + "\"}";
		}
		while(rs.next()){
			acttype = acttype + ", {\"act_type\":\"" + rs.getInt("act_type") + "\" , \"act_name\":\"" + rs.getString("act_name") + "\", \"group_name\": \"" + rs.getString("group_name") + "\"}";
		}
		acttype = acttype + "]}\'";
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

	try {
		String sql = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, act_type FROM archive_" + sssn + " WHERE (DATE(tstamp) = CURRENT_DATE());";
		ResultSet rs = dbm.executeQuery(sql);
		if (rs.next()){
			activity = activity + "{\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"act_type\":\"" + rs.getInt("act_type") + "\"}";
		}
		while(rs.next()){
			activity = activity + ", {\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"act_type\":\"" + rs.getInt("act_type") + "\"}";
		}
		activity = activity + "]}\'";
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}


    try {
  		String sql = "SELECT SUM(step) as StepCount ,SUM(dist) as Distance ,SUM(stride)  as StrideCount ,AVG(step_frq) as step_frq ,AVG(step_len) as step_len ,AVG(spd) as spd FROM archive_" + sssn +" where tstamp like '" + currentDate2 + "%'";
  		ResultSet rs = dbm.executeQuery(sql);

  		if (rs.next()){
  			step_index  = rs.getInt("StepCount");
  			stride_index  = rs.getInt("StrideCount");
        dist_index = rs.getDouble("Distance");
        step_frq_index = rs.getInt("step_frq");
        step_len_index = rs.getInt("step_len");
        spd_index = rs.getDouble("spd");

  		}

  		} catch (Exception e) {
  			out.println(e.getMessage());
  			e.printStackTrace();
  		}


        try {
          String sql ="SELECT cast(stab_mean  as decimal(16,2)) as stab_mean , cast(stab_3mean  as decimal(16,2)) as stab_3mean , cast(sym_mean  as decimal(16,2))  as sym_mean, cast(sym_3mean  as decimal(16,2)) as sym_3mean FROM `gait_criterion`";
          ResultSet rs = dbm.executeQuery(sql);

          if (rs.next()){

            stab_mean  = rs.getFloat("stab_mean");
            stab_3mean  = rs.getFloat("stab_3mean");
            sym_mean = rs.getFloat("sym_mean");
            sym_3mean = rs.getFloat("sym_3mean");



            session.setAttribute("stab_mean",stab_mean);
            session.setAttribute("stab_3mean",stab_3mean);
            session.setAttribute("sym_mean",sym_mean);
            session.setAttribute("sym_3mean",sym_3mean);

          }

          } catch (Exception e) {
            out.println(e.getMessage());
            e.printStackTrace();
          }
          try {
			//String sql = "SELECT tstamp , hr , act_type FROM archive_RFG2D3T6ET WHERE tstamp BETWEEN SUBTIME('2017-06-18 01:35:14' , '1:00:00') AND '2017-06-18 01:35:14'"
            String sql = "SELECT tstamp , hr , act_type FROM archive_"+sssn+" WHERE tstamp BETWEEN SUBTIME('"+currentDate+"' , '1:00:00') AND '"+currentDate+"' order by tstamp";

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


		try {
  		String sql = "SELECT lat , lon FROM alerts WHERE SSSN = '"+sssn+"' ORDER BY id DESC LIMIT 1";
  		ResultSet rs = dbm.executeQuery(sql);

  		if (rs.next()){
			last_lat = rs.getDouble("lat");
			last_lon = rs.getDouble("lon");

  		}

  		} catch (Exception e) {
  			out.println(e.getMessage());
  			e.printStackTrace();
  		}
		//out.println(last_lat +" "+last_lon);
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
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>
<script src="../js/amcharts/amcharts.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/serial.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/gantt.js"></script>
<script src="../bower_components/amcharts/dist/amcharts/plugins/export/export.min.js"></script>
<link rel="stylesheet" href="../bower_components/amcharts/dist/amcharts/plugins/export/export.css" type="text/css" media="all" />
<script src="../js/amcharts/pie.js"></script>
<script src="../js/amcharts/xy.js"></script>
<script src="../js/amcharts/themes/light.js"></script>
<script src="https://www.amcharts.com/lib/3/gauge.js"></script>
<script src="../js/bootstrap-notify.min.js"></script>
<link rel="stylesheet" href="../css/animate.min.css">
  <script type="text/javascript" src="../js/moment.min.js"></script>




<script type="text/javascript">

  var i_realtime =1;
  var message_act;
  var message_ts;
  var message_hr;
  var message_lat;
  var message_lon;
  var fall_history = <%=fall_history_json%>;
  var json_fall_history = JSON.parse(fall_history);



	var msgInterval = <%=msgInterval%>;
	var actgroup = 0;
	var hr = 0;
	var sstep = <%=sstep%>;
	var scalories = <%=scalories%>;
	var sleep = <%=sleep%>;
	var stationary = <%=stationary%>;
	var active = <%=active%>;
	var hactive = <%=hactive%>;
	var sismobile = <%=sismobile%>;
	var sdistance = <%=sdistance%>;
  var sta_index = <%=sta_index%>;
  var sym_index = <%=sym_index%>;
  var step_index = <%=step_index%>;
  var stride_index = <%=stride_index%>;
  var dist_index = <%=dist_index%>;
  var step_frq_index = <%=step_frq_index%>;
  var step_len_index = <%=step_len_index%>;
  var spd_index = <%=spd_index%>;
  var stab_mean = <%=stab_mean%>;
  var stab_3mean = <%=stab_3mean%>;
  var sym_mean = <%=sym_mean%>;
  var sym_3mean = <%=sym_3mean%>;
  var last_lat =<%=last_lat%>;
  var last_lon =<%=last_lon%>;
  var infoWindow;

  var noti_stab = false
  var noti_sym = false;
  var alert_sta = 0;
  var checksta = 0;
    var color_text ="";
  var sta_interval1;
  var sta_interval2;

  var alert_sym = 0;
  var checksym = 0;
  var sym_interval1;
  var sym_interval2;
  var countalertsta = 0;
  var countalertsym = 0;
	//alert("sismobile: " + sismobile);
	var mobilityIdx = Math.round((((sismobile * msgInterval)/864) + 0.00001) * 100) / 100;
	//alert("Mobility: " + mobilityIdx);
	var notAvail = 86400 - sleep - stationary - active - hactive;

	var lsleep = <%=lsleep%>;
	var lstationary = <%=lstationary%>;
	var lactive = <%=lactive%>;
	var lhactive = <%=lhactive%>;
	var d = new Date();
	var curdate = d.toDateString();
	var actString = <%=acttype%>;
	var acttype = JSON.parse(actString);
	var curact = "Not Available";
	var name = <%=name%>;

	var allact = JSON.parse(<%=activity%>);
	//var chartActivityDetail = [];

	//Chart2
	var startDate = new Date();

	startDate.setHours(0);
	startDate.setMinutes(0);
	startDate.setSeconds(0);
	var endDate = new Date();
	endDate.setHours(23);
	endDate.setMinutes(59);
	endDate.setSeconds(59);

	/*
	var chart2 = AmCharts.makeChart("chartdiv2", {
              "type": "xy",
			  "theme": "light",
			  "dataDateFormat": "YYYY-MM-DD",
              "startDuration": 0,
              "trendLines": [],
              "graphs": [
                {
                  "balloonText": "x:<b>[[x]]</b> y:<b>[[y]]</b><br>value:<b>[[value]]</b>",
                  "bullet": "round",
                  "id": "AmGraph-1",
                  "lineAlpha": 0,
                  "lineColor": "#b0de09",
                  "valueField": "value",
                  "xField": "time",
                  "yField": "acttype"
                }
              ],
              "guides": [],
              "valueAxes": [
                {
                  "id": "ValueAxis-1",
                  "axisAlpha": 0,
				  "labelFunction": formatValue
                }, {
				 "id": "ValueAxis-2",
				 "axisAlpha": 0,
				 "position": "bottom",
				 "type": "date",
				 "minimumDate": startDate,
				 "maximumDate": endDate
				}
              ],
              "allLabels": [],
              "balloon": {},
              "titles": [],
              "chartScrollbar":{},
              "dataProvider": []
            });
	*/

var bottomTextSta;
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
        "endValue": <%=stab_mean%>,
        "startValue": 0
      }, {
        "color": "#fdd400",
        "endValue": <%=stab_3mean%>,
        "startValue": <%=stab_mean%>
      }, {
        "color": "#cc4748",
        "endValue": <%=stab_3mean *2 %>,
        "innerRadius": "95%",
        "startValue":<%=stab_3mean%>
      } ],
      "bottomText": "0",
      "bottomTextYOffset": 10,
      "endValue": <%=stab_3mean *2 %>,

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
        "endValue": <%=sym_mean%>,
        "startValue": 0
      }, {
        "color": "#fdd400",
        "endValue": <%=sym_3mean%>,
        "startValue": <%=sym_mean%>
      }, {
        "color": "#cc4748",
        "endValue": <%=sym_3mean *2%>,
        "innerRadius": "95%",
        "startValue": <%=sym_3mean%>
      } ],
      "bottomText": "0",
      "bottomTextYOffset": 10,
      "endValue": <%=sym_3mean *2%>,
      "bottomTextFontSize" : 15,

    } ],
    "arrows": [ {} ],
    "export": {
      "enabled": true
    }
  } );


	var chart2 = AmCharts.makeChart("chartdiv2", {
              "type": "xy",
			  "theme": "light",
              "startDuration": 0,
              "trendLines": [],
              "graphs": [
                {
                  "balloonText": "x:<b>[[x]]</b> y:<b>[[y]]</b><br>value:<b>[[value]]</b>",
                  "bullet": "square",
				  "bulletSize": 0,
                  "id": "AmGraph-1",
                  "lineAlpha": 0,
                  "lineColor": "#b0de09",
                  "bulletSizeField": "value",
                  "xField": "time",
                  "yField": "acttype"
                }
              ],
              "guides": [],
              "valueAxes": [
                {
                  "id": "ValueAxis-1",
                  "axisAlpha": 0,
				  "labelFunction": formatValue
                }, {
				 "id": "ValueAxis-2",
				 "axisAlpha": 0,
				 "position": "bottom",
				 "labelFunction": formatTimeAxis
				}
              ],
              "allLabels": [],
              "balloon": {},
              "titles": [],
              "chartScrollbar":{},
              "dataProvider": []
            });

	//Initialize Data for chart 2
	/*
	for (var i = 0; i < allact.allactivity.length; i++) {
		chart2.dataProvider.push({"time": new Date(parseInt(allact.allactivity[i].timestamp)), "acttype": parseInt(allact.allactivity[i].act_type), "value": 1});
		chart2.validateData();
	}
	*/




	for (var i = 0; i < allact.allactivity.length; i++) {
		chart2.dataProvider.push({"time": parseInt(allact.allactivity[i].timestamp), "acttype": parseInt(allact.allactivity[i].act_type), "value": 1});
		chart2.validateData();
	}

	function init(){
		document.getElementById("curdate").innerHTML = curdate;
		document.getElementById("curact").innerHTML = curact;
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

    updateChart_FallRisk();
		updateChart_ActivityDetail();
	}

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
		   d = new Date(parseInt(message.getAttribute('ts')));
		   curdate = d.toDateString();

		   //End of day reset
		   if (notAvail <= 0){
				mobilityIdx = 0.0;
				sstep = 0;
				scalories = 0.0;
				sleep = 0;
				stationary = 0;
				active = 0;
				hactive = 0;
				lsleep = 0;
				lstationary = 0;
				lactive = 0;
				lhactive = 0;
				sismobile = 0;
				sdistance = 0.0;
		   }

       hr = message.getAttribute('hr');
		   sstep = sstep + parseInt(message.getAttribute('step'));
		   scalories = scalories + parseFloat(message.getAttribute('cal'));
		   actgroup = parseInt(message.getAttribute('act_group'));
		   sdistance = sdistance + parseFloat(message.getAttribute('dist'));
       sta_index = parseFloat(message.getAttribute("stab"));
       sym_index = parseFloat(message.getAttribute("sym"));
    message_act = parseInt(message.getAttribute("act_type"));
	message_hr = parseInt(message.getAttribute("hr"));
	message_ts = moment(parseInt(message.getAttribute("ts"))).format("YYYY-MM-DD HH:mm:ss");
	message_lat = parseFloat(message.getAttribute("lat"));
	message_lon = parseFloat(message.getAttribute("lon"));

 step_index += parseInt(message.getAttribute("step"))
stride_index  += parseInt(message.getAttribute("stride"))
spd_index = parseFloat(message.getAttribute("spd"))
step_frq_index = parseFloat(message.getAttribute("step_frq"))
step_len_index = parseFloat(message.getAttribute("step_len"))
dist_index += parseFloat(message.getAttribute("dist"))


       console.log("sta_index: " + sta_index);
 console.log("sym_index: " + sym_index);
		   for (var i = 0; i < acttype.activity.length; i++) {
				if (parseInt(message.getAttribute('act_type')) == parseInt(acttype.activity[i].act_type)){
					//curact = acttype.activity[i].act_name;
					curact = acttype.activity[i].group_name;
					break;
				}
		   }

		   if (message.getAttribute('ismobile') == "true"){
				sismobile++;
		   }
		   switch (actgroup){
				case 1:
					sleep = sleep + msgInterval;
					if (parseInt(message.getAttribute('long_sleep')) > lsleep){
						lsleep = parseInt(message.getAttribute('long_sleep'));
					}
					break;
				case 2:
					stationary = stationary + msgInterval;
					if (parseInt(message.getAttribute('long_stationary')) > lstationary){
						lstationary = parseInt(message.getAttribute('long_stationary'));
					}
					break;
				case 3:
					active = active + msgInterval;
					if (parseInt(message.getAttribute('long_active')) > lactive){
						lactive = parseInt(message.getAttribute('long_active'));
					}
					break;
				case 4:
					hactive = hactive + msgInterval;
					if (parseInt(message.getAttribute('long_hactive')) > lhactive){
						lhactive = parseInt(message.getAttribute('long_hactive'));
					}
					break;
		   }
		   notAvail = 86400 - sleep - stationary - active - hactive;

		   var nd = parseInt(message.getAttribute('ts'));
		   chart2.dataProvider.push({"time": nd, "acttype": parseInt(message.getAttribute('act_type')), "value": 1});
		   updateChart_ActivityDetail();
       updateChart_FallRisk();


    	if(message_act == 2){color_text = "#C0C0C0"}
    			else if(message_act == 1){color_text = "#e98529";}
    			else if(message_act == 3){color_text = "#d4f145";}
    			else if(message_act == 4){color_text = "#5bda47";}
    			else if(message_act == 5){color_text = "#003300";}
    			else if(message_act == 8 || message_act == 7){color_text = "#0983d2";}
    			else if(message_act == 6){color_text = "#e448e7";}

    	//console.log(date_test);
    	//console.log(heartrate_random);
    	//console.log(color_text);

    	/*console.log("show real time message_act = " + message_act);
    	console.log("show real time message_hr = " + message_hr);
    	console.log("show real time message_ts = " + message_ts);*/

    	chart_realtime.dataProvider.push( {

    	lineColor: color_text,
    	date: message_ts,
    	heartrate: message_hr

    	} );
    	chart_realtime.validateData();


      checkAlert(0);

        //MoveMarker
        marker.setPosition( new google.maps.LatLng( message_lat, message_lon ) );
        map.panTo( new google.maps.LatLng( message_lat, message_lon) );
        var contentString =
			'<h1>Info Patient</h1>'+
			'<b class="infotext" >Patient Name : </b><p id="patient_name">'+name+'</p>'+
			'<b class="infotext" >Stability index : </b><p id="sta">'+sta_index+'</p>'+
			'<b class="infotext" >Symmetry index : </b><p id="sym">'+sym_index+'</p>'+
			'<b class="infotext" >AVG speed : </b><p id="avg_spd">'+spd_index+'</p>'+
			'<b class="infotext" >last time : </b><p id="last_time">'+message_ts+'</p>';

        infoWindow.setContent(contentString);
		infoWindow.open(map,marker);

        },
        myId: 'test0',
        myDestination: 'topic://<%=sssn%>_pred'
      };

	amq.addListener(myHandler.myId, myHandler.myDestination,myHandler.rcvMessage);



  var myHandler2 =
      {
        rcvMessage: function(message)
        {
            alert_type = message.getAttribute("type");
            console.log("alert_type: " + alert_type);
            // if(alert_type == 3 || alert_type == 4 || alert_type == 8 || alert_type == 9){
            //
            //
            // }
            checkAlert(alert_type);
              // var type = alert_type;
              // var mType  = '';
              // var mMessage = '';
              // if(type == 3 || type == 8){
              // 	mType= "<strong>Warning</strong>";
              //
              // }
              //
              // if(type == 9 || type == 4 || type == 7){
              // 	mType= "<strong>Danger</strong>";
              // }
              // if(type == 3){
              //   noti_stab = true;
              //   mMessage = "Stability index warning !";
              // }
              // if(type == 4){
              //   noti_stab = true;
              //   mMessage = "Stability index danger !";
              // }
              // if(type == 8){
              //   noti_sym = true;
              // 	mMessage = "Symmetry index warning !";
              // }
              // if(type == 9){
              //   noti_sym = true;
              // 	mMessage = "Symmetry index danger !";
              // }
              //
              // if(type == 7){
              // 	mMessage = "Fall is detected !";
              // }
              //
              //   $.notify({
              //   // options
              //     icon: "glyphicon glyphicon-bell",
              //     message: mType + ' ' + mMessage
              //   },{
              //   // settings
              //       type: 'warning'
              //   });
              //
              //   if(noti_stab == true){
              //     setInterval(function(){
              //         $("#chart-sta").css("background-color","#edf0bf");
              //     },5000);
              //
              //   }
              //





        },
        myId: 'test1',
        myDestination: 'topic://<%=sssn%>_alert'
      };

  amq.addListener(myHandler2.myId, myHandler2.myDestination,myHandler2.rcvMessage);




	//xxxxxxxxxxxxxxxx create chart xxxxxxxxxxxxxxxxxx
	var chart = AmCharts.makeChart( "chartdiv", {
	  "type": "pie",
	  "pullOutRadius": 0,
	  "theme": "light",

	  "allLabels": [{
        "text": "Mobility Index",
		"size": 25,
        "align": "center",
        "bold": true,
        "y": 220
    },{
        "text": mobilityIdx + " %",
		"size": 20,
        "align": "center",
        "bold": false,
        "y": 250
    }],
      "colors" : ["#2f4074", "#ea5f5c", "#f57a3e", "#2d904f", "#f1f1f1"
	  ],
	  "dataProvider": [ {
		"title": "Sleep",
		"value": Math.round(((sleep/864) + 0.00001) * 100) / 100
	  },{
		"title": "Stationary",
		"value": Math.round(((stationary/864) + 0.00001) * 100) / 100
	  },{
		"title": "Active",
		"value": Math.round(((active/864) + 0.00001) * 100) / 100
	  },{
		"title": "Highly Active",
		"value": Math.round(((hactive/864) + 0.00001) * 100) / 100
	  },{
		"title": "Not Available",
		"value": Math.round(((notAvail/864) + 0.00001) * 100) / 100
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

	function formatValue(value, formattedValue, valueAxis){
		var actvalue = "";
    	for (var i = 0; i < acttype.activity.length; i++) {
			if (value == parseInt(acttype.activity[i].act_type)){
				actvalue = acttype.activity[i].act_name;
				break;
			}
		}
		return actvalue;
	}

	function formatTimeAxis(value, formattedValue, valueAxis){
		var timevalue = new Date(value);
		return (timevalue.toTimeString()).substr(0, 5);
	}


function checkAlert(type) {

  console.log("alerttype: " + type);
  if(type == 7){
    $.notify({
      // options
      icon: "glyphicon glyphicon-bell",
      message: '<strong>danger</strong> Fall is detected !'
    },{
      // settings
      type: 'danger'
    });

  }
  if(sta_index > stab_mean) {
        if(type == 3 && alert_sta != 1){
          alert_sta = 1;
          console.log("do alert 3 alert_sta: " + alert_sta);
          clearInterval(sta_interval2);
          sta_interval1 =   setInterval(function(){
            if(checksta == 0){
                $("#chart-sta").css("background-color","#fff");
                checksta = 1;
            }else{
                $("#chart-sta").css("background-color","#edf0bf");
                checksta = 0;
            }
            countalertsta ++;
            if(countalertsta == 7){
              $.notify({
                // options
                icon: "glyphicon glyphicon-bell",
                message: '<strong>Stability index reaches warning level</strong> '
              },{
                // settings
                type: 'warning'
              });
              countalertsta = 0;
            }

            // if(countalertsta == 30){
            //   clearInterval(sta_interval1);
            //   countalertsta = 0;
            // }


          },1000);
      }
      else if(type == 4 && alert_sta != 2){
        alert_sta = 2;
        console.log("do alert 4 alert_sta: " + alert_sta);
        clearInterval(sta_interval1);
        sta_interval2 =   setInterval(function(){
          if(checksta == 0){
              $("#chart-sta").css("background-color","#fff");
              checksta = 1;
          }else{
              $("#chart-sta").css("background-color","#f0c2bf");
              checksta = 0;
          }
          countalertsta ++;
         if(countalertsta == 7){
            $.notify({
              // options
              icon: "glyphicon glyphicon-bell",
              message: '<strong>Stability index reaches danger level</strong>'
            },{
              // settings
              type: 'danger'
            });
            countalertsta = 0;
            }


        },1000);
      }

}else{
  alert_sta = 0;
  clearInterval(sta_interval1);
  clearInterval(sta_interval2);
  $("#chart-sta").css("background-color","#fff");
  $("#chart-sym").css("background-color","#fff");
  checksta = 1;
}

console.log("Symindex " + sym_index + " symmean" + sym_mean);
  if(sym_index > sym_mean) {
      if(type == 8 && alert_sym != 1){
        alert_sym = 1;
        console.log("do alert 8 alert_sym: " + alert_sym);
        clearInterval(sym_interval2);
        sym_interval1 =   setInterval(function(){
          if(checksym == 0){
              $("#chart-sym").css("background-color","#fff");
              checksym = 1;
          }else{
              $("#chart-sym").css("background-color","#edf0bf");
              checksym = 0;
          }

          countalertsym ++;
          if(countalertsym == 7){
            $.notify({
              // options
              icon: "glyphicon glyphicon-bell",
              message: '<strong>Symmetry index reaches warning level</strong>'
            },{
              // settings
              type: 'warning'
            });
            countalertsym = 0;
         }


        },1000);
      }
      else if(type == 9 && alert_sym != 2){
      alert_sym = 2;
      console.log("do alert 9 alert_sym: " + alert_sym);
      clearInterval(sym_interval1);
      sym_interval2 =   setInterval(function(){
        if(checksym == 0){
            $("#chart-sym").css("background-color","#fff");
            checksym = 1;
        }else{
            $("#chart-sym").css("background-color","#f0c2bf");
            checksym = 0;
        }
        countalertsym ++;
        if(countalertsym == 7){
          $.notify({
            // options
            icon: "glyphicon glyphicon-bell",
            message: '<strong>Symmetry index reaches danger level</strong>'
          },{
            // settings
            type: 'danger'
          });
          countalertsym = 0;
        }


      },1000);
      }
}else{
  alert_sym = 0;
  $("#chart-sta").css("background-color","#fff");
  $("#chart-sym").css("background-color","#fff");
  checksym = 1;
  clearInterval(sym_interval1);
  clearInterval(sym_interval2);
}


      //
      //   if(alert_sym == true){
      //
      //     sym_interval =   setInterval(function(){
      //       if(checksym == 0){
      //           $("#chart-sym").css("background-color","#fff");
      //           checksym = 1;
      //       }else{
      //           $("#chart-sym").css("background-color",color_sym);
      //           checksym =0;
      //       }
      //     },1000);
      // }



}


function updateChart_FallRisk(){
  document.getElementById("StepCount").innerHTML=step_index;
  document.getElementById("StrideCount").innerHTML=stride_index;
  document.getElementById("Speed").innerHTML=spd_index.toFixed(2);
  document.getElementById("StepLength").innerHTML=step_len_index.toFixed(2);
  document.getElementById("StepAvg").innerHTML=step_frq_index;
  document.getElementById("Distance").innerHTML = dist_index.toFixed(2);

// console.log("StepCount: " + StepCount);
// console.log("StrideCount: " + StrideCount);
// console.log("Distance: " + Distance);

//console.log("sta_index: " + sta_index + " typeof: " + typeof sta_index);
//console.log("sym_index: " + sym_index)+ " typeof: " + typeof sym_index;


    if ( gaugeChartSta ) {
      if ( gaugeChartSta.arrows ) {
        if ( gaugeChartSta.arrows[ 0 ] ) {
          if ( gaugeChartSta.arrows[ 0 ].setValue ) {
            if(sta_index > stab_3mean*2){
                   gaugeChartSta.arrows[ 0 ].setValue( stab_3mean*2 );
              }else{
                 gaugeChartSta.arrows[ 0 ].setValue( sta_index );
              }
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
              if(sym_index > sym_3mean*2){
                  gaugeChartSym.arrows[ 0 ].setValue( sym_index *2);
              }else{
                gaugeChartSym.arrows[ 0 ].setValue( sym_index );
              }
            gaugeChartSym.axes[ 0 ].setBottomText( sym_index + "\n\n Symmetry Level : "+level);

          }
        }
      }
    }


}
	function updateChart_ActivityDetail(){
		var chartData = [];
		var chartMobility = [];
		mobilityIdx = Math.round((((sismobile * msgInterval)/864) + 0.00001) * 100) / 100;
		chartData.push({"title": "Sleep","value": Math.round(((sleep/864) + 0.00001) * 100) / 100});
		chartData.push({"title": "Stationary","value": Math.round(((stationary/864) + 0.00001) * 100) / 100});
		chartData.push({"title": "Active","value": Math.round(((active/864) + 0.00001) * 100) / 100});
		chartData.push({"title": "Highly Active","value": Math.round(((hactive/864) + 0.00001) * 100) / 100});
		chartData.push({"title": "Not Available","value": Math.round(((notAvail/864) + 0.00001) * 100) / 100});
		chart.dataProvider = chartData;
		chartMobility.push({"text": "Mobility Index", "size": 25, "align": "center", "bold": true, "y": 220});
		chartMobility.push({"text": mobilityIdx + " %", "size": 20, "align": "center", "bold": false, "y": 250});
		chart.allLabels = chartMobility;
		chart.validateData();

		document.getElementById("curact").innerHTML = curact;
		document.getElementById("curdate").innerHTML = curdate;
		document.getElementById("hr").innerHTML = Math.round(hr);
		document.getElementById("steps").innerHTML = numberWithCommas(sstep);
		document.getElementById("dist").innerHTML = numberWithCommas(Math.round(sdistance * 100)/100);
		document.getElementById("cal").innerHTML = Math.round(scalories * 100)/100;
		document.getElementById("sleep").innerHTML = showTime(sleep);
		document.getElementById("lsleep").innerHTML = showTime(lsleep);
		document.getElementById("stationary").innerHTML = showTime(stationary);
		document.getElementById("lstationary").innerHTML = showTime(lstationary);
		document.getElementById("active").innerHTML = showTime(active);
		document.getElementById("lactive").innerHTML = showTime(lactive);
		document.getElementById("highlyactive").innerHTML = showTime(hactive);
		document.getElementById("lhighlyactive").innerHTML = showTime(lhactive);

		//chart2.dataProvider = chartActivityDetail;
		chart2.validateData();

		document.getElementById("patient").innerHTML = "Patient Name : " + name;

		//alert(chartActivityDetail.length);
		//alert(chartActivityDetail[0].time + " " + chartActivityDetail[0].acttype + " " +  chartActivityDetail[0].value);
	}


	function numberWithCommas(num) {
		var parts = num.toString().split(".");
		parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		return parts.join(".");
	}

	function showTime(sec){
		var hour = 0;
		var min = 0;
		var second = sec;
		var out = "";
		hour = Math.floor(second/3600);
		second = second % 3600;
		min = Math.floor(second/60);
		second = second % 60;
		if (hour > 0){
			out = out + hour + " h ";
		}
		if (min > 0){
			out = out + min + " m ";
		}
		out = out + second + " s";
		return out;
	}



  	function Generator_Activity() {
      var Data = [];
  	var color_code = "";

      for (var i = 0; i < json_fall_history.falling.length; i++) {

  				if(parseInt(json_fall_history.falling[i].act) == 2){color_code = "#C0C0C0";}
  				else if(parseInt(json_fall_history.falling[i].act) == 1){color_code = "#e98529";}
  				else if(parseInt(json_fall_history.falling[i].act) == 3){color_code = "#d4f145";}
  				else if(parseInt(json_fall_history.falling[i].act) == 4){color_code = "#5bda47";}
  				else if(parseInt(json_fall_history.falling[i].act) == 5){color_code = "#003300";}
  				else if(parseInt(json_fall_history.falling[i].act) == 8 || parseInt(json_fall_history.falling[i].act) == 7){color_code = "#0983d2";}
  				else if(parseInt(json_fall_history.falling[i].act) == 6){color_code = "#e448e7";}


  				console.log("show data json act = " + json_fall_history.falling[i].act);
  				console.log("show data json start = " + json_fall_history.falling[i].start);
  				console.log("show data json hr = " + json_fall_history.falling[i].value);

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




    var map;
	var marker;



function initMap() {
   var myLatLng = {lat:last_lat, lng: last_lon};

	  map = new google.maps.Map(document.getElementById('map'),  {
      zoom: 16,
      center: myLatLng

    });

    marker = new google.maps.Marker({
      position: myLatLng,
      map: map
    });


	infoWindow = new google.maps.InfoWindow();



	marker.setMap( map );



  setInterval(function(){
    google.maps.event.trigger(map, 'resize');
  },300)

}

/*

  function initMap() {
        var uluru = {lat: -25.363, lng: 131.044};
        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 4,
          center: uluru
        });

        var contentString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">Uluru</h1>'+
            '<div id="bodyContent">'+
            '<p><b>Uluru</b>, also referred to as <b>Ayers Rock</b>, is a large ' +
            'sandstone rock formation in the southern part of the '+
            'Northern Territory, central Australia. It lies 335&#160;km (208&#160;mi) '+
            'south west of the nearest large town, Alice Springs; 450&#160;km '+
            '(280&#160;mi) by road. Kata Tjuta and Uluru are the two major '+
            'features of the Uluru - Kata Tjuta National Park. Uluru is '+
            'sacred to the Pitjantjatjara and Yankunytjatjara, the '+
            'Aboriginal people of the area. It has many springs, waterholes, '+
            'rock caves and ancient paintings. Uluru is listed as a World '+
            'Heritage Site.</p>'+
            '<p>Attribution: Uluru, <a href="https://en.wikipedia.org/w/index.php?title=Uluru&oldid=297882194">'+
            'https://en.wikipedia.org/w/index.php?title=Uluru</a> '+
            '(last visited June 22, 2009).</p>'+
            '</div>'+
            '</div>';

        var infowindow = new google.maps.InfoWindow({
          content: contentString
        });

        var marker = new google.maps.Marker({
          position: uluru,
          map: map,
          title: 'Uluru (Ayers Rock)'
        });
        marker.addListener('click', function() {
          infowindow.open(map, marker);
        });


  setInterval(function(){
    google.maps.event.trigger(map, 'resize');
  },300)
      }
*/
/*function moveMarker( map, marker ) {

        marker.setPosition( new google.maps.LatLng( message_lat, message_lon ) );
        map.panTo( new google.maps.LatLng( message_lat, message_lon) );

}*/


	/*$(function(){

			console.log("step_index: " + step_index)

	 document.getElementById("StepCount").innerHTML=step_index;
	  document.getElementById("StrideCount").innerHTML=stride_index;
	  document.getElementById("Speed").innerHTML=spd_index.toFixed(2);
	  document.getElementById("StepLength").innerHTML=step_len_index.toFixed(2);
	  document.getElementById("StepAvg").innerHTML=step_frq_index;
	  document.getElementById("Distance").innerHTML = dist_index.toFixed(2);

	});*/
</script>


	<script async defer
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAvaaEu7gTg_1ewo6F22MRkHtuF6jCbi7g&callback=initMap">
   </script>

<style>
.infotext { float:left; }
.legend{
  position: absolute; top:0;
   margin-top: 5px;
   margin-left: 100px;
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
.chart { width:100%; height:500px; }
.icon { float:left; margin-right:10px; }

.col-md-6 { padding-left:5px; padding-right:5px; }
.nav-tabs { border:0px; }
.nav-tabs > li { border-color: transparent; background: none; }
.nav-tabs > li:hover { border-color: transparent; background: none; }
.nav-tabs > li.active > a { border-color: transparent; }
.nav-tabs > li.active > a:hover { border-color: transparent; }
.nav-tabs > li.active > a:focus { border-color: transparent; }
.nav-tabs > li a { border-color: transparent; background: none; }
.nav-tabs > li a:hover { border-color: transparent; background: none; }

@media (min-width:1000px){

	.chart { height:450px; }
	.asd { margin:10px; padding-bottom:5px; font-size:20px; }

}
</style>

</head>
<body onload="init()">

<%@include file="../include/nav.jsp"%>

<div class="container">
	<div class="panel" style="margin-left:15px;margin-right:15px;"><font class="fs17">Real-time Activity&nbsp;&nbsp;>&nbsp;&nbsp;<span id="curdate"></span><span id="patient" class="right"></span></font></div>
	<ul class="nav nav-tabs" style="margin-left:15px;margin-right:15px;">
    <li class="active"><a data-toggle="tab" href="#fall-risk-analysis"><font class="s17">Fall Risk Analysis</font></a></li>
    <li><a data-toggle="tab" href="#activity"><font class="s17">Activity Detail</font></a></li>
    <li><a data-toggle="tab" href="#activity_realtime"><font class="s17">Activity Timeline</font></a></li>
	<li><a data-toggle="tab" href="#patient_location"><font class="s17">Patient Location</font></a></li>
  </ul>



	<div class="tab-content">
  <div id="fall-risk-analysis" class="tab-pane  fade in active">
    <div class="row" style="margin-left:0px;margin-right:0px;">
      <div class="col-md-12 col-xs-12">
        <div class="panel" style="margin-left:0px;margin-right:0px;">
          <div class="row" style="margin-left:0px;margin-right:0px;">
            <div class="col-md-6 col-xs-12">
              <div class="fs20 text-primary text-center" style="margin-top: 10px">Stability Index</div>
              <div  id="chart-sta" class="chart" width="200px" style="padding-bottom: 90px; "></div>

            </div>
            <div class="col-md-6 col-xs-12">
              <div class="fs20 text-primary text-center" style="margin-top: 10px">Symmetry Index</div>
              <div id="chart-sym" class="chart" style="padding-bottom: 90px;"></div>

            </div>

          </div>

        </div>
      </div>
    </div>

    <div class="row" style="margin-left:0px;margin-right:0px;">
  <div class="col-md-12 col-xs-12">
    <div class="panel" style="color:#2d904f;margin-left:0px;margin-right:0px;padding-top: 10px; padding-bottom: 10px; margin-top: 0px; margin-bottom:0px;">

      <div class="row" style="margin-left:0px;margin-right:0px;">
        <div class="col-md-6 col-xs-12">
          <div class="fs20">
            <img src="../images/icons/step.png" width="30" height="30">&nbsp;<font  style="color:#2d904f;">Step count&nbsp;:&nbsp;<font id ="StepCount"></font></font>&nbsp;steps</div>
            <%-- <div class="fs15">Longest&nbsp;:&nbsp;<font id="lstationary"></font></div> --%>

            <div class="fs20" style="margin-top: 15px">
              <img src="../images/icons/active.png" width="30" height="30">

                <font  style="color:#f57a3e;">Stride Count&nbsp;:&nbsp;<font id="StrideCount"></font>&nbsp;strides</font>
              </div>

              <div class="fs20" style="margin-top: 15px">
                <img src="../images/icons/marker.png" width="30" height="30">
                  <font id="velocity" style="color:#ea5f5c;">AVG Speed&nbsp;:&nbsp;<font id ="Speed">2.2</font>&nbsp;m/s</font>
                </div>

              </div>

              <div class="col-md-6 col-xs-12">

                <div class="fs20">
                  <img src="../images/icons/walk.png" width="30" height="30">
                    <font id="velocity" style="color:#2d904f;">AVG step frequency&nbsp;:&nbsp;<font id = "StepAvg">2</font>&nbsp;steps/s</font>
                  </div>

                  <div class="fs20" style="margin-top: 15px">
                    <img src="../images/icons/step_length.png" width="35" height="35">
                      <font id="velocity" style="color:#f57a3e;">Estimated step length&nbsp;:&nbsp;<font id = "StepLength">40</font>&nbsp;cm.</font>
                    </div>

                    <div class="fs20" style="margin-top: 15px">
                      <img src="../images/icons/distance.png" width="30" height="30">

                        <font style="color:#2f4074;">Distance&nbsp;:&nbsp;<font id="Distance" ></font>&nbsp;m.</font>
                      </div>

                    </div>

                  </div>

                </div>

              </div>


            </div>




<%--
                <canvas id="sleeping" width="40" height="40" style="border:2px solid #000000; padding 0 15px; float: left;">t --%>


<%-- <canvas id="lying" width="40" height="40" style="border:2px solid #000000;">
  <canvas id="sitting" width="40" height="40" style="border:2px solid #000000;">
<canvas id="standing" width="40" height="40" style="border:2px solid #000000;">
<canvas id="walking" width="40" height="40" style="border:2px solid #000000;">
<canvas id="running" width="40" height="40" style="border:2px solid #000000;">
<canvas id="climbing" width="40" height="40" style="border:2px solid #000000;"> --%>





      </div>




        <div id="activity" class="tab-pane fade">
            <div class="col-md-6 col-xs-12">
                <div class="panel" style="margin-left:10px;margin-right:10px;">
                    <div id="chartdiv" class="chart"></div>
                </div>
            </div>


            <div class="col-md-6 col-xs-12">
                <div class="panel" style="margin-left:5px;margin-right:5px;">
                    <div class="fs20">&nbsp;Real-Time Activity&nbsp;:&nbsp;<span id="curact"></span>&nbsp;</div>
                </div>
            </div>
            <div class="col-md-6 col-xs-12">
                <div class="row" style="margin-left:0px;margin-right:0px;">
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#ea5f5c;">
                            <div class="fs20"><img src="../images/icons/hr.png" width="30" height="30">&nbsp;<font id="hr"></font>&nbsp;bpm</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;;color:#f57a3e;">
                            <div class="fs20"><img src="../images/icons/cal.png" width="30" height="30">&nbsp;<font id="cal"></font>&nbsp;calories</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xs-12">
                <div class="row" style="margin-left:0px;margin-right:0px;">
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#2d904f;">
                            <div class="fs20"><img src="../images/icons/step.png" width="30" height="30">&nbsp;<font id="steps"></font>&nbsp;Steps</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#2f4074;">
                            <div class="fs20"><img src="../images/icons/distance.png" width="30" height="30">&nbsp;distance&nbsp;:&nbsp;<font id="dist"></font>&nbsp;m</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-xs-12">
                <div class="panel" style="color:#2f4074;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="../images/icons/sleep.png" width="50" height="50"></div>
                    <div class="fs20">Sleep time&nbsp;:&nbsp;<font id="sleep"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lsleep"></font></div>
                </div>
                <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="../images/icons/stattime.png" width="50" height="50"></div>
                    <div class="fs20">Stationary time&nbsp;:&nbsp;<font id="stationary"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lstationary"></font></div>
                </div>
                <div class="panel" style="color:#f57a3e;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="../images/icons/active.png" width="50" height="50"></div>
                    <div class="fs20">Active time&nbsp;:&nbsp;<font id="active"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lactive"></font></div>
                </div>
                <div class="panel" style="color:#2d904f;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="../images/icons/highlyactive.png" width="50" height="50"></div>
                    <div class="fs20">Highly Active time&nbsp;:&nbsp;<font id="highlyactive"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lhighlyactive"></font></div>
                </div>
            </div>
        </div>



          <div id="activity_realtime" class="tab-pane fade">

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


          <div id="patient_location" class="tab-pane fade">

            <div class="row">
          		<div class="col-md-12">

					<div class="panel" style="margin-left:10px;margin-right:10px;">


						<div id="map" style="height:900px; max-width: none; "></div>



					</div>
                </div>
          	</div>


          </div>
    </div>
</div>


<!-- JS Main File -->




<script src="../js/bootstrap.min.js"></script>
</body>
</html>
