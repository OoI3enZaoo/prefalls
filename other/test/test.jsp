<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("index.jsp");
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
				response.sendRedirect("activity.jsp?SSSN="+rs.getString("SSSN"));
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

			add = add + "<button type='button' class='btn btn-primary glyphicon glyphicon-plus' onClick=showdiv('1')>เพื่อนผู้สูงอายุ</button>";
			
			}
			
			while((rs!=null) && (rs.next())){
				String sssn = rs.getString("SSSN");
				String fname = rs.getString("firstname");
				String lname = rs.getString("lastname");
				String imgpath = rs.getString("imgPath");
				output = output + "<a href=activity.jsp?SSSN="+sssn+" class=ccc><div class=cccc><img class=mpic src=images/patients/"+imgpath+">"+fname+" "+lname+"</div></a>";

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
<link rel="Shortcut Icon" href="images/icon.png"/>
<link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
<script language="JavaScript">

	function showdiv(main) {

      if (main == 1) {

         main1.style.display = 'none';
         main2.style.display = '';

      }

      if (main == 2) {

         location.reload();

      }
   }

   function insert() {

      var sn = document.getElementById("sn").value;
      var fn = document.getElementById("fn").value;
      var ln = document.getElementById("ln").value;
      var sex = document.getElementById("sex").value;
      var bd = document.getElementById("bd").value;
      var add = document.getElementById("add").value;
      var wg = document.getElementById("wg").value;
      var hg = document.getElementById("hg").value;
      var dis = document.getElementById("dis").value;
      var med = document.getElementById("med").value;
      var agmed = document.getElementById("agmed").value;
      var agfood = document.getElementById("agfood").value;
      var app = document.getElementById("app").value;
      var hos = document.getElementById("hos").value;
      var cn1 = document.getElementById("cn1").value;
      var cp1 = document.getElementById("cp1").value;
      var cr1 = document.getElementById("cr1").value;
      var cn2 = document.getElementById("cn2").value;
      var cp2 = document.getElementById("cp2").value;
      var cr2 = document.getElementById("cr2").value;
      var cn3 = document.getElementById("cn3").value;
      var cp3 = document.getElementById("cp3").value;
      var cr3 = document.getElementById("cr3").value;
      var url = "insert.jsp?sn="+sn+"&fn="+fn+"&ln="+ln+"&sex="+sex+"&bd="+bd+"&add="+add+"&wg="+wg+"&hg="+hg+"&dis="+dis+"&med="+med+"&agmed="+agmed+"&agfood="+agfood+"&app="+app+"&hos="+hos+"&cn1="+cn1+"&cp1="+cp1+"&cr1="+cr1+"&cn2="+cn2+"&cp2="+cp2+"&cr2="+cr2+"&cn3="+cn3+"&cp3="+cp3+"&cr3="+cr3 ;
      window.location = url ;

   }

</script>
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
         <a class="header-brand" href="#"><img src="images/logo.png"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav navbar-right">
            <li><a><%=ssfn%></a></li>
            <li><a href="logout.jsp">ออกจากระบบ</a></li>
         </ul>
      </div>
   </div>
</nav>
<div class="container">
	<div id="main1">
		<div class="container-header col-md-12 line">
			<%=add%>
        	<font class="s20">รายชื่อผู้สูงอายุ</font>
    	</div>
    	<%=output%>
    </div>
    <div id="main2" style="display:none">
    	<div class="container-header col-md-12 line">
    		<button type="button" class="btn btn-danger glyphicon glyphicon-remove" onClick="showdiv('2')">ยกเลิก</button>
    		<button type="button" class="btn btn-success glyphicon glyphicon-floppy-save" onClick="insert()">บันทึก</button>
        	<font class="s20">รายชื่อผู้สูงอายุ</font>
    	</div>
    	<div class="container-header col-md-12"><font class="s17">ข้อมูลด้านสุขภาพ</font></div></br>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">sssn</span>
           <input type="text" id="sn" class="form-control" aria-describedby="basic-addon1">
        </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
           <input type="text" id="fn" class="form-control" aria-describedby="basic-addon1">
        </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">นามสกุล</span>
            <input type="text" id="ln" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เพศ</span>
            <select class="form-control" id="sex">
               <option value="ชาย">ชาย</option>
               <option value="หญิง">หญิง</option>
            </select>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">วันเกิด</span>
            <input type="date" id="bd" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ที่อยู่</span>
            <input type="text" id="add" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="container-header col-md-12"><font class="s17">ข้อมูลด้านสุขภาพ</font></div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">น้ำหนัก</span>
            <input type="number" id="wg" class="form-control" aria-describedby="basic-addon1">
            <div class="input-group-addon">กิโลกรัม</div>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ส่วนสูง</span>
            <input type="number" id="hg" class="form-control" aria-describedby="basic-addon1">
            <div class="input-group-addon">เซนติเมตร</div>
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">โรคประจำตัว</span>
            <input type="text" id="dis" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ยาที่ใช้ประจำ</span>
            <input type="text" id="med" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ยาที่แพ้</span>
            <input type="text" id="agmed" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">อาหารที่แพ้</span>
            <input type="text" id="agfood" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ลักษณะพิเศษ</span>
            <input type="text" id="app" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">โรงพยาบาล</span>
            <input type="text" id="hos" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="container-header col-md-12"><font class="s17">ข้อมูลการติดต่อ</font></div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" id="cn1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" id="cp1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" id="cr1" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" id="cn2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" id="cp2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" id="cr2" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-12">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ชื่อ</span>
            <input type="text" id="cn3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เบอร์โทร</span>
            <input type="number" id="cp3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>
      <div class="col-md-6">
         <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">เกี่ยวข้องเป็น</span>
            <input type="text" id="cr3" class="form-control" aria-describedby="basic-addon1">
         </div></br>
      </div>

    </div>
</div>
<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>