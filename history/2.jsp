<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
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
	
	int sit = 0;
	int stand = 0;
	int walk = 0;
	int as = 0;
	int run = 0;
	int cycling =0;
	
	int avghr = 0;
	int count = 0;

	String date = request.getParameter("date");
	String active ="";
	String hactive ="";
	String stationary ="";
	String sleep ="";
    int hr =0;
    String step ="";
    String calories ="";
    String activity = "\'{\"allactivity\": [";
	
	dbm.createConnection();

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

	dbm.createConnection();

	try {

		//String sql = "select * from `activitylog` where SSSN = '"+sssn+"' and actDate = '"+date+"';" ;
        String sql = "select max(long_active) as long_active ,max(long_hactive) as long_hactive,max(long_stationary) as long_stationary,max(long_sleep) as long_sleep,avg(hr) as hr,sum(step) as step,sum(calories) as calories from archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
        
        
		ResultSet rs = dbm.executeQuery(sql);

		/*while((rs!=null) && (rs.next())){

			active = rs.getString("long_active");
            hactive = rs.getString("long_hactive");
            stationary = rs.getString("long_stationary");
            sleep = rs.getString("long_sleep");
            
            hr = rs.getInt("hr");
            step = rs.getString("step");
            calories = rs.getString("calories");
            
            session.setAttribute("hr", hr);

		}*/
		try {
			String grHR = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, hr FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
			ResultSet gr= dbm.executeQuery(grHR);
				if (gr.next()){
					activity = activity + "{\"timestamp\":\"" + gr.getString("MILLISECONDS") + "\" , \"hr\":\"" + gr.getInt("hr") + "\"}";
				}
				while(gr.next()){
					activity = activity + ", {\"timestamp\":\"" + gr.getString("MILLISECONDS") + "\" , \"hr\":\"" + gr.getInt("hr") + "\"}";
				}
				activity = activity + "]}\'";
				out.print(activity);
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}	
		//out.print(activity);
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
<link rel="Shortcut Icon" href="../images/icon.png"/>
<!-- CSS Main File-->
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<!-- CSS Panels with nav tabs File -->
<link rel="stylesheet" type="text/css" href="css/navtabs.css"/>
<!-- JS amCharts File -->
<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="js/amq.js"></script>
<script src="http://www.amcharts.com/lib/3/amcharts.js"></script>
<script src="http://www.amcharts.com/lib/3/themes/light.js"></script>
<!-- JS ChartColumn amCharts File -->
<script src="http://www.amcharts.com/lib/3/serial.js"></script>
<!-- JS ChartDonut  amCharts File -->
<script src="http://www.amcharts.com/lib/3/pie.js"></script>
<!--JS-->
<script src="https://www.amcharts.com/lib/3/serial.js"></script>

<script type="text/javascript">
	
	var sit = <%=sit%>;
	var as = <%=as%>;
	var cycling = <%=cycling%>;
	
	var count = <%=count%>;	

	//<sensor-reading id='1' ts='1449342613' pid='MA36PB256Y' lat='13.779152' lng='100.556808' acc='20' alt='5.0' spd='10.45' dist='3.21' bearing='3.22' hr='87' steps='1' spo2='98' acl='{0,1.2,1.1,1.3,1.1}' act='1' />
	var lat = 0;
    var lng = 0;
	var spo2 = 0;
	var act = 0;
	
	// Donut chart
	var chart = AmCharts.makeChart( "chartdonut", {

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
		"title": "Sleep " + <%=sleep%> + "%" ,
		"value": <%=sleep%>
	  }, {
		"title": "Stationary " + <%=stationary%> + "%",
		"value": <%=stationary%>
	  } , {
		"title": "Active " + <%=active%> + "%" ,
		"value": <%=active%>
	  }, {
		"title": "Highlyactive " + <%=hactive%> + "%",
		"value": <%=hactive%>
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
	var chart = AmCharts.makeChart("chartcolumn", {
	  "type": "serial",
	  "theme": "light",
	  "marginRight": 70,
	  "dataProvider": [{
	    "country": "USA",
	    "visits": 3025,
	    "color": "#FF0F00"
	  }, {
	    "country": "China",
	    "visits": 1882,
	    "color": "#FF6600"
	  }, {
	    "country": "Japan",
	    "visits": 1809,
	    "color": "#FF9E01"
	  }, {
	    "country": "Germany",
	    "visits": 1322,
	    "color": "#FCD202"
	  }, {
	    "country": "UK",
	    "visits": 1122,
	    "color": "#F8FF01"
	  }, {
	    "country": "France",
	    "visits": 1114,
	    "color": "#B0DE09"
	  }, {
	    "country": "India",
	    "visits": 984,
	    "color": "#04D215"
	  }, {
	    "country": "Spain",
	    "visits": 711,
	    "color": "#0D8ECF"
	  }, {
	    "country": "Netherlands",
	    "visits": 665,
	    "color": "#0D52D1"
	  }, {
	    "country": "Russia",
	    "visits": 580,
	    "color": "#2A0CD0"
	  }, {
	    "country": "South Korea",
	    "visits": 443,
	    "color": "#8A0CCF"
	  }, {
	    "country": "Canada",
	    "visits": 441,
	    "color": "#CD0D74"
	  }],
	  "valueAxes": [{
	    "axisAlpha": 0,
	    "position": "left",
	    "title": "Visitors from country"
	  }],
	  "startDuration": 1,
	  "graphs": [{
	    "balloonText": "<b>[[category]]: [[value]]</b>",
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

    //121321
    var chartData = generateChartData();

    var chart = AmCharts.makeChart("chartdiv", {
        "type": "serial",
        "theme": "light",
        "marginRight": 80,
        "dataProvider": chartData,
        "valueAxes": [{
            "position": "left",
            "title": "Unique visitors"
        }],
        "graphs": [{
            "id": "g1",
            "fillAlphas": 0.4,
            "valueField": "visits",
             "balloonText": "<div style='margin:5px; font-size:19px;'>Visits:<b>[[value]]</b></div>"
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

    chart.addListener("dataUpdated", zoomChart);
    // when we apply theme, the dataUpdated event is fired even before we add listener, so
    // we need to call zoomChart here
    zoomChart();
    // this method is called when chart is first inited as we listen for "dataUpdated" event
    function zoomChart() {
        // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
        chart.zoomToIndexes(chartData.length - 250, chartData.length - 100);
    }

    // generate some random data, quite different range
    function generateChartData() {
        var chartData = [];
        // current date
        var firstDate = new Date();

        for (var i = 0; i < <%out.println(session.getAttribute("hr"));%>; i++) {
            var newDate = new Date(firstDate);
            // each time we add one minute
            newDate.setMinutes(newDate.getMinutes() + i);
            // some random number
            var visits = <>;
            // add data item to the array
            chartData.push({
                date: newDate,
                visits: visits
        });
        
        }
        return chartData;
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

#chartcolumn {
	width		: 100%;
	height		: 500px;
	font-size	: 11px;  
}										

.amcharts-export-menu-top-right {
  top: 10px;
  right: 0;
}

#chartdiv {
	width	: 100%;
	height	: 500px;
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
		<a class="header-brand" href="../listname/"><img src="../images/logo.png"></a>
		</div>
		<div id="navbar" class="navbar-collapse collapse">
		<ul class="nav navbar-nav navbar-right">
			<li><a><%=ssfn%></a></li>
			<li><a href="../logout.jsp">ออกจากระบบ</a></li>
		</ul>
		</div>
	</div>
</nav>
<div class="container">
	<div class="container-header line"><font class="s17">กิจกรรมประจำวัน</font></div>
	<div class="row">
		<div class="col-md-12">
			<div class="panel with-nav-tabs panel-default">
				<div class="panel-heading">
					<ul class="nav nav-tabs">
						<li class="active"><a href="#tab1default" data-toggle="tab">ข้อมูลสรุป</a></li>
						<li><a href="#tab2default" data-toggle="tab">ประมาณแคลอรี่</a></li>
						<li><a href="#tab3default" data-toggle="tab">อัตราการเต้นของหัวใจ</a></li>
						<li><a href="#tab4default" data-toggle="tab">ปริมาณออกซิเจนในเลือด</a></li>
						<li><a href="#tab5default" data-toggle="tab">อัตราความเร็วที่ใช้ในการเคลื่อนไหว</a></li>
					</ul>
				</div>
				<div class="panel-body">
					<div class="tab-content">
						<div class="tab-pane fade in active" id="tab1default">
							<div class="row">
								<div class="col-md-6 col-xs-12">
									<div id="chartdonut" class="chart"></div>
								</div>
								<div class="col-md-6 col-xs-12">
									<div class="connn">
										<div class="asd"><img src="../images/icons/hr.png" width="30" height="30">&nbsp;Avg heart rate&nbsp;:&nbsp;<font id="hr"><%=hr%></font>&nbsp;bpm</div>
										<div class="asd"><img src="../images/icons/step.png" width="30" height="30">&nbsp;Steps&nbsp;:&nbsp;<font id="steps"><%=step%></font></div>
										<div class="asd"><img src="../images/icons/cal.png" width="30" height="30">&nbsp;Cal burn&nbsp;:&nbsp;<font id="cal"><%=calories%></font></div>
										<div class="asd"><img src="../images/icons/stattime.png" width="30" height="30">&nbsp;Stationary time&nbsp;:&nbsp;<font id="stationary"><%out.print(sit+stand);%></font></div>
										<div class="asd"><img src="../images/icons/active.png" width="30" height="30">&nbsp;Active time&nbsp;:&nbsp;<font id="active"><%out.print(walk+as);%></font></div>
										<div class="asd"><img src="../images/icons/highlyactive.png" width="30" height="30">&nbsp;Highlyactive time&nbsp;:&nbsp;<font id="highlyactive"><%out.print(run+cycling);%></font></div>
									</div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade" id="tab2default">
							<div id="chartcolumn"></div>
						</div>
						<div class="tab-pane fade" id="tab3default">
                            <div id="chartdiv"></div>
                        </div>
						<div class="tab-pane fade" id="tab4default">Default 4</div>
						<div class="tab-pane fade" id="tab5default">Default 5</div>
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
