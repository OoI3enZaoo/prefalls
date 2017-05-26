<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	int ID = 1;
   String SSSN ="MA36PB256Y";
   int Hours = 0;
   int Minuts = 0;
   int Second = 0;
   String latit = "13.7784707";
   String logit = "100.5599263";

   Random rand = new Random();
   int HR = rand.nextInt(100)+50;

   String accuracy = "0";
   String altitude = "0";
   int speed = 0;
   String dist = "0";
   String bearing = "0";
   int act_type = 1;
   int steps = 0 ;
   int spo2 = 0;

%>

<!doctype html>
<script language="JavaScript">
   var id =1;
   function count(){
      document.getElementById('ID').value = ++id;
      document.getElementById('HR').value = Math.floor(Math.random(50) * 150);
   }

</script>

<head>
<title>mobilise</title>
</head>
<body>
<div>
   <from>
      ID
      <input type="text" value="<%=ID%>" id="ID" ><br>
      SSSN
      <input type="text" value="<%=SSSN%>" id="SSSN" ><br>
      datetimeEent
      <input type="text" value="2015-12-08<%=Hours%><%=Minuts%><%=Second%>" id="datetimeEent" ><br>
      latitudeEvent
      <input type="text" value="<%=latit%>" id="latitudeEvent" ><br>
      longitudeEvent
      <input type="text" value="<%=logit%>" id="longitudeEvent" ><br>
      heartRateEvent
      <input type="text" value="<%=HR%>" id="HR" ><br>
      accuracy
      <input type="text" value="<%=accuracy%>" id="accuracy" ><br>
      altitude
      <input type="text" value="<%=altitude%>" id="altitude" ><br>
      speed
      <input type="text" value="<%=speed%>" id="speed" ><br>
      dist
      <input type="text" value="<%=dist%>" id="dist" ><br>
      bearing
      <input type="text" value="<%=bearing%>" id="bearing" ><br>
      act_type
      <input type="text" value="<%=act_type%>" id="act_type" ><br>
      steps
      <input type="text" value="<%=steps%>" id="steps" ><br>
      spo2
      <input type="text" value="<%=spo2%>" id="spo2" ><br>


      <input type="button" value="Enter"  onclick="count()">

   </from>
</div>
</body>
</html>