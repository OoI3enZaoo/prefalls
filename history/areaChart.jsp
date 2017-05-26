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

    int clRunning = 0;
    int clCycling = 0;
    int clStairg = 0;
    int clWalking = 0;
    int clStanding = 0;
    int clSitting = 0;
    int clLying =0;
    int clLySleep =0;

    String calories ="";
    String activity = "\'{\"allactivity\": [";
    String pace = "\'{\"allpace\": [";
    //String colorie = "\'{\"allcolorie\": [";
	dbm.createConnection();

	try {

		//String sql = "select * from `activitylog` where SSSN = '"+sssn+"' and actDate = '"+date+"';" ;
        String sql = "select max(long_active) as long_active ,max(long_hactive) as long_hactive,max(long_stationary) as long_stationary,max(long_sleep) as long_sleep,avg(hr) as hr,sum(step) as step,sum(calories) as calories from archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
        
        
		ResultSet rs = dbm.executeQuery(sql);

		while((rs!=null) && (rs.next())){

			active = rs.getString("long_active");
            hactive = rs.getString("long_hactive");
            stationary = rs.getString("long_stationary");
            sleep = rs.getString("long_sleep");
            
            hr = rs.getInt("hr");
            step = rs.getString("step");
            calories = rs.getString("calories");

		}
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
		/*try {
			String grCL = "SELECT `calories`,`act_type` FROM archive_"+sssn+" where DATE_FORMAT(tstamp,'%Y-%m-%d')= '"+date+"'";
			ResultSet cl= dbm.executeQuery(grCL);
				if (pc.next()){
					pace = pace + "{\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"pace\":\"" + pc.getInt("pace") + "\"}";
				}
				while(pc.next()){
					pace = pace + ", {\"timestamp\":\"" + pc.getString("MILLISECONDS") + "\" , \"pace\":\"" + pc.getInt("pace") + "\"}";
				}
				pace = pace + "]}\'";
				}
				out.print(clRunning);
				
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}*/
		
	} catch (Exception e) {
		out.println(e.getMessage());
		e.printStackTrace();
	}
		
	dbm.closeConnection();
	
%>
<!doctype html>
<html>
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
<link rel="stylesheet" type="text/css" href="../css/fullcalendar/navtabs.css"/>
<!-- JS amCharts File -->
<script type="text/javascript" src="../js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>
<script src="../js/amcharts/amcharts.js"></script>
<script src="../js/amcharts/themes/light.js"></script>
<!-- JS ChartColumn amCharts File -->
<script src="../js/amcharts/serial.js"></script>
<!-- JS ChartDonut  amCharts File -->
<script src="../js/amcharts/pie.js"></script>
<!--JS-->

<script>

var sit = <%=sit%>;
	var as = <%=as%>;
	var cycling = <%=cycling%>;
	
	var count = <%=count%>;	
	var activity = <%=activity%>;
	var pace = <%=pace%>;
	var	jsonpace = JSON.parse(pace);
	var jsonactivity = JSON.parse(activity);

	//<sensor-reading id='1' ts='1449342613' pid='MA36PB256Y' lat='13.779152' lng='100.556808' acc='20' alt='5.0' spd='10.45' dist='3.21' bearing='3.22' hr='87' steps='1' spo2='98' acl='{0,1.2,1.1,1.3,1.1}' act='1' />
	var lat = 0;
    var lng = 0;
	var spo2 = 0;
	var act = 0;


//var chartData = generateChartData();
var chartData = ChartDataPace();
console.log(chartData);

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
    // now set 500 minutes back
    firstDate.setMinutes(firstDate.getDate() - 1000);

    // and generate 500 data items
    for (var i = 0; i < 500; i++) {
        var newDate = new Date(firstDate);
        // each time we add one minute
        newDate.setMinutes(newDate.getMinutes() + i);
        // some random number
        var visits = Math.round(Math.random() * 40 + 10 + i + Math.random() * i / 5);
        // add data item to the array
        chartData.push({
            date: newDate,
            visits: visits
        });
    }
    return chartData;
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
</script>
<style type="text/css">
	#chartdiv {
	width	: 100%;
	height	: 500px;
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
						</div>
						<div class="tab-pane fade" id="tab2default">
							Comming Soon
						</div>
						<div class="tab-pane fade" id="tab3default">
                            Comming Soon
                        </div>
						<div class="tab-pane fade" id="tab4default">
							Comming Soon
						</div>
						<div class="tab-pane fade" id="tab5default" style="width: 100%; height: 500px;">
							<div id="chartdiv"></div>
						</div>
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