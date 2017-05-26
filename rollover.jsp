<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@include file="config.jsp"%>
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
	
	String acttype = "\'{\"activity\": [";
	String activity = "\'{\"allactivity\": [";

    String sssn = (String)session.getAttribute("SSSN");
	String name = "";

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
<script src="js/amcharts/themes/light.js"></script>
<script type="text/javascript">
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
		
		updateChart();		
	}
	
    var amq = org.activemq.Amq;
    amq.init({ 
     uri: 'amq',
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
		   updateChart();		   
        },
        myId: 'test0',
        myDestination: 'topic://<%=sssn%>_pred'
      };
    
	amq.addListener(myHandler.myId, myHandler.myDestination,myHandler.rcvMessage);

	
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
	
	function updateChart(){
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
    
}
</style>

</head>
<body onload="init()">
<nav class="navbar navbar-default navbar-static-top">
   <div class="container-fluid">
      <div class="navbar-header">
         <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>  
         </button>
         <a class="header-brand" href="./listname/"><img src="images/logo.png"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav">
            <li class="active"><a href="activity.jsp">กิจกรรมประจำวัน</a></li>
            <li><a href="./history/">ประวัติกิจกรรม</a></li>
            <li><a href="./notifications/">บันทึกการแจ้งเตือน</a></li>
            <li><a href="./comment/">คำแนะนำแพทย์</a></li>
            <li><a href="./mobility/">บันทึกผลการทดสอบ</a></li>
            <li><a href="./profile/">ข้อมูลส่วนตัว</a></li>
            <li class="end"><a href="./setting/">ตั้งค่า</a></li>
         </ul>
         <ul class="nav navbar-nav navbar-right">
            <li><a><%=ssfn%></a></li>
            <li><a href="logout.jsp">ออกจากระบบ</a></li>
         </ul>
      </div>
   </div>
</nav>
<div class="container">
	<div class="panel"><font class="fs17">กิจกรรมประจำวันที่&nbsp;&nbsp;>&nbsp;&nbsp;<span id="curdate"></span><span id="patient" class="right"></span></font></div>
	<ul class="nav nav-tabs" style="margin-left:10px;margin-right:10px;">
		<li class="active"><a data-toggle="tab" href="#summary"><font class="s17">Summary Data</font></a></li>
		<li><a data-toggle="tab" href="#activity"><font class="s17">Activity Detail</font></a></li>
	</ul>
	<div class="tab-content">
        <div id="summary" class="tab-pane fade in active">
            <div class="col-md-6 col-xs-12">
                <div class="panel" style="margin-left:5px;margin-right:5px;">
                    <div id="chartdiv" class="chart"></div>
                </div>
            </div>
            <div class="col-md-6 col-xs-12">
                <div class="panel" style="margin-left:5px;margin-right:5px;">
                    <div class="fs20">&nbsp;Current Activity&nbsp;:&nbsp;<span id="curact"></span>&nbsp;</div>
                </div>
            </div>
            <div class="col-md-6 col-xs-12">
                <div class="row" style="margin-left:0px;margin-right:0px;">
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#ea5f5c;">
                            <div class="fs20"><img src="images/icons/hr.png" width="30" height="30">&nbsp;<font id="hr"></font>&nbsp;bpm</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;;color:#f57a3e;">
                            <div class="fs20"><img src="images/icons/cal.png" width="30" height="30">&nbsp;<font id="cal"></font>&nbsp;calories</div>
                        </div>
                    </div>
                </div>
            </div>    
            <div class="col-md-6 col-xs-12">
                <div class="row" style="margin-left:0px;margin-right:0px;">
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#2d904f;">
                            <div class="fs20"><img src="images/icons/step.png" width="30" height="30">&nbsp;<font id="steps"></font>&nbsp;Steps</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel" style="margin-left:0px;margin-right:0px;color:#2f4074;">
                            <div class="fs20"><img src="images/icons/distance.png" width="30" height="30">&nbsp;distance&nbsp;:&nbsp;<font id="dist"></font>&nbsp;m</div>
                        </div>
                    </div>
                </div>
            </div> 
            <div class="col-md-6 col-xs-12">
                <div class="panel" style="color:#2f4074;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="images/icons/sleep.png" width="50" height="50"></div>
                    <div class="fs20">Sleep time&nbsp;:&nbsp;<font id="sleep"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lsleep"></font></div>
                </div>	
                <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="images/icons/stattime.png" width="50" height="50"></div>
                    <div class="fs20">Stationary time&nbsp;:&nbsp;<font id="stationary"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lstationary"></font></div>
                </div>
                <div class="panel" style="color:#f57a3e;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="images/icons/active.png" width="50" height="50"></div>
                    <div class="fs20">Active time&nbsp;:&nbsp;<font id="active"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lactive"></font></div>
                </div>
                <div class="panel" style="color:#2d904f;margin-left:5px;margin-right:5px;">
                    <div class="icon"><img src="images/icons/highlyactive.png" width="50" height="50"></div>
                    <div class="fs20">Highly Active time&nbsp;:&nbsp;<font id="highlyactive"></font></div>
                    <div class="fs15">Longest&nbsp;:&nbsp;<font id="lhighlyactive"></font></div>
                </div>
            </div>
        </div>
        <div id="activity" class="tab-pane fade">
            <div class="panel">
                <div id="chartdiv2" class="chart"></div>
            </div>
        </div>
    </div>
</div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>