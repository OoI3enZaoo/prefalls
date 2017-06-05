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

	String start_fall = (String)session.getAttribute("tstamp");


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
	String rollalerts = "\'{\"allrollalerts\": [";
	String fall_history_json = "\'{\"falling\": [";

    int minhr = 0;
    int maxhr = 0;


	String test_lat = "";
	String test_lon = "";

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
		String sql = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, act_type, 0 AS alert_type FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '" + date + "' UNION SELECT UNIX_TIMESTAMP(start) * 1000 AS MILLISECONDS, 0 AS act_type, alert_type FROM alerts where (SSSN = '" + sssn + "') AND (alert_type = 7) AND (DATE_FORMAT(start,'%Y-%m-%d')= '"+date+"') ORDER BY MILLISECONDS";
		ResultSet rs = dbm.executeQuery(sql);
		if (rs.next()){
			rollalerts = rollalerts + "{\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"acttype\":\"" + rs.getInt("act_type") + "\" , \"alerttype\":\"" + rs.getInt("alert_type") + "\"}";
			}
		while(rs.next()){
			rollalerts = rollalerts + ", {\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"acttype\":\"" + rs.getInt("act_type") + "\" , \"alerttype\":\"" + rs.getInt("alert_type") + "\"}";
		}
		rollalerts = rollalerts + "]}\'";


		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
	try {
		start_fall = "2017-06-01 18:00:00";
		String sql = "SELECT tstamp , hr , act_type FROM archive_"+sssn+" WHERE tstamp BETWEEN SUBTIME('"+start_fall+"' , '0:30:00') AND ADDTIME('"+start_fall+"' , '0:30:00')";
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
		start_fall = "2012-01-02 09:19:52";

		String sql = "SELECT lat , lon FROM archive_"+sssn+" WHERE tstamp = DATE_FORMAT('"+start_fall+"','%Y-%m-%d %H:%i:%s')";
		ResultSet rs = dbm.executeQuery(sql);

		while((rs!=null) && (rs.next())){
			test_lat = String.valueOf(rs.getDouble("lat"));
			test_lon = String.valueOf(rs.getDouble("lon"));
		}


		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

		//out.println(test_lat + test_lon);

	dbm.closeConnection();

    date = "\""+date+"\"";

%>

<!doctype html>
<head>
<title>PreFall</title>
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

<style media="screen">


.legend{
	position: absolute; top:0;
	 margin-top: 5px;
	 margin-left: 100px;
}

</style>
<%-- <script src="https://www.amcharts.com/lib/3/gantt.js"></script> --%>




<script type="text/javascript">

    var msgInterval = <%=msgInterval%>;
	var actgroup = 0;

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
	var rollalerts = <%=rollalerts%>;
	var	jsonrollalerts = JSON.parse(rollalerts);
	var fall_history = <%=fall_history_json%>;
	var json_fall_history = JSON.parse(fall_history);
	console.log(json_fall_history);

	//varible google map
	var lat = 13.664336;//<%=test_lat%>
	var lng = 100.387573;//<%=test_lon%>


	// Donut chart
	var donutchart = AmCharts.makeChart( "chartdiv", {
	  "type": "pie",
	  "pullOutRadius": 0,
	  "theme": "light",

	  "allLabels": [{
        "text": "Mobilise Index",
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
    for (var i = 0; i < jsonhr.allhr.length; i++) {
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

    //chartRoll
    var chartDataRoll = ChartDataRoll();
	console.log("This is chartDataRoll ");
	console.log(chartDataRoll);
	var chartRoll = AmCharts.makeChart("chartdiv5", {
              "type": "xy",
			  "theme": "light",
              "startDuration": 0,
              "trendLines": [],
              "graphs": [
                {
                  "balloonText": "<b>[[time]]</b>",
                  "bullet": "square",
                  "id": "AmGraph-1",
                  "lineAlpha": 0,
                  "lineColorField": "lineColor",
				  "bulletSize": 16,
//                  "bulletSizeField": "value",
                  "xField": "time",
                  "yField": "acttype"
                }
              ],
              "guides": [],
			  "legend": {
				"data":  [{
					title: "Less than 1 hour",
					color: "#00ff00"}
					, {
					title: " 1 - 2 hours",
					color: "#ffff00"}
					, {
					title: " 2 - 3 hours",
					color: "#ff8000"}
					, {
					title: "More than 3 hours",
					color: "#ff0000"}
					]
			  },
              "valueAxes": [
                {
                  "id": "ValueAxis-1",
                  "axisAlpha": 0,
				  "labelFunction": formatValue,
				  "autoGridCount": false,
				  "gridCount": 2
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
              "dataProvider": chartDataRoll
            });


    chartRoll.addListener("dataUpdated", zoomChartRoll);
    // when we apply theme, the dataUpdated event is fired even before we add listener, so
    // we need to call zoomChart here
    zoomChartRoll();
    // this method is called when chart is first inited as we listen for "dataUpdated" event
    function zoomChartRoll() {
        // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
        //chartRoll.zoomToIndexes(chartRoll.length - 250, chartRoll.length - 100);
		//chartRoll.write("chartdiv5");
		//console.log("zoomDataRoll");
		chartRoll.validateData();
    }

    function Generator_Activity() {
    var Data = [];
	var color_code = "";
	var heartrate_random = Math.floor((Math.random() *100)+1);
    for (var i = 0; i < json_fall_history.falling.length; i++) {
				if(parseInt(json_fall_history.falling[i].act) == 2){color_code = "#FF0000";}
				else if(parseInt(json_fall_history.falling[i].act) == 1){color_code = "#FF00BF";}
				else if(parseInt(json_fall_history.falling[i].act) == 3){color_code = "#FFFF00";}
				else if(parseInt(json_fall_history.falling[i].act) == 4){color_code = "#00FF00";}
				else if(parseInt(json_fall_history.falling[i].act) == 5){color_code = "#0000FF";}
				else if(parseInt(json_fall_history.falling[i].act) == 8){color_code = "#0000FF";}
				else if(parseInt(json_fall_history.falling[i].act) == 6){color_code = "#FF00FF";}
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


    function ChartDataRoll() {
	var tmpDataRoll = [];
    var DataRoll = [];
	var totaltime = 0;
    for (var i = 0; i < jsonrollalerts.allrollalerts.length; i++) {
        var mytime = new Date();
        var newTime = parseInt(jsonrollalerts.allrollalerts[i].timestamp);
        mytime.setTime(newTime);
		if ((parseInt(jsonrollalerts.allrollalerts[i].acttype) < 4) && (parseInt(jsonrollalerts.allrollalerts[i].alerttype) == 0)) {
			totaltime += 3;
			tmpDataRoll.push({
				time: mytime,
				value: 4
			});
		}
		else{
			var labelcolor = "";
			console.log(totaltime);

			if (totaltime <= 3600){
				labelcolor = "#00ff00";
			}
			else{
				if (totaltime <= 7200){
					labelcolor = "#ffff00";
				}
				else {
					if (totaltime <= 9800){
						labelcolor = "#ff8000";
					}
					else {labelcolor = "#ff0000";}
				}
			}
			for (var j = 0; j < tmpDataRoll.length; j++){
				mytime.setTime(tmpDataRoll[j].time);
				DataRoll.push({
					time: mytime,
					acttype: 1,
					value: 4,
					lineColor: labelcolor
				});
			}
			if (jsonrollalerts.allrollalerts[i].alerttype == 7){
				mytime.setTime(jsonrollalerts.allrollalerts[i].timestamp);
				DataRoll.push({
					time: mytime,
					acttype: 2,
					value: 4,
					lineColor: "#ff0000"
				});
			}
			totaltime = 0;
			tmpDataRoll = [];
		}
    }
    return DataRoll;
	}

	function fillImmobilityTable(){
		var d = new Date(date);
		uDate = d.getTime() - (7 * 60 * 60 * 1000); //SE Asia Standard Time
		var totaltime = 0;
		for (var i = 0; i < jsonrollalerts.allrollalerts.length; i++) {
			if ((jsonrollalerts.allrollalerts[i].acttype > 0) && (jsonrollalerts.allrollalerts[i].acttype < 4)){
				totaltime += 3;
			}
			else{
				if (jsonrollalerts.allrollalerts[i].alerttype == 7){
					fillActivity(jsonrollalerts.allrollalerts[i].timestamp - uDate, totaltime);
					totaltime = 0;
					if (jsonrollalerts.allrollalerts[i].timestamp <= (uDate + (6 * 3600000))){ //Row1
						var c15 = parseInt($("#c15").html()) + 1;
						$("#c15").html(c15);
						continue;
					}
					if (jsonrollalerts.allrollalerts[i].timestamp <= (uDate + (12 * 3600000))){ //Row2
						var c25 = parseInt($("#c25").html()) + 1;
						$("#c25").html(c25);
						continue;
					}
					if (jsonrollalerts.allrollalerts[i].timestamp <= (uDate + (18 * 3600000))){ //Row3
						var c35 = parseInt($("#c35").html()) + 1;
						$("#c35").html(c35);
						continue;
					}
					if (jsonrollalerts.allrollalerts[i].timestamp <= (uDate + (24 * 3600000))){ //Row4
						var c45 = parseInt($("#c45").html()) + 1;
						$("#c45").html(c45);
						continue;
					}
				}
				else{
					fillActivity(jsonrollalerts.allrollalerts[i].timestamp - uDate, totaltime);
					totaltime = 0;
				}
			}
		}
	}

	function fillActivity(ms, ttime){
		var row1 = [parseInt($("#c11").html()), parseInt($("#c12").html()), parseInt($("#c13").html()), parseInt($("#c14").html())];
		var row2 = [parseInt($("#c21").html()), parseInt($("#c22").html()), parseInt($("#c23").html()), parseInt($("#c24").html())];
		var row3 = [parseInt($("#c31").html()), parseInt($("#c32").html()), parseInt($("#c33").html()), parseInt($("#c34").html())];
		var row4 = [parseInt($("#c41").html()), parseInt($("#c42").html()), parseInt($("#c43").html()), parseInt($("#c44").html())];

		if (ttime > 0){
			if ((ms/(3600000)) <= 6){ //Row 1
				row1[Math.floor(ttime/(3600))] = row1[Math.floor(ttime/(3600000))] + 1;
			}
			else if((ms/(3600000)) <= 12){ //Row 2
				row2[Math.floor(ttime/(3600))] = row2[Math.floor(ttime/(3600000))] + 1;
			}
			else if((ms/(3600000)) <= 18){ //Row 3
				row3[Math.floor(ttime/(3600))] = row3[Math.floor(ttime/(3600000))] + 1;
			}
			else{row4[Math.floor(ttime/(3600))] = row4[Math.floor(ttime/(3600000))] + 1;}
		}
		$("#c11").html(row1[0]);
		$("#c12").html(row1[1]);
		$("#c13").html(row1[2]);
		$("#c14").html(row1[3]);
		$("#c21").html(row2[0]);
		$("#c22").html(row2[1]);
		$("#c23").html(row2[2]);
		$("#c24").html(row2[3]);
		$("#c31").html(row3[0]);
		$("#c32").html(row3[1]);
		$("#c33").html(row3[2]);
		$("#c34").html(row3[3]);
		$("#c41").html(row4[0]);
		$("#c42").html(row4[1]);
		$("#c43").html(row4[2]);
		$("#c44").html(row4[3]);
	}

	function formatValue(value, formattedValue, valueAxis){
		var actvalue = "";
		if (value == 1){
			actvalue = "Immobility Time";
		}
		if (value == 2){
			actvalue = "Turn Over Time";
		}
		return actvalue;
	}

	function formatTimeAxis(value, formattedValue, valueAxis){
		var timevalue = new Date(value);
		return (timevalue.toTimeString()).substr(0, 5);
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

		fillImmobilityTable();
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


	$.getJSON("http://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng+"&sensor=false", function(result){
            $("#location").text(result.results[0].formatted_address);
			console.log("print location = "  + result.results[0].formatted_address);
    });


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
#chartdiv5 {
	width	: 100%;
	height	: 500px;
}
#chartdivactivity {
	width		: 100%;
	height		: 500px;
	font-size	: 11px;
}

</style>

<style>
      /* Always set the map height explicitly to define the size of the div
       * element that contains the map. */
      #map {
            position: relative;
            width: 100%;
            height: 45vh;
            margin: 0;
            padding: 0;
        }
    </style>

</head>
<body onload="init()">

<%@include file="../include/nav.jsp"%>

<div class="container">
    <div class="panel"><font class="fs17">History > <span id="date"></span><span id="patient" class="right"></span></font></div>
	<div class="row">
		<div class="col-md-12">
            <ul class="nav nav-tabs" style="margin-left:10px;margin-right:10px;">
				<!--<li class="active"><a href="#tab0default" data-toggle="tab">Fall History</a></li>-->
                <li class="active"><a href="#tab1default" data-toggle="tab">Summary</a></li>
                <li><a href="#tab2default" data-toggle="tab">Calories</a></li>
                <li><a href="#tab3default" data-toggle="tab">Heart rate</a></li>
<!--                <li><a href="#tab4default" data-toggle="tab">อัตราความเร็วที่ใช้ในการเคลื่อนไหว</a></li>-->
				<li><a href="#tab5default" data-toggle="tab">Immobility</a></li>
				<li><a href="#tab6default" data-toggle="tab">Immobility Summary</a></li>
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
                <div class="tab-pane fade" id="tab6default">
                	<div class="panel" style="margin-left:10px;margin-right:10px;">
					<table class="table table-striped table-bordered">
						<thead>
							<tr class="success" >
								<th rowspan="2" class="text-center">Period</th>
								<th colspan="4" class="text-center">Immobility frequency by time</th>
								<th rowspan="2" class="text-center">Turn over frequency</th>
							</tr>
							<tr class="success">
								<th class="text-center">less than 1 hour</th>
								<th class="text-center">1 - 2 hours</th>
								<th class="text-center">2 - 3 hours</th>
								<th class="text-center">more than 3 hours</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="text-center">00:01 - 06:00 </td>
								<td class="text-center" id = "c11">0</td>
								<td class="text-center" id = "c12">0</td>
								<td class="text-center" id = "c13">0</td>
								<td class="text-center" id = "c14">0</td>
								<td class="text-center" id = "c15">0</td>
							</tr>
							<tr>
								<td class="text-center">06:01 - 12:00 </td>
								<td class="text-center" id = "c21">0</td>
								<td class="text-center" id = "c22">0</td>
								<td class="text-center" id = "c23">0</td>
								<td class="text-center" id = "c24">0</td>
								<td class="text-center" id = "c25">0</td>
							</tr>
							<tr>
								<td class="text-center">12:01 - 18:00 </td>
								<td class="text-center" id = "c31">0</td>
								<td class="text-center" id = "c32">0</td>
								<td class="text-center" id = "c33">0</td>
								<td class="text-center" id = "c34">0</td>
								<td class="text-center" id = "c35">0</td>
							</tr>
							<tr>
								<td class="text-center">18:01 - 00:00 </td>
								<td class="text-center" id = "c41">0</td>
								<td class="text-center" id = "c42">0</td>
								<td class="text-center" id = "c43">0</td>
								<td class="text-center" id = "c44">0</td>
								<td class="text-center" id = "c45">0</td>
							</tr>
						</tbody>
					</table>
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
