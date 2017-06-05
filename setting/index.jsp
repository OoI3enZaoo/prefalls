<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<%
	if(session.getAttribute("ssuid") == null){
		response.sendRedirect("./");
	}

	if(request.getParameter("SSSN") != null){
		session.setAttribute("SSSN",request.getParameter("SSSN"));
	}

	String ssfn = (String)session.getAttribute("ssfn");
	String ssln = (String)session.getAttribute("ssln");
    String sstypeid = (String)session.getAttribute("sstypeid");
    String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + session.getAttribute("fname") + " " + (String)session.getAttribute("lname") + " ";


    String minHR = "";
    String maxHR = "";
    String maxS = "";
    String editsetting ="";

    dbm.createConnection();

	if(sstypeid.equals("1")||sstypeid.equals("2")){

		try {

			String sql = "select * from supervise,caregiver where caregiver.type_id = '"+sstypeid+"' and caregiver.UID = supervise.UID";
			ResultSet rs = dbm.executeQuery(sql);

			if(rs.next()){
				rs.first();
                editsetting = editsetting + "<a href='edit.jsp'><button type='button' class='btn btn-warning glyphicon glyphicon-edit' onClick=edit.jsp>Edit</button></a>";
			}

		}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

    }

    try {

        String sql = "select * from patients where SSSN = '" + session.getAttribute("SSSN") + "';" ;
        ResultSet rs = dbm.executeQuery(sql);

        if(rs.next()){
            rs.first();
            minHR = rs.getString("minHeartRate");
            maxHR = rs.getString("maxHeartRate");
            maxS = rs.getString("maxStationary");

        }

    } catch (Exception e) {
        out.println(e.getMessage());
        e.printStackTrace();
    }

   dbm.closeConnection();

%>

<!doctype html>
<head>
<title>PreFall</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
</head>
<body>

<%@include file="../include/nav.jsp"%>

<div class="container">
    <div class="panel"><font class="fs17">Settings<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel" style="margin-left:10px;margin-right:10px;">
        <%=editsetting%>
        <br>
        <br>
        <div class="input-group" style="width:300px;">
            <span class="input-group-addon" id="basic-addon1">Maximum heart rate  (bpm)</span>
            <input type="text" name="maxHR" class="form-control" value="<%=maxHR%>" aria-describedby="basic-addon1" readonly>
        </div><br>
        <div class="input-group" style="width:300px;">
            <span class="input-group-addon" id="basic-addon1">Minimum heart rate  (bpm)</span>
            <input type="text" name="minHR" class="form-control" value="<%=minHR%>" aria-describedby="basic-addon1" readonly>
        </div><br>
        <div class="input-group" style="width:300px;">
            <span class="input-group-addon" id="basic-addon1">Maximum immobility time (Minutes)</span>
            <input type="text" name="maxS" class="form-control" value="<%=maxS%>" aria-describedby="basic-addon1" readonly>
        </div>
    </div>
</div>
<script src="../js/jquery.min.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
