<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
    String date = request.getParameter("date");
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}
    
    String sssn = (String)session.getAttribute("SSSN");
    String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + session.getAttribute("fname") + " " + (String)session.getAttribute("lname") + " ";
    String result = "";
    Double total = 0.0 ,fw = 0.0 ,rt = 0.0 ,t = 0.0 ,sitst = 0.0 ,stsit = 0.0;
    Double total2 = 0.0 ,fw2 = 0.0 ,rt2 = 0.0 ,t2 = 0.0 ,sitst2 = 0.0 ,stsit2 = 0.0;
    String date2 = "";	
    dbm.createConnection();

    try {

        String sql = "SELECT * FROM `MobilityTest` WHERE `SSSN` = '"+sssn+"' AND `start` = '"+date+"';" ;
        ResultSet rs = dbm.executeQuery(sql);

        if(rs.next()){        				
            rs.first();
            total = rs.getDouble("time_total");
            fw = rs.getDouble("time_forward");
            rt = rs.getDouble("time_return");
            t = rs.getDouble("time_turn");
            sitst = rs.getDouble("time_sit2stand");
            stsit = rs.getDouble("time_stand2sit");           
            
        }

    } catch (Exception e) {
        out.println(e.getMessage());
        e.printStackTrace();
    }
    
    try {

        String sql = "SELECT * FROM `MobilityTest` WHERE `SSSN` = '"+sssn+"' AND `start` != '"+date+"';" ;
        ResultSet rs = dbm.executeQuery(sql);

        if(rs.next()){        				
            rs.first();
            date2 = rs.getString("start");
            total2 = rs.getDouble("time_total");
            fw2 = rs.getDouble("time_forward");
            rt2 = rs.getDouble("time_return");
            t2 = rs.getDouble("time_turn");
            sitst2 = rs.getDouble("time_sit2stand");
            stsit2 = rs.getDouble("time_stand2sit");           
            
        }

    } catch (Exception e) {
        out.println(e.getMessage());
        e.printStackTrace();
    }
    dbm.closeConnection();
    if(total>13.5){
        result = "Fall risk ";                
    } else if(total>13.5){
        result = "High fall risk";
    } else {
        result = "Normal";
    }
    
    
    date = "\""+date+"\""; 
    date2 = "\""+date2+"\""; 
    result = "\""+result+"\""; 
	
%>

<!doctype html>
<head>
<title>mobilise</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<script src="../js/amcharts/amcharts.js"></script>
<script src="../js/amcharts/radar.js"></script>
<script src="../js/amcharts/serial.js"></script>
<script src="../js/amcharts/themes/light.js"></script>
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
#chartdiv {
	width		: 100%;
	height		: 500px;
	font-size	: 11px;
}
#chart2 {
	width		: 100%;
	height		: 500px;
	font-size	: 11px;
}									

@media (min-width:1000px){
    
	.chart { height:450px; }
	.asd { margin:10px; padding-bottom:5px; font-size:20px; }
    .connn { height:500px; border-left: solid 1px #e1e1e1; }
    
}
    
</style>
<script type="text/javascript">    

    var total = 0.0;
    var fw = 0.0;
    var rt = 0.0;
    var t = 0.0;
    var sitst = 0.0;
    var stsit = 0.0;    
    var date = "N/A" ;
    var result = <%=result%>;
    date = <%=date%>;
    total = <%=total%>;
    fw = <%=fw%>;
    rt = <%=rt%>;
    t = <%=t%>;
    sitst = <%=sitst%>;
    stsit = <%=stsit%>;
    
    var total2 = 0.0;
    var fw2 = 0.0;
    var rt2 = 0.0;
    var t2 = 0.0;
    var sitst2 = 0.0;
    var stsit2 = 0.0;    
    var date2 = "N/A" ;
    date2 = <%=date2%>;
    total2 = <%=total2%>;
    fw2 = <%=fw2%>;
    rt2 = <%=rt2%>;
    t2 = <%=t2%>;
    sitst2 = <%=sitst2%>;
    stsit2 = <%=stsit2%>;
    
    var chart = AmCharts.makeChart( "chartdiv", {
    "type": "radar",
    "theme": "light",
    "dataProvider": [ {
    "category": "Stand to sit duration",
    "value": (stsit/total) *100
    }, {
    "category": "Turn\n duration",
    "value": (t/total) *100
    }, {
    "category": "Forward duration",
    "value": (fw/total) *100
    }, {
    "category": "Return duration",
    "value": (rt/total) *100
    }, {
    "category": "Sit to stand\n duration",
    "value": (sitst/total) *100
    }],
    "valueAxes": [ {
    "axisTitleOffset": 15,
    "minimum": 0,
     "maximum":100,     
    "axisAlpha": 0.15
    } ],
    "startDuration": 2,
    "graphs": [ {
    "balloonText": "[[value]] % of TUG duration",
    "bullet": "round",
    "valueField": "value"
    } ],
    "categoryField": "category",
    "centerLabels":false,
    "export": {
    "enabled": true
    }
    } );
   
   var chart2 = AmCharts.makeChart( "chart2", {
  "type": "serial",
  "theme": "light", 
  "dataProvider": [ {
    "date": date,
    "Sit to stand duration": sitst,
    "Stand to sit duration": stsit,
    "Turn duration": t,
     "Forward duration" : fw ,
     "Return duration" :rt, 
	 "TUG duration": total
  },{
    "date": date2,
    "Sit to stand duration": sitst2,
    "Stand to sit duration": stsit2,
    "Turn duration": t2,
     "Forward duration" : fw2 ,
     "Return duration" :rt2, 
	 "TUG duration": total2
  } ],
  "valueAxes": [ {
    "gridColor": "#FFFFFF",
    "gridAlpha": 0.2,
    "dashLength": 0
  } ],
  "gridAboveGraphs": true,
  "startDuration": 1,
  "graphs": [ {
    "balloonText": "Sit to stand duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "Sit to stand duration", 
	"legendValueText": "Sit to stand duration"
  },
             {
    "balloonText": "Stand to sit duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "Stand to sit duration", 
	"legendValueText": "Stand to sit duration"
  },
             {
    "balloonText": "Forward duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "Forward duration", 
	"legendValueText": "Forward duration"
  },
             {
    "balloonText": "Return duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "Return duration", 
	"legendValueText": "Return duration"
  },
  {
    "balloonText": "Turn duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "Turn duration", 
	"legendValueText": "Turn duration"
  }, 
  {
    "balloonText": "TUG duration: <b>[[value]]</b>",
    "fillAlphas": 0.8,
    "lineAlpha": 0.2,
    "type": "column",
    "valueField": "TUG duration", 
	"legendValueText": "TUG duration"
  }],
  "chartCursor": {
    "categoryBalloonEnabled": false,
    "cursorAlpha": 0,
    "zoomable": false
  },
  "categoryField": "date",
  "categoryAxis": {
    "gridPosition": "start",
    "gridAlpha": 0,
    "tickPosition": "start",
    "tickLength": 20
  },
  "export": {
    "enabled": true
  }

} );
    
    function load(){
        document.getElementById("date").innerHTML = date ;
        document.getElementById("total").innerHTML = total ;
        document.getElementById("fw").innerHTML = fw ;
        document.getElementById("rt").innerHTML = rt ;
        document.getElementById("t").innerHTML = t ;
        document.getElementById("sitst").innerHTML = sitst ;
        document.getElementById("stsit").innerHTML = stsit ;
        document.getElementById("result").innerHTML = result ;
		var legend = new AmCharts.AmLegend();
		legend.data = [{title: "Sit to stand duration", color: "#85C5E3"},{title: "Stand to sit duration", color: "#FDDC33"},{title: "Forward duration", color: "#9CC580"},{title: "Return duration", color: "#D66B6C"},{title: "Turn duration", color: "#D79BBD"} ,{title: "TUG duration", color: "#58668F"}];
		chart2.addLegend(legend);
		chart2.validateNow();
    }
    
</script>
</head>
<body onload="load()">

<%@include file="../include/nav.jsp"%> 

<div class="container">
   <div class="panel"><font class="fs17">Assessment Log<span id="patient" class="right"><%=name%></span></font></div>
   <div class="row">
		<div class="col-md-12">
            <ul class="nav nav-tabs" style="margin-left:10px;margin-right:10px;">
                <li class="active"><a href="#tab1default" data-toggle="tab">Summary</a></li>
                <li><a href="#tab2default" data-toggle="tab">Assessment Chart</a></li>
            </ul>
            <div class="tab-content">                                               
                <div id="tab1default" class="tab-pane fade in active">
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
                            <div id="chartdiv"></div>
                        </div>
                    </div>
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
                            <div class="fs20"><img src="../images/icons/mobility/experiment-results.png" width="30" height="30">&nbsp;Test results&nbsp;:&nbsp;<span id="result"></span>&nbsp;</div>
                        </div>
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
                            <div class="fs20"><img src="../images/icons/mobility/starttime.png" width="30" height="30">&nbsp;Start time&nbsp;:&nbsp;<span id="date"></span>&nbsp;</div>
                        </div>
                        <div class="panel" style="margin-left:5px;margin-right:5px;">
                            <div class="fs20"><img src="../images/icons/mobility/duration.png" width="30" height="30">&nbsp;TUG Duration (s)&nbsp;:&nbsp;<span id="total"></span>&nbsp;</div>
                        </div>
                        <div class="panel" style="margin-left:5px;margin-right:5px;color:#f57a3e;">
                            <div class="fs20"><img src="../images/icons/mobility/runer-silhouette-running-fast.png" width="30" height="30">&nbsp;<font id="cal"></font>AVG Pace : 2.3km/h</div>
                        </div>
                        <div class="panel" style="margin-left:5px;margin-right:5px;color:#2f4074;">
                            <div class="fs20"><img src="../images/icons/mobility/heart-with-electrocardiogram.png" width="30" height="30">&nbsp;<font id="dist"></font>AVG HR : 96 bpm</div>
                        </div>
                        <div class="panel" style="margin-left:5px;margin-right:5px;color:#2f4074;">
                            <div class="fs20"><img src="../images/icons/mobility/arrow-in-u-shape-to-turn.png" width="30" height="30">Turn duration (s)&nbsp;:&nbsp;<font id="t"></font></div>
                        </div>
                    </div>
                    <!--div class="col-md-6 col-xs-12">
                        <div class="row" style="margin-left:0px;margin-right:0px;">
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;color:#ea5f5c;">
                                    <div class="fs20"><img src="" width="30" height="30">&nbsp;<font id="hr"></font>AVG spo2 : 97%</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;;color:#f57a3e;">
                                    <div class="fs20"><img src="../images/icons/mobility/runer-silhouette-running-fast.png" width="30" height="30">&nbsp;<font id="cal"></font>AVG Pace : 2.3km/h</div>
                                </div>
                            </div>
                        </div>
                    </div>    
                    <div class="col-md-6 col-xs-12">
                        <div class="row" style="margin-left:0px;margin-right:0px;">
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;color:#2f4074;">
                                    <div class="fs20"><img src="" width="30" height="30">&nbsp;<font id="dist"></font>AVG HR : 96 bpm</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="panel" style="margin-left:0px;margin-right:0px;color:#2d904f;">
                                    <div class="fs20"><img src="" width="30" height="30">&nbsp;<font id="steps"></font>432 Steps</div>
                                </div>
                            </div>
                        </div>
                    </div--> 
                    <div class="col-md-6 col-xs-12">
                        <div class="panel" style="color:#2f4074;margin-left:5px;margin-right:5px;">
                            <div class="icon"><img src="../images/icons/mobility/waiting-room-sign.png" width="50" height="50"></div>
                            <div class="fs20">Sit to Stand duration (s)&nbsp;:&nbsp;<font id="sitst"></font></div>
                            <div class="fs15">Stand to Sit duration (s)&nbsp;:&nbsp;<font id="stsit"></font></div>
                        </div>	
                        <div class="panel" style="color:#ea5f5c;margin-left:5px;margin-right:5px;">
                            <div class="icon"><img src="../images/icons/mobility/fast-forward-media-control-button.png" width="50" height="50"></div>
                            <div class="fs20">Forward duration (s)&nbsp;:&nbsp;<font id="fw"></font></div>
                            <div class="fs15">Return duration (s)&nbsp;:&nbsp;<font id="rt"></font></div>
                        </div>
                    </div>
                </div>    
                <div class="tab-pane fade" id="tab2default">
                    <div class="panel" style="margin-left:10px;margin-right:10px;">
                        <div id="chart2"></div>	
                    </div>
                </div>
            </div>
        </div>
	</div>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>