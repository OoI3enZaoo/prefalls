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
	String rollalerts = "\'{\"allrollalerts\": [";
    
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
<script src="../js/amcharts/xy.js"></script>
<script src="https://www.amcharts.com/lib/3/plugins/export/export.min.js"></script>
<link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css" media="all" />
<script src="https://www.amcharts.com/lib/3/themes/light.js"></script>
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
	var rollalerts = <%=rollalerts%>;
	var	jsonrollalerts = JSON.parse(rollalerts);
	console.log(jsonrollalerts);
	
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


	var chart = AmCharts.makeChart("chartdivheart_fall", {
    "type": "serial",
    "theme": "light",
    "marginRight": 40,
    "marginLeft": 40,
    "autoMarginOffset": 20,
    "mouseWheelZoomEnabled":true,
    "dataDateFormat": "YYYY-MM-DD",
    "valueAxes": [{
        "id": "v1",
        "axisAlpha": 0,
        "position": "left",
        "ignoreAxisWidth":true
    }],
    "balloon": {
        "borderThickness": 1,
        "shadowAlpha": 0
    },
    "graphs": [{
        "id": "g1",
        "balloon":{
          "drop":true,
          "adjustBorderColor":false,
          "color":"#ffffff"
        },
        "bullet": "round",
        "bulletBorderAlpha": 1,
        "bulletColor": "#FFFFFF",
        "bulletSize": 5,
        "hideBulletsCount": 50,
        "lineThickness": 2,
        "title": "red line",
        "useLineColorForBulletBorder": true,
        "valueField": "value",
        "balloonText": "<span style='font-size:18px;'>[[value]]</span>"
    }],
    "chartScrollbar": {
        "graph": "g1",
        "oppositeAxis":false,
        "offset":30,
        "scrollbarHeight": 80,
        "backgroundAlpha": 0,
        "selectedBackgroundAlpha": 0.1,
        "selectedBackgroundColor": "#888888",
        "graphFillAlpha": 0,
        "graphLineAlpha": 0.5,
        "selectedGraphFillAlpha": 0,
        "selectedGraphLineAlpha": 1,
        "autoGridCount":true,
        "color":"#AAAAAA"
    },
    "chartCursor": {
        "pan": true,
        "valueLineEnabled": true,
        "valueLineBalloonEnabled": true,
        "cursorAlpha":1,
        "cursorColor":"#258cbb",
        "limitToGraph":"g1",
        "valueLineAlpha":0.2,
        "valueZoomable":true
    },
    "valueScrollbar":{
      "oppositeAxis":false,
      "offset":50,
      "scrollbarHeight":10
    },
    "categoryField": "date",
    "categoryAxis": {
        "parseDates": true,
        "dashLength": 1,
        "minorGridEnabled": true
    },
    "export": {
        "enabled": true
    },
    "dataProvider": [{
        "date": "2012-07-27",
        "value": 13
    }, {
        "date": "2012-07-28",
        "value": 11
    }, {
        "date": "2012-07-29",
        "value": 15
    }, {
        "date": "2012-07-30",
        "value": 16
    }, {
        "date": "2012-07-31",
        "value": 18
    }, {
        "date": "2012-08-01",
        "value": 13
    }, {
        "date": "2012-08-02",
        "value": 22
    }, {
        "date": "2012-08-03",
        "value": 23
    }, {
        "date": "2012-08-04",
        "value": 20
    }, {
        "date": "2012-08-05",
        "value": 17
    }, {
        "date": "2012-08-06",
        "value": 16
    }, {
        "date": "2012-08-07",
        "value": 18
    }, {
        "date": "2012-08-08",
        "value": 21
    }, {
        "date": "2012-08-09",
        "value": 26
    }, {
        "date": "2012-08-10",
        "value": 24
    }, {
        "date": "2012-08-11",
        "value": 29
    }, {
        "date": "2012-08-12",
        "value": 32
    }, {
        "date": "2012-08-13",
        "value": 18
    }, {
        "date": "2012-08-14",
        "value": 24
    }, {
        "date": "2012-08-15",
        "value": 22
    }, {
        "date": "2012-08-16",
        "value": 18
    }, {
        "date": "2012-08-17",
        "value": 19
    }, {
        "date": "2012-08-18",
        "value": 14
    }, {
        "date": "2012-08-19",
        "value": 15
    }, {
        "date": "2012-08-20",
        "value": 12
    }, {
        "date": "2012-08-21",
        "value": 8
    }, {
        "date": "2012-08-22",
        "value": 9
    }, {
        "date": "2012-08-23",
        "value": 8
    }, {
        "date": "2012-08-24",
        "value": 7
    }, {
        "date": "2012-08-25",
        "value": 5
    }, {
        "date": "2012-08-26",
        "value": 11
    }, {
        "date": "2012-08-27",
        "value": 13
    }, {
        "date": "2012-08-28",
        "value": 18
    }, {
        "date": "2012-08-29",
        "value": 20
    }, {
        "date": "2012-08-30",
        "value": 29
    }, {
        "date": "2012-08-31",
        "value": 33
    }, {
        "date": "2012-09-01",
        "value": 42
    }, {
        "date": "2012-09-02",
        "value": 35
    }, {
        "date": "2012-09-03",
        "value": 31
    }, {
        "date": "2012-09-04",
        "value": 47
    }, {
        "date": "2012-09-05",
        "value": 52
    }, {
        "date": "2012-09-06",
        "value": 46
    }, {
        "date": "2012-09-07",
        "value": 41
    }, {
        "date": "2012-09-08",
        "value": 43
    }, {
        "date": "2012-09-09",
        "value": 40
    }, {
        "date": "2012-09-10",
        "value": 39
    }, {
        "date": "2012-09-11",
        "value": 34
    }, {
        "date": "2012-09-12",
        "value": 29
    }, {
        "date": "2012-09-13",
        "value": 34
    }, {
        "date": "2012-09-14",
        "value": 37
    }, {
        "date": "2012-09-15",
        "value": 42
    }, {
        "date": "2012-09-16",
        "value": 49
    }, {
        "date": "2012-09-17",
        "value": 46
    }, {
        "date": "2012-09-18",
        "value": 47
    }, {
        "date": "2012-09-19",
        "value": 55
    }, {
        "date": "2012-09-20",
        "value": 59
    }, {
        "date": "2012-09-21",
        "value": 58
    }, {
        "date": "2012-09-22",
        "value": 57
    }, {
        "date": "2012-09-23",
        "value": 61
    }, {
        "date": "2012-09-24",
        "value": 59
    }, {
        "date": "2012-09-25",
        "value": 67
    }, {
        "date": "2012-09-26",
        "value": 65
    }, {
        "date": "2012-09-27",
        "value": 61
    }, {
        "date": "2012-09-28",
        "value": 66
    }, {
        "date": "2012-09-29",
        "value": 69
    }, {
        "date": "2012-09-30",
        "value": 71
    }, {
        "date": "2012-10-01",
        "value": 67
    }, {
        "date": "2012-10-02",
        "value": 63
    }, {
        "date": "2012-10-03",
        "value": 46
    }, {
        "date": "2012-10-04",
        "value": 32
    }, {
        "date": "2012-10-05",
        "value": 21
    }, {
        "date": "2012-10-06",
        "value": 18
    }, {
        "date": "2012-10-07",
        "value": 21
    }, {
        "date": "2012-10-08",
        "value": 28
    }, {
        "date": "2012-10-09",
        "value": 27
    }, {
        "date": "2012-10-10",
        "value": 36
    }, {
        "date": "2012-10-11",
        "value": 33
    }, {
        "date": "2012-10-12",
        "value": 31
    }, {
        "date": "2012-10-13",
        "value": 30
    }, {
        "date": "2012-10-14",
        "value": 34
    }, {
        "date": "2012-10-15",
        "value": 38
    }, {
        "date": "2012-10-16",
        "value": 37
    }, {
        "date": "2012-10-17",
        "value": 44
    }, {
        "date": "2012-10-18",
        "value": 49
    }, {
        "date": "2012-10-19",
        "value": 53
    }, {
        "date": "2012-10-20",
        "value": 57
    }, {
        "date": "2012-10-21",
        "value": 60
    }, {
        "date": "2012-10-22",
        "value": 61
    }, {
        "date": "2012-10-23",
        "value": 69
    }, {
        "date": "2012-10-24",
        "value": 67
    }, {
        "date": "2012-10-25",
        "value": 72
    }, {
        "date": "2012-10-26",
        "value": 77
    }, {
        "date": "2012-10-27",
        "value": 75
    }, {
        "date": "2012-10-28",
        "value": 70
    }, {
        "date": "2012-10-29",
        "value": 72
    }, {
        "date": "2012-10-30",
        "value": 70
    }, {
        "date": "2012-10-31",
        "value": 72
    }, {
        "date": "2012-11-01",
        "value": 73
    }, {
        "date": "2012-11-02",
        "value": 67
    }, {
        "date": "2012-11-03",
        "value": 68
    }, {
        "date": "2012-11-04",
        "value": 65
    }, {
        "date": "2012-11-05",
        "value": 71
    }, {
        "date": "2012-11-06",
        "value": 75
    }, {
        "date": "2012-11-07",
        "value": 74
    }, {
        "date": "2012-11-08",
        "value": 71
    }, {
        "date": "2012-11-09",
        "value": 76
    }, {
        "date": "2012-11-10",
        "value": 77
    }, {
        "date": "2012-11-11",
        "value": 81
    }, {
        "date": "2012-11-12",
        "value": 83
    }, {
        "date": "2012-11-13",
        "value": 80
    }, {
        "date": "2012-11-14",
        "value": 81
    }, {
        "date": "2012-11-15",
        "value": 87
    }, {
        "date": "2012-11-16",
        "value": 82
    }, {
        "date": "2012-11-17",
        "value": 86
    }, {
        "date": "2012-11-18",
        "value": 80
    }, {
        "date": "2012-11-19",
        "value": 87
    }, {
        "date": "2012-11-20",
        "value": 83
    }, {
        "date": "2012-11-21",
        "value": 85
    }, {
        "date": "2012-11-22",
        "value": 84
    }, {
        "date": "2012-11-23",
        "value": 82
    }, {
        "date": "2012-11-24",
        "value": 73
    }, {
        "date": "2012-11-25",
        "value": 71
    }, {
        "date": "2012-11-26",
        "value": 75
    }, {
        "date": "2012-11-27",
        "value": 79
    }, {
        "date": "2012-11-28",
        "value": 70
    }, {
        "date": "2012-11-29",
        "value": 73
    }, {
        "date": "2012-11-30",
        "value": 61
    }, {
        "date": "2012-12-01",
        "value": 62
    }, {
        "date": "2012-12-02",
        "value": 66
    }, {
        "date": "2012-12-03",
        "value": 65
    }, {
        "date": "2012-12-04",
        "value": 73
    }, {
        "date": "2012-12-05",
        "value": 79
    }, {
        "date": "2012-12-06",
        "value": 78
    }, {
        "date": "2012-12-07",
        "value": 78
    }, {
        "date": "2012-12-08",
        "value": 78
    }, {
        "date": "2012-12-09",
        "value": 74
    }, {
        "date": "2012-12-10",
        "value": 73
    }, {
        "date": "2012-12-11",
        "value": 75
    }, {
        "date": "2012-12-12",
        "value": 70
    }, {
        "date": "2012-12-13",
        "value": 77
    }, {
        "date": "2012-12-14",
        "value": 67
    }, {
        "date": "2012-12-15",
        "value": 62
    }, {
        "date": "2012-12-16",
        "value": 64
    }, {
        "date": "2012-12-17",
        "value": 61
    }, {
        "date": "2012-12-18",
        "value": 59
    }, {
        "date": "2012-12-19",
        "value": 53
    }, {
        "date": "2012-12-20",
        "value": 54
    }, {
        "date": "2012-12-21",
        "value": 56
    }, {
        "date": "2012-12-22",
        "value": 59
    }, {
        "date": "2012-12-23",
        "value": 58
    }, {
        "date": "2012-12-24",
        "value": 55
    }, {
        "date": "2012-12-25",
        "value": 52
    }, {
        "date": "2012-12-26",
        "value": 54
    }, {
        "date": "2012-12-27",
        "value": 50
    }, {
        "date": "2012-12-28",
        "value": 50
    }, {
        "date": "2012-12-29",
        "value": 51
    }, {
        "date": "2012-12-30",
        "value": 52
    }, {
        "date": "2012-12-31",
        "value": 58
    }, {
        "date": "2013-01-01",
        "value": 60
    }, {
        "date": "2013-01-02",
        "value": 67
    }, {
        "date": "2013-01-03",
        "value": 64
    }, {
        "date": "2013-01-04",
        "value": 66
    }, {
        "date": "2013-01-05",
        "value": 60
    }, {
        "date": "2013-01-06",
        "value": 63
    }, {
        "date": "2013-01-07",
        "value": 61
    }, {
        "date": "2013-01-08",
        "value": 60
    }, {
        "date": "2013-01-09",
        "value": 65
    }, {
        "date": "2013-01-10",
        "value": 75
    }, {
        "date": "2013-01-11",
        "value": 77
    }, {
        "date": "2013-01-12",
        "value": 78
    }, {
        "date": "2013-01-13",
        "value": 70
    }, {
        "date": "2013-01-14",
        "value": 70
    }, {
        "date": "2013-01-15",
        "value": 73
    }, {
        "date": "2013-01-16",
        "value": 71
    }, {
        "date": "2013-01-17",
        "value": 74
    }, {
        "date": "2013-01-18",
        "value": 78
    }, {
        "date": "2013-01-19",
        "value": 85
    }, {
        "date": "2013-01-20",
        "value": 82
    }, {
        "date": "2013-01-21",
        "value": 83
    }, {
        "date": "2013-01-22",
        "value": 88
    }, {
        "date": "2013-01-23",
        "value": 85
    }, {
        "date": "2013-01-24",
        "value": 85
    }, {
        "date": "2013-01-25",
        "value": 80
    }, {
        "date": "2013-01-26",
        "value": 87
    }, {
        "date": "2013-01-27",
        "value": 84
    }, {
        "date": "2013-01-28",
        "value": 83
    }, {
        "date": "2013-01-29",
        "value": 84
    }, {
        "date": "2013-01-30",
        "value": 81
    }]
});

chart.addListener("rendered", zoomChart);

zoomChart();

function zoomChart() {
    chart.zoomToIndexes(chart.dataProvider.length - 40, chart.dataProvider.length - 1);
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

</script>
// function google map
    <script>

      function initMap() {
        var myLatLng = {lat: -25.363, lng: 131.044};

        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 4,
          center: myLatLng
        });

        var marker = new google.maps.Marker({
          position: myLatLng,
          map: map,
          title: 'Hello World!'
        });
      }
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
#chartdivheart_fall {
	width	: 100%;
	height	: 250px;
}													
</style>

<style>
      /* Always set the map height explicitly to define the size of the div
       * element that contains the map. */
      #map {
            position: relative;
            width: 100%;
            height: 88vh;
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
				<li class="active"><a href="#tab0default" data-toggle="tab">Fall History</a></li>
                <li><a href="#tab1default" data-toggle="tab">Summary</a></li>
                <li><a href="#tab2default" data-toggle="tab">Calories</a></li>
                <li><a href="#tab3default" data-toggle="tab">Heart rate</a></li>
<!--                <li><a href="#tab4default" data-toggle="tab">อัตราความเร็วที่ใช้ในการเคลื่อนไหว</a></li>-->
				<li><a href="#tab5default" data-toggle="tab">Immobility</a></li>
				<li><a href="#tab6default" data-toggle="tab">Immobility Summary</a></li>				
            </ul>
            <div class="tab-content">
				<div id="tab0default" class="tab-pane fade in active">
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
							<!--<img src=https://image.flaticon.com/icons/svg/148/148976.svg>-->
							 <div id="map"></div>
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
                            <div class="icon"><img src="https://image.flaticon.com/icons/svg/149/149060.svg" width="30" height="30"></div>
                            <div class="fs20">Location : <font id="location"></font>ตลาดบางแค กทม.</div>
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
                        <div class="panel" style="margin-left:10px;margin-right:10px;">
                            <div id="chartdivheart_fall"></div>
                        </div>
                        <!--<div class="panel" style="color:#2d904f;margin-left:5px;margin-right:5px;">
                            <div class="icon"><img src="../images/icons/highlyactive.png" width="50" height="50"></div>
                            <div class="fs20">Highly Active time&nbsp;:&nbsp;<font id="highlyactive"></font></div>
                            <div class="fs15">Longest&nbsp;:&nbsp;<font id="lhighlyactive"></font></div>
                        </div>-->
                    </div>   
                </div>                                    
                <div id="tab1default" class="tab-pane fade">
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
