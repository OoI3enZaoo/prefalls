<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../");
	}
	
	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String ssuid = (String)session.getAttribute("ssuid");
	String sstypeid = (String)session.getAttribute("sstypeid");
	String output = "";
	String add = "";
	
	if(sstypeid.equals("1")||sstypeid.equals("3")){
      response.sendRedirect("../listname/");
   }

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
   <form action="insert.jsp" method="post">
      <div class="container-header col-md-12 line">
         <a href="../listname"><button type="button" class="btn btn-danger glyphicon glyphicon-remove">ยกเลิก</button></a>
         <button type="submit" class="btn btn-success glyphicon glyphicon-floppy-save">บันทึก</button>
         <font class="s20">รายชื่อผู้สูงอายุ</font>
      </div>
      <div class="container-header col-md-12"><font class="s17">ข้อมูลด้านสุขภาพ</font></div></br>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">sssn</span>
            <input type="text" name="sn" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" name="fn" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">นามสกุล</span>
            <input type="text" name="ln" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เพศ</span>
            <select class="form-control" name="sex">
               <option value="ชาย">ชาย</option>
               <option value="หญิง">หญิง</option>
            </select>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">วันเกิด</span>
            <input type="date" name="bd" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ที่อยู่</span>
            <input type="text" name="add" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="container-header col-md-12"><font class="s17">ข้อมูลด้านสุขภาพ</font></div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">น้ำหนัก</span>
            <input type="number" name="wg" class="form-control" aria-describedby="basic-addon1">
            <div class="input-group-addon">กิโลกรัม</div>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ส่วนสูง</span>
            <input type="number" name="hg" class="form-control" aria-describedby="basic-addon1">
            <div class="input-group-addon">เซนติเมตร</div>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">โรคประจำตัว</span>
            <input type="text" name="dis" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ยาที่ใช้ประจำ</span>
            <input type="text" name="med" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ยาที่แพ้</span>
            <input type="text" name="agmed" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">อาหารที่แพ้</span>
            <input type="text" name="agfood" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ลักษณะพิเศษ</span>
            <input type="text" name="app" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">โรงพยาบาล</span>
            <input type="text" name="hos" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="container-header col-md-12"><font class="s17">ข้อมูลการติดต่อ</font></div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" name="cn1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" name="cp1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" name="cr1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" name="cn2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" name="cp2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" name="cr2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" name="cn3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" name="cp3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" name="cr3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
   </form>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>