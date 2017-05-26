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
	
	if(sstypeid.equals("3")){
		
		dbm.createConnection();
		
		try {

			String sql = "select * from supervise,caregiver where caregiver.type_id = '"+sstypeid+"' and caregiver.UID = supervise.UID";
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();
				response.sendRedirect("../activity.jsp?SSSN="+rs.getString("SSSN"));
			}
			
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();
		
	} else {
		
		dbm.createConnection();
		
		try {
			
			String sql = "select * from supervise,patients where supervise.UID = '"+ssuid+"' and supervise.SSSN = patients.SSSN";
			ResultSet rs = dbm.executeQuery(sql);

			if(sstypeid.equals("2")) {

			add = add + "<a href='add.jsp'><button type='button' class='btn btn-primary glyphicon glyphicon-plus'>เพิ่มผู้สูงอายุ</button></a>";
			
			}
			
			while((rs!=null) && (rs.next())){
				String sssn = rs.getString("SSSN");
				String fname = rs.getString("firstname");
				String lname = rs.getString("lastname");
				String imgpath = rs.getString("imgPath");
				output = output + "<a href=../activity.jsp?SSSN="+sssn+" class=ccc><div class=cccc><img class=mpic src=../images/patients/"+imgpath+">"+fname+" "+lname+"</div></a>";

    		}
			
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();
		
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
         <a class="header-brand" href="#"><img src="../images/logo.png"></a>
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
	<div class="container-header col-md-12 line">
		<%=add%>
      <font class="s20">รายชื่อผู้สูงอายุ</font>
   </div>
   <%=output%>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>