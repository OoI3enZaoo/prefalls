<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.text.DecimalFormat" %>
<%@include file="../config.jsp"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../");
	}
	
	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String sssn = (String)session.getAttribute("SSSN");
	
	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}

	String date = request.getParameter("date");
    String name = "\'" + session.getAttribute("fname") + " " + session.getAttribute("lname") + "\'";

    int sleep = 0;
	int stationary = 0;
	int active = 0;
	int hactive = 0;

	double calsleep =0.0;
	double callying =0.0;
	double calsitting =0.0;
	double calstanding =0.0;
	double calwalking =0.0;
	double calstair =0.0;
	double calruning =0.0;
	int acttype =0;
	
	int lsleep = 0;
	int lstationary = 0;
	int lactive = 0;
	int lhactive = 0;
	
	int sstep = 0;
	double sdistance = 0.0;
	double scalories = 0.0;
	int sismobile = 0;

	String hr = "\'{\"allhr\": [";
    String pace = "\'{\"allpace\": [";
    
    int minhr = 0;
    int maxhr = 0;

	dbm.createConnection();
    
    try {
		String grminmax = "SELECT  hr FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
		ResultSet rshr= dbm.executeQuery(grminmax);
        int hrr;
        int count = 0;
		while((rshr!=null) && (rshr.next())){        
            hrr = rshr.getInt("hr");	
            
            if (hrr!=0){
                
                if(count == 0){
                    minhr = hrr;
                    maxhr = hrr;
                    count++;
                }             
   
                minhr = minhr < hrr ? minhr : hrr;
                maxhr = maxhr > hrr ? maxhr : hrr;
    
            }
		}

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
   
    try {
		String sql = "SELECT act_group, COUNT(*) * " + String.valueOf(msgInterval) + "  AS SEC, MAX(long_sleep) AS LSLEEP, MAX(long_stationary) AS LSTATIONARY, MAX(long_active) AS LACTIVE, MAX(long_hactive) AS LHACTIVE FROM actgroup a, archive_" + sssn + " b WHERE (a.group_id = b.act_group) AND DATE_FORMAT(tstamp,'%Y-%m-%d')= '" + date + "' GROUP BY act_group;";
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
		String sql = "SELECT SUM(step) AS SSTEP, SUM(calories) AS SCALORIES, SUM(ismobile) AS SISMOBILE, SUM(dist) AS SDISTANCE FROM archive_" + sssn + " WHERE DATE_FORMAT(tstamp,'%Y-%m-%d')= '" + date + "' ;";
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
		String grcl = "SELECT calories,act_type FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
		ResultSet cl= dbm.executeQuery(grcl);
		

		while(cl.next()){
			if (cl.getInt("act_type")==1){
			calsleep += cl.getDouble("calories");
			}
			else if (cl.getInt("act_type")==2){
			callying += cl.getDouble("calories");
			}
			else if (cl.getInt("act_type")==3){
			calsitting += cl.getDouble("calories");
			}
			else if (cl.getInt("act_type")==4){
			calstanding += cl.getDouble("calories");
			}
			else if (cl.getInt("act_type")==5){
			calwalking += cl.getDouble("calories");
			}
			else if (cl.getInt("act_type")==6){
			calstair += cl.getDouble("calories");
			}
			else{
			calruning += cl.getDouble("calories");
			}
		}
	} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}


	try {
		String grPc = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, hr FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
		ResultSet pc= dbm.executeQuery(grPc);
		if (pc.next()){
			hr = hr + "{\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"hr\":\"" + pc.getInt("hr") + "\"}";
			}
		while(pc.next()){
			hr = hr + ", {\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"hr\":\"" + pc.getInt("hr") + "\"}";
		}
		hr = hr + "]}\'";

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

	try {
		String grPc = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, pace FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
		ResultSet pc= dbm.executeQuery(grPc);
		if (pc.next()){
			pace = pace + "{\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"pace\":\"" + pc.getInt("pace") + "\"}";
			}
		while(pc.next()){
			pace = pace + ", {\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"pace\":\"" + pc.getInt("pace") + "\"}";
		}
		pace = pace + "]}\'";

		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
	dbm.closeConnection();
    
    date = "\""+date+"\""; 
	
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
<script src="../js/amcharts/amcharts.js"></script>
<script src="../js/amcharts/themes/light.js"></script>
<!-- JS ChartColumn amCharts File -->
<!-- JS ChartDonut  amCharts File -->
<script src="../js/amcharts/pie.js"></script>
<!--JS-->
<script src="../js/amcharts/serial.js"></script>
<script type="text/javascript">
    
    var msgInterval = <%=msgInterval%>;
	var actgroup = 0;
	var hr = 0;
	var mobilityIdx = 0.0;
	var sstep = <%=sstep%>;
	var scalories = <%=scalories%>;
	var sleep = <%=sleep%>;
	var stationary = <%=stationary%>;
	var active = <%=active%>;
	var hactive = <%=hactive%>;
	var sismobile = <%=sismobile%>;
	var sdistance = <%=sdistance%>;
	var notAvail = 86400 - sleep - stationary - active - hactive;	

	var lsleep = <%=lsleep%>;
	var lstationary = <%=lstationary%>;
	var lactive = <%=lactive%>;
	var lhactive = <%=lhactive%>;

	var calsleep = parseInt(<%=calsleep%>,10);
	var callying = parseInt(<%=callying%>,10);
	var calsitting = parseInt(<%=calsitting%>,10);
	var calstanding = parseInt(<%=calstanding%>,10);
	var calwalking = parseInt(<%=calwalking%>,10);
	var calstair = parseInt(<%=calstair%>,10);
	var calruning = parseInt(<%=calruning%>,10);
    
    var date = <%=date%>;
    
    var minhr = <%=minhr%>;
    var maxhr = <%=maxhr%>;

	var name = <%=name%>;

	var hr = <%=hr%>;
	var jsonhr = JSON.parse(hr);
	var pace = <%=pace%>;
	var	jsonpace = JSON.parse(pace);
	
	// Donut chart
	var donutchart = AmCharts.makeChart( "chartdiv", {
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

	// Column With Rotated Series
	var chart = AmCharts.makeChart("chartdiv2", {
	  "type": "serial",
	  "theme": "light",
	  "marginRight": 70,
	  "dataProvider": [{
	    "country": "Running",
	    "visits": calruning,
	    "color": "#6b8094"
	  }, {
	    "country": "Stair climbling",
	    "visits": calstair,
	    "color": "#85c5e3"
	  }, {
	    "country": "Walking",
	    "visits": calwalking,
	    "color": "#e1a0fc"
	  }, {
	    "country": "Standing",
	    "visits": calstanding,
	    "color": "#fb5e65"
	  }, {
	    "country": "Sitting",
	    "visits": calsitting,
	    "color": "#75bdee"
	  }, {
	    "country": "Lying",
	    "visits": callying,
	    "color": "#f0897e"
	  }, {
	    "country": "Sleep",
	    "visits": calsleep,
	    "color": "#86c6b9"
	  }],
	  "valueAxes": [{
	    "axisAlpha": 0,
	    "position": "left",
	    "title": "Calories"
	  }],
	  "startDuration": 1,
	  "graphs": [{
	    "balloonText": "<b>[[category]]: [[value]] Cal</b>",
	    "fillColorsField": "color",
	    "fillAlphas": 0.9,
	    "lineAlpha": 0.2,
	    "type": "column",
	    "valueField": "visits"
	  }],
	  "chartCursor": {
	    "categoryBalloonEnabled": false,
	    "cursorAlpha": 0,
	    "zoomable": false
	  },
	  "categoryField": "country",
	  "categoryAxis": {
	    "gridPosition": "start",
	    "labelRotation": 45
	  },
	  "export": {
	    "enabled": true
	  }

	});
	
	//chartHeart rate
    var chartDataHR = ChartDatahr();
    var charthr = AmCharts.makeChart("chartdiv3", {
        "type": "serial",
        "theme": "light",
        "marginRight": 80,
        "dataProvider": chartDataHR,
        "valueAxes": [{
            "position": "left",
            "title": "Heart rate"
        }],
        "graphs": [{
            "id": "g1",
            "fillAlphas": 0.4,
            "valueField": "visits",
             "balloonText": "<div style='margin:5px; font-size:19px;'><b>[[value]]</b> bpm</div>"
        }],
        "chartScrollbar": {
            "graph": "g1",
            "scrollbarHeight": 80,
            "backgroundAlpha": 0,
            "selectedBackgroundAlpha": 0.1,
            "selectedBackgroundColor": "#888888",
            "graphFillAlpha": 0,
            "graphLineAlpha": 0.5,
            "selectedGraphFillAlpha": 0,
            "selectedGraphLineAlpha": 1,
            "autoGridCount": true,
            "color": "#AAAAAA"
        },
        "chartCursor": {
            "categoryBalloonDateFormat": "JJ:NN, DD MMMM",
            "cursorPosition": "mouse"
        },
        "categoryField": "date",
        "categoryAxis": {
            "minPeriod": "mm",
            "parseDates": true
        },
        "export": {
            "enabled": true
        }
    });

    charthr.addListener("dataUpdated", zoomChartHR);
    // when we apply theme, the dataUpdated event is fired even before we add listener, so
    // we need to call zoomChart here
    zoomChartHR();
    // this method is called when chart is first inited as we listen for "dataUpdated" event
    function zoomChartHR() {
        // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
        charthr.zoomToIndexes(chartDataHR.length - 250, chartDataHR.length - 100);
    }

    
    function ChartDatahr() {
    var Datahr = [];
    for (var i = 0; i < jsonpace.allpace.length; i++) {
        var time = new Date();
        var newTime = parseInt(jsonhr.allhr[i].timestamp);
        time.setTime(newTime);
        var hr = parseInt(jsonhr.allhr[i].hr);
        Datahr.push({
            date: time,
            visits: hr
        });
    }
    return Datahr;
	}

    //chartPace
    var chartDataPace = ChartDataPace();
    console.log(chartDataPace);
    var chartPace = AmCharts.makeChart("chartdiv4", {
        "type": "serial",
        "theme": "light",
        "marginRight": 80,
        "dataProvider": chartDataPace,
        "valueAxes": [{
            "position": "left",
            "title": "Pace"
        }],
        "graphs": [{
            "id": "g1",
            "fillAlphas": 0.4,
            "valueField": "visits",
             "balloonText": "<div style='margin:5px; font-size:19px;'><b>[[value]]</b> km/H</div>"
        }],
        "chartScrollbar": {
            "graph": "g1",
            "scrollbarHeight": 80,
            "backgroundAlpha": 0,
            "selectedBackgroundAlpha": 0.1,
            "selectedBackgroundColor": "#888888",
            "graphFillAlpha": 0,
            "graphLineAlpha": 0.5,
            "selectedGraphFillAlpha": 0,
            "selectedGraphLineAlpha": 1,
            "autoGridCount": true,
            "color": "#AAAAAA"
        },
        "chartCursor": {
            "categoryBalloonDateFormat": "JJ:NN, DD MMMM",
            "cursorPosition": "mouse"
        },
        "categoryField": "date",
        "categoryAxis": {
            "minPeriod": "mm",
            "parseDates": true
        },
        "export": {
            "enabled": true
        }
    });

    chartPace.addListener("dataUpdated", zoomChartPace);
    // when we apply theme, the dataUpdated event is fired even before we add listener, so
    // we need to call zoomChart here
    zoomChartPace();
    // this method is called when chart is first inited as we listen for "dataUpdated" event
    function zoomChartPace() {
        // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
        chartPace.zoomToIndexes(chartDataPace.length - 250, chartDataPace.length - 100);
    }

    function ChartDataPace() {
    var DataPace = [];
    for (var i = 0; i < jsonpace.allpace.length; i++) {
        var time = new Date();
        var newTime = parseInt(jsonpace.allpace[i].timestamp);
        time.setTime(newTime);
        var pace = parseInt(jsonpace.allpace[i].pace);
        DataPace.push({
            date: time,
            visits: pace
        });
    }
    return DataPace;
	}

    function init(){
        
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
		donutchart.allLabels = chartMobility;
		donutchart.validateData();
        
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
        
        document.getElementById("patient").innerHTML = "Patient Name : " + name;    
        document.getElementById("date").innerHTML = date;
        document.getElementById("minhr").innerHTML = minhr;
        document.getElementById("maxhr").innerHTML = maxhr;
			
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

</script>

<style>
    
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
    .connn { height:500px; border-left: solid 1px #e1e1e1; }
    
}

#chartdiv2 {
	width		: 100%;
	height		: 500px;
	font-size	: 11px;  
}										

.amcharts-export-menu-top-right {
  top: 10px;
  right: 0;
}

#chartdiv3 {
	width	: 100%;
	height	: 500px;
}
#chartdiv4 {
	width	: 100%;
	height	: 500px;
}													
</style>

</head>
<body onload="init()">

<%@include file="../include/nav.jsp"%>
    
<div class="container">
    <div class="panel"><font class="fs17">ประวัติกิจกรรม > <span id="date"></span><span id="patient" class="right"></span></font></div>
	<div class="row">
		<div class="col-md-12">
            <ul class="nav nav-tabs" style="margin-left:10px;margin-right:10px;">
                <li class="active"><a href="#tab1default" data-toggle="tab">ข้อมูลสรุป</a></li>
                <li><a href="#tab2default" data-toggle="tab">ปริมาณแคลอรี่</a></li>
                <li><a href="#tab3default" data-toggle="tab">อัตราการเต้นของหัวใจ</a></li>
                <li><a href="#tab4default" data-toggle="tab">อัตราความเร็วที่ใช้ในการเคลื่อนไหว</a></li>
				<li><a href="#tab5default" data-toggle="tab">ข้อมูลการพลิกตัว</a></li>			
            </ul>
            <div class="tab-content">                                  
                <div id="tab1default" class="tab-pane fade in active">
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
                            <div id="chartdiv" class="chart"></div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                            <div class="icon"><img src="../images/icons/hr.png" width="50" height="50"></div>
                            <div class="fs20">min&nbsp;:&nbsp;<font id="minhr"></font>&nbsp;bpm</div>
                            <div class="fs15">max&nbsp;:&nbsp;<font id="maxhr"></font>&nbsp;bpm</div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xs-12">
                        <div class="row" style="margin-left:0px;margin-right:0px;">
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;;color:#f57a3e;">
                                    <div class="fs20"><img src="../images/icons/cal.png" width="30" height="30">&nbsp;<font id="cal"></font>&nbsp;calories</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;color:#2d904f;">
                                    <div class="fs20"><img src="../images/icons/step.png" width="30" height="30">&nbsp;<font id="steps"></font>&nbsp;Steps</div>
                                </div>
                            </div>
                        </div>
                    </div>    
                    <div class="col-md-6 col-xs-12">
                        <div class="row" style="margin-left:5px;margin-right:5px;">
                            <!--div class="col-md-6"-->
                                <div class="panel" style="margin-left:0px;margin-right:0px;color:#2f4074;">
                                    <div class="fs20"><img src="../images/icons/distance.png" width="30" height="30">&nbsp;distance&nbsp;:&nbsp;<font id="dist"></font>&nbsp;m</div>
                                </div>
                            <!--/div-->
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
                <div class="tab-pane fade" id="tab2default">
                    <div class="panel" style="margin-left:10px;margin-right:10px;">
                        <div id="chartdiv2"></div>
                    </div>
                </div>
                <div class="tab-pane fade" id="tab3default">
                    <div class="panel" style="margin-left:10px;margin-right:10px;">
                        <div id="chartdiv3"></div>
                    </div>
                </div>
                <div class="tab-pane fade" id="tab4default">
                	<div class="panel" style="margin-left:10px;margin-right:10px;">
                		<div id="chartdiv4"></div>
                	</div>
                </div>
                <div class="tab-pane fade" id="tab5default">
                	<div class="panel" style="margin-left:10px;margin-right:10px;">
                		<div id="chartdiv5"></div>
                	</div>
                </div>				
            </div>
        </div>
	</div>
</div>
<!-- JS Main File -->
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
