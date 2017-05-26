<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	String tin = request.getParameter("in");
    String carid = request.getParameter("id");
    String tout = request.getParameter("out");
    String ttotal = request.getParameter("total");
    String tp = request.getParameter("p");
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
    
<div class="bill">
    <div class="callout">
        <p class="hh">PARKiNG SySTEM</p>
	<p>~~~~~~~~~~~~~~~~~~~~~~~~~~~</p>
	<div>เลขทะเบียน<div class="float-right"><%=carid%></div></div>
        <p>~~~~~~~~~~~~~~~~~~~~~~~~~~~</p>
        <div>เวลาเข้า<div class="float-right"><%=tin%></div></div>
        <div>เวลาออก<div class="float-right"><%=tout%></div></div>
        <div>เวลาทั้งหมด<div class="float-right"><%=ttotal%></div></div>
        <div>ค่าบริการ<div class="float-right"><%=tp%> บาท</div></div>
        <p>~~~~~~~~~~~~~~~~~~~~~~~~~~~</p>
        <p>*อัตตราค่าบริการ*</p>
        <p>**ชั่วโมงแรกคิดค่าบริการ 20 บาท**</p>
        <p>**ชั่วโมงต่อไปคิดค่าบริการ 10 บาท**</p>
    </div>
</div>
    
</body>
<script src="js/jquery.min.js"></script>
</html>