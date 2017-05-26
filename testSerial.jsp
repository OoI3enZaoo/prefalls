<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@include file="config.jsp"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	String pace = "\'{\"allpace\": [";
	dbm.createConnection();	
	try {
		String sql = "SELECT UNIX_TIMESTAMP(tstamp) * 1000 AS MILLISECONDS, pace FROM archive_MA36PB256Y WHERE (DATE(tstamp) = '2016-02-13');";
		ResultSet rs = dbm.executeQuery(sql);
		if (rs.next()){
			pace = pace + "{\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"pace\":\"" + rs.getInt("pace") + "\"}";
		}
		while(rs.next()){
			pace = pace + ", {\"timestamp\":\"" + rs.getString("MILLISECONDS") + "\" , \"pace\":\"" + rs.getInt("pace") + "\"}";
		}
		pace = pace + "]}\'";
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
<link rel="Shortcut Icon" href="images/icon.png"/>
<link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="js/amq.js"></script>
<script src="js/amcharts/amcharts.js"></script>
<script src="js/amcharts/pie.js"></script>
<script src="js/amcharts/xy.js"></script>
<script src="js/amcharts/serial.js"></script>
<script src="js/amcharts/themes/light.js"></script>
<script type="text/javascript">
	var mypace = JSON.parse(<%=pace%>);
		
            var chart = AmCharts.makeChart("chartDiv", {
                type: "serial",
                dataProvider: [],
                categoryField: "time",
                categoryAxis: {
                    gridAlpha: 0.15,
                    minorGridEnabled: true,
                    axisColor: "#DADADA"
                },
                valueAxes: [{
                    axisAlpha: 0.2,
                    id: "v1"
                }],
                graphs: [{
                    title: "red line",
                    id: "g1",
                    valueAxis: "v1",
                    valueField: "pace",
                    bullet: "round",
                    bulletBorderColor: "#FFFFFF",
                    bulletBorderAlpha: 1,
                    lineThickness: 2,
                    lineColor: "#b5030d",
                    negativeLineColor: "#0352b5",
                    balloonText: "[[category]]<br><b><span style='font-size:14px;'>value: [[value]]</span></b>"
                }],
                chartCursor: {
                    fullWidth:true,
                    cursorAlpha:0.1
                },
                chartScrollbar: {
                    scrollbarHeight: 40,
                    color: "#FFFFFF",
                    autoGridCount: true,
                    graph: "g1"
                },

                mouseWheelZoomEnabled:true
            });
		
	function init(){
		for (var i = 0; i < pace.allpace.length; i++) { 
			chart.dataProvider.push({"time": parseInt(mypace.allpace[i].timestamp), "pace": parseInt(mypace.allpace[i].pace)});
			chart.validateNow();
		}	
	}
</script>

<style>
.chart { width:100%; height:500px; }
.col-md-6 { padding-left: 5px; padding-right: 5px; }
.icon { float:left; margin-right: 10px; }

@media (min-width:1000px){
    
	.chart { height:450px; }
	.asd { margin:10px; padding-bottom:5px; font-size:20px; }
    
}
</style>

</head>
<body onload="init()">
<div id="chartDiv"></div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>	