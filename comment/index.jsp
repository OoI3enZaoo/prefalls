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
	String sssn = (String)session.getAttribute("SSSN");
    String sstypeid = (String)session.getAttribute("sstypeid");
    String fname = (String)session.getAttribute("fname");
    String lname = (String)session.getAttribute("lname");
    String name = " Patient Name : " + session.getAttribute("fname") + " " + (String)session.getAttribute("lname") + " ";

    String comment ="";

    if(sstypeid.equals("1")||sstypeid.equals("2")){
		
		try {

            comment = comment + "<form action='insert.jsp' method='post'><h3>Add doctor's advice</h3><textarea class='text' id='comment' name='comment' cols='70' rows='5' style='padding: 4px;'></textarea><br><button type='submit' class='btn btn-primary'>Sent</button></form>";
			
		}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}

    }
	
%>

<!doctype html>
<head>
<title>mobilise</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="Shortcut Icon" href="../images/icon.png"/>
<!-- CSS Main File-->
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="../css/style.css"/>
<!--CSS and JS dataTables File -->
<link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap.min.css"/>
<script type="text/javascript" src="js/jquery-1.12.0.min.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="js/dataTables.bootstrap.min.js"></script>

</head>
<body>

<%@include file="../include/nav.jsp"%>    
    
<div class="container">
    <div class="panel"><font class="fs17">Medical advices<span id="patient" class="right"><%=name%></span></font></div>
    <div class="panel">
    
  <table id="TBcomment" class="table table-striped table-bordered" cellspacing="0" width="100%">
  	<thead>
  		<tr class="success">
  		    <th>Date</th>
  		    <th>Medical advices</th>
  		</tr>
  	</thead>
  	<tbody>

      <%
          dbm.createConnection();
          try {

              String sql = "SELECT * FROM `comment_"+sssn+"`";
              ResultSet rs = dbm.executeQuery(sql);
              
               
              while((rs!=null) && (rs.next())){%>

                <tr>
                    <td><%= rs.getString("date")%></td>
                    <td><%= rs.getString("comment")%></td>
                </tr>

              <%}
          } catch (Exception e) {
                  out.print(e);
          }
              
          dbm.closeConnection();
      %>

  	</tbody>
  </table>

    <%=comment%>

    </div>
</div>
<script type="text/javascript">

	$(document).ready(function() {
	    $('#TBcomment').DataTable();
	} );

</script>
<!-- JS Main File -->
<script src="../js/bootstrap.min.js"></script>
</body>
</html>