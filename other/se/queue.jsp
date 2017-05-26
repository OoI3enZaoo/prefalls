<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	String carid = request.getParameter("carid");
    String id = request.getParameter("id");
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" type="text/css" href="css/foundation.min.css"/>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
<title>PARKiNG SySTEM</title>
</head>
<body>
    
<div class="queue">
    <div class="callout">
        <p style="font-size:40px;"><%=carid%></p>
        <p style="font-size:80px;"><%=id%></p>
        <p>*อัตตราค่าบริการ*</p>
        <p>**ชั่วโมงแรกคิดค่าบริการ 20 บาท**</p>
        <p>**ชั่วโมงต่อไปคิดค่าบริการ 10 บาท**</p>
        <p>***หายปรับ 1,000 บาท***</p>
    </div>
</div>
    
</body>
<script src="js/jquery.min.js"></script>
</html>