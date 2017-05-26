<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<!DOCTYPE html>
<html>
<head>
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" type="text/css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.10.10/css/dataTables.bootstrap.min.css" type="text/css" rel="stylesheet">
<script src="https://code.jquery.com/jquery-1.12.0.min.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/1.10.10/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="https://cdn.datatables.net/1.10.10/js/dataTables.bootstrap.min.js" type="text/javascript"></script>

</head>
<body>
<table id="example" class="table table-striped table-bordered" cellspacing="0" width="100%">
	<thead>
		<tr class="success">
		    <th>วัน - เวลา</th>
		    <th>ประเภทการแจ้งเตือน</th>
		    <th>ระดับความสำคัญ</th>
		</tr>
	</thead>
	<tbody>
                <%
                    dbm.createConnection();
                        try {

                            String sql = "SELECT a.start,b.alert_name,b.severity FROM alerts a LEFT JOIN alerttypename b ON a.alert_type=b.alert_type GROUP BY a.start ORDER BY a.start";
                            ResultSet rs = dbm.executeQuery(sql);
                            
                             
                            while((rs!=null) && (rs.next())){%>
                            <tr>
                                <td><%= rs.getString("start")%></td>
                                <td><%= rs.getString("alert_name")%></td>
                                <td><% if(rs.getInt("severity")==3){
                                        out.print("อันตราย");
                                        }else if (rs.getInt("severity")==2){
                                        out.print("เฝ้าระวัง");
                                    }else{
                                        out.print("ปกติ");
                                }
                                        %>
                                </td>
                            </tr>        
                            <%}
                        } catch (Exception e) {
                                out.print(e);
                        }
                        
                    dbm.closeConnection();
                %>
	</tbody>
</table>
<script type="text/javascript">
    
$(document).ready(function() {
    $('#example').DataTable();
} );

</script>
</body>
</html>