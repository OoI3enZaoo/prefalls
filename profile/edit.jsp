<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("../index.jsp");
	}

	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
	String sstypeid = (String)session.getAttribute("sstypeid");
	String ssuid = (String)session.getAttribute("ssuid");
	String editpic = "";
	
	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}

   if(sstypeid.equals("3")){
      response.sendRedirect("../profile");
   }
	
	if(sstypeid.equals("1")||sstypeid.equals("2")){
		
		dbm.createConnection();
		
		try {

			String sql = "select * from supervise,caregiver where caregiver.type_id = '"+sstypeid+"' and caregiver.UID = supervise.UID";
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();
				editpic = editpic + "<span class='glyphicon glyphicon-edit'>Edit</span>";
			}
			
		}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();

   }
	
		String fn = "";
		String ln = "";
		String bd = "";
		String ad = "";
		String sex = "";
		String wg = "";
		String hg = "";
		String dis = "";
		String agmed = "";
		String agfood = "";
		String app = "";
		String med = "";
		String hn = "";
		String cn1 = "";
      String cp1 = "";
      String cr1 = "";
		String cn2 = "";
      String cp2 = "";
      String cr2 = "";
		String cn3 = "";
      String cp3 = "";
      String cr3 = "";
		String im = "";
      String sn = "";
	
		dbm.createConnection();
		
		try {
			
			String sql = "select * from patients where SSSN = '" + session.getAttribute("SSSN") + "';" ;
			ResultSet rs = dbm.executeQuery(sql);
			 
			if(rs.next()){				
				rs.first();
				fn = rs.getString("firstname");
				ln = rs.getString("lastname");
				bd = rs.getString("birthday");
				ad = rs.getString("address");
				sex = rs.getString("sex");
				wg = rs.getString("weight");
				hg = rs.getString("height");
				dis = rs.getString("diseases");
				agmed = rs.getString("AllergicMed");
				agfood = rs.getString("AllergicFood");
				app = rs.getString("apparent");
				med = rs.getString("medicine");
				hn = rs.getString("hospitalName");
				cn1 = rs.getString("cousinName1");
				cp1 = rs.getString("cousinPhone1");
				cr1 = rs.getString("cousinRelation1");
				cn2 = rs.getString("cousinName2");
				cp2 = rs.getString("cousinPhone2");
				cr2 = rs.getString("cousinRelation2");
				cn3 = rs.getString("cousinName3");
				cp3 = rs.getString("cousinPhone3");
				cr3 = rs.getString("cousinRelation3");
				im = rs.getString("imgPath");
            sn = rs.getString("SSSN");
			}
			
		} catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
	
%>

<!doctype html>
<head>
<title>mobilise</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
</head>
<body>

<%@include file="../include/nav.jsp"%>
    
<div class="container">
   <div class="col-xs-12 col-sm-6 col-md-3">
      <div class="lpic">
         <img src="../images/patients/<%=im%>">
         <div class="editlpic"><%=editpic%></div>
      </div>
   </div>
   <div class="col-xs-12 col-md-9">
      <form action="update.jsp" method="post">
         <div class="container-header col-md-12">
            <a href="../profile/"><button type="button" class="btn btn-danger glyphicon glyphicon-remove">Cancal</button></a>
            <button type="submit" class="btn btn-success glyphicon glyphicon-floppy-save">Save</button>
         </div>
         <div class="container-header col-md-12"><font class="fs17">Patient information</font></div></br>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Name</span>
              <input type="text" name="fn" class="form-control" value="<%=fn%>" aria-describedby="basic-addon1">
           </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Surname</span>
               <input type="text" name="ln" class="form-control" value="<%=ln%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Sex</span>
               <select class="form-control" name="sex" value="<%=sex%>">
                  <option value="ชาย">Men</option>
                  <option value="หญิง">Women</option>
               </select>
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Birthday</span>
               <input type="date" name="bd" class="form-control" value="<%=bd%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-12">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Address</span>
               <input type="text" name="add" class="form-control" value="<%=ad%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="container-header col-md-12"><font class="fs17">Health information</font></div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Weight</span>
               <input type="number" name="wg" class="form-control" value="<%=wg%>" aria-describedby="basic-addon1">
               <div class="input-group-addon">kg.</div>
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Height</span>
               <input type="number" name="hg" class="form-control" value="<%=hg%>" aria-describedby="basic-addon1">
               <div class="input-group-addon">cm.</div>
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Congenital disease</span>
               <input type="text" name="dis" class="form-control" value="<%=dis%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Medication</span>
               <input type="text" name="med" class="form-control" value="<%=med%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Drug allergies</span>
               <input type="text" name="agmed" class="form-control" value="<%=agmed%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Food allergies</span>
               <input type="text" name="agfood" class="form-control" value="<%=agfood%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Birthmarks</span>
               <input type="text" name="app" class="form-control" value="<%=app%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Hospital</span>
               <input type="text" name="hos" class="form-control" value="<%=hn%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="container-header col-md-12"><font class="fs17">Contact</font></div>
         <div class="col-md-12">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Name</span>
               <input type="text" name="cn1" class="form-control" value="<%=cn1%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Telephone number</span>
               <input type="number" name="cp1" class="form-control" value="<%=cp1%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Relationship</span>
               <input type="text" name="cr1" class="form-control" value="<%=cr1%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-12">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Name</span>
               <input type="text" name="cn2" class="form-control" value="<%=cn2%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Telephone number</span>
               <input type="number" name="cp2" class="form-control" value="<%=cp2%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Relationship</span>
               <input type="text" name="cr2" class="form-control" value="<%=cr2%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-12">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Name</span>
               <input type="text" name="cn3" class="form-control" value="<%=cn3%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Telephone number</span>
               <input type="number" name="cp3" class="form-control" value="<%=cp3%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
         <div class="col-md-6">
            <div class="input-group">
               <span class="input-group-addon" id="basic-addon1">Relationship</span>
               <input type="text" name="cr3" class="form-control" value="<%=cr3%>" aria-describedby="basic-addon1">
            </div></br>
         </div>
      <form>
   </div>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>