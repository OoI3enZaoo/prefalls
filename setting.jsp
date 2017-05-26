<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
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
		
		try {
			
			String sql = "select * from patients where SSSN = '" + session.getAttribute("SSSN") + "';" ;
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();

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
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="images/icon.png"/>
<link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
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
         <a class="header-brand" href="./listname/"><img src="images/logo.png"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav">
            <li><a href="activity.jsp">กิจกรรมประจำวัน</a></li>
            <li><a href="./history/">ประวัติกิจกรรม</a></li>
            <li><a href="./notifications/">บันทึกการแจ้งเตือน</a></li>
            <li><a href="mobility.jsp">บันทึกผลการทดสอบ</a></li>
            <li><a href="./profile/">ข้อมูลส่วนตัว</a></li>
            <li class="active end"><a href="setting.jsp">ตั้งค่า</a></li>
         </ul>
         <ul class="nav navbar-nav navbar-right">
         	<li><a><%=ssfn%></a></li>
            <li><a href="logout.jsp">ออกจากระบบ</a></li>
         </ul>
      </div>
   </div>
</nav>
<div class="container">
    <div class="panel"><font class="fs17">ตั่งค่า</font></div>
    <form action="update.jsp" method="post">
        <div class="col-lg-6">
        <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ค่าสูงสุด BPM</span>
            <input type="text" name="fn" class="form-control" value="....>" aria-describedby="basic-addon1">
        </div>
        </div>
        <div class="col-lg-6">
        <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ค่าต่ำสุด BPM</span>
            <input type="text" name="fn" class="form-control" value="....>" aria-describedby="basic-addon1">
        </div>
        </div>
    </form>
</div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>