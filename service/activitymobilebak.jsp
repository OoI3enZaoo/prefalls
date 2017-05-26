<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@include file="../config.jsp"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
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
	double scalories = 0.0;
	int sismobile = 0;
	
	String sssn = (String)request.getParameter("SSSN");
	
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
		String sql = "SELECT SUM(step) AS SSTEP, SUM(calories) AS SCALORIES, SUM(ismobile) AS SISMOBILE FROM archive_" + sssn + " WHERE (DATE(tstamp) = CURRENT_DATE());";
		ResultSet rs = dbm.executeQuery(sql);
		
		if (rs.next()){
			sstep = rs.getInt("SSTEP");
			scalories = rs.getDouble("SCALORIES");
			sismobile = rs.getInt("SISMOBILE");
		}
		
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
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<script type="text/javascript" src="../js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="../js/amq_jquery_adapter.js"></script>
<script type="text/javascript" src="../js/amq.js"></script>
<script src="http://www.amcharts.com/lib/3/amcharts.js"></script>
<script src="http://www.amcharts.com/lib/3/pie.js"></script>
<script src="http://www.amcharts.com/lib/3/themes/light.js"></script>
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
	var notAvail = 86400 - sleep - stationary - active - hactive;	

	var lsleep = <%=lsleep%>;
	var lstationary = <%=lstationary%>;
	var lactive = <%=lactive%>;
	var lhactive = <%=lhactive%>;

	
	function init(){
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
           hr = message.getAttribute('hr');
		   sstep = sstep + parseInt(message.getAttribute('step'));
		   scalories = scalories + parseFloat(message.getAttribute('cal'));
		   actgroup = parseInt(message.getAttribute('act_group'));

		   if (message.getAttribute('ismobile')){
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

	  "dataProvider": [ {
		"title": "Sleep",
		"value": Math.round(((sleep/864) + 0.00001) * 100) / 100
	  }, {
		"title": "Stationary",
		"value": Math.round(((stationary/864) + 0.00001) * 100) / 100
	  } , {
		"title": "Active",
		"value": Math.round(((active/864) + 0.00001) * 100) / 100
	  }, {
		"title": "Highly Active",
		"value": Math.round(((hactive/864) + 0.00001) * 100) / 100
	  }, {
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
		document.getElementById("hr").innerHTML = Math.round(hr);
		document.getElementById("steps").innerHTML = numberWithCommas(sstep);
		document.getElementById("cal").innerHTML = Math.round(scalories * 100)/100;
		document.getElementById("sleep").innerHTML = showTime(sleep);
		document.getElementById("lsleep").innerHTML = showTime(lsleep);
		document.getElementById("stationary").innerHTML = showTime(stationary);
		document.getElementById("lstationary").innerHTML = showTime(lstationary);
		document.getElementById("active").innerHTML = showTime(active);
		document.getElementById("lactive").innerHTML = showTime(lactive);
		document.getElementById("highlyactive").innerHTML = showTime(hactive);		
		document.getElementById("lhighlyactive").innerHTML = showTime(lhactive);
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
.connn { height:auto; }
.asd { border-bottom: solid 1px #e1e1e1; margin:10px; padding-bottom:5px; }

@media (min-width:1000px){
	.chart { height:450px; }
	.asd { border-bottom: solid 1px #e1e1e1; margin:10px; padding-bottom:5px; font-size:20px; }
	.connn { height:500px; border-left: solid 1px #e1e1e1; }
}
</style>

</head>
<body onload="init()">
<div class="container">
   <div class="col-md-6 col-xs-12">
      <div id="chartdiv" class="chart"></div>
   </div>
   <div class="col-md-6 col-xs-12">
      <div class="connn">
      	
         <div class="asd"><img src="../images/icons/hr.png" width="30" height="30">&nbsp;Avg heart rate&nbsp;:&nbsp;<font id="hr"></font>&nbsp;bpm</div>
         <div class="asd"><img src="../images/icons/step.png" width="30" height="30">&nbsp;Steps&nbsp;:&nbsp;<font id="steps"></font></div>
         <div class="asd"><img src="../images/icons/cal.png" width="30" height="30">&nbsp;Cal burn&nbsp;:&nbsp;<font id="cal"></font></div>
		 <div class="asd"><img src="../images/icons/sleep.png" width="30" height="30">&nbsp;Sleep time&nbsp;:&nbsp;<font id="sleep"></font><br/>
		 &nbsp;&nbsp;Longest Sleep time&nbsp;:&nbsp;<font id="lsleep"></font>
		 </div>		 
         <div class="asd"><img src="../images/icons/stattime.png" width="30" height="30">&nbsp;Stationary time&nbsp;:&nbsp;<font id="stationary"></font><br/>
		 &nbsp;&nbsp;Longest Stationary time&nbsp;:&nbsp;<font id="lstationary"></font></div>
         <div class="asd"><img src="../images/icons/active.png" width="30" height="30">&nbsp;Active time&nbsp;:&nbsp;<font id="active"></font><br/>
		 &nbsp;&nbsp;Longest Active time&nbsp;:&nbsp;<font id="lactive"></font></div>
         <div class="asd"><img src="../images/icons/highlyactive.png" width="30" height="30">&nbsp;Highly Active time&nbsp;:&nbsp;<font id="highlyactive"></font><br/>
		 &nbsp;&nbsp;Longest Highly Active time&nbsp;:&nbsp;<font id="lhighlyactive"></font></div>
      </div>
   </div>
</div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>	