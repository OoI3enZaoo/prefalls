<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" media="screen" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
<link href="https://eonasdan.github.io/bootstrap-datetimepicker/css/prettify-1.0.css" rel="stylesheet">
<link href="https://eonasdan.github.io/bootstrap-datetimepicker/css/base.css" rel="stylesheet">
<link href="https://cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/build/css/bootstrap-datetimepicker.css" rel="stylesheet">

<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.9.0/moment-with-locales.js"></script>
<script src="https://cdn.rawgit.com/Eonasdan/bootstrap-datetimepicker/e8bddc60e73c1ec2475f827be36e1957af72e2ea/src/js/bootstrap-datetimepicker.js"></script>

</head>
<body>
<div class="container">
	<form action="showNoti.jsp" method="post">
    <div class='col-md-3'>
        <div class="form-group">
            <div class='input-group date' id='datetimepicker6'>
                <input type='text' class="form-control" name="startTime" />
                <span class="input-group-addon">
                    <span class="glyphicon glyphicon-calendar"></span>
                </span>
            </div>
        </div>
    </div>
    <div class='col-md-3'>
        <div class="form-group">
            <div class='input-group date' id='datetimepicker7'>
                <input type='text' class="form-control" name="endTime" />
                <span class="input-group-addon">
                    <span class="glyphicon glyphicon-calendar"></span>
                </span>
            </div>
        </div>
    </div>
    <div class='col-md-3'>
    <div class="form-group">
      <select class="form-control" name="Type">
        <option value="1">HR ผิดปกติ</option>
        <option value="2">Mobility ต่ำกว่าเกณฑ์</option>
        <option value="3">เตือนการพลิกตัว</option>
      </select>
    </div>
	</div>
	<div class='col-md-2'>
    <div class="form-group">
      <select class="form-control" name="Lavel">
        <option value="1">ปกติ</option>
        <option value="2">เฝ้าระวัง</option>
        <option value="3">มาก</option>
      </select>
    </div>
	</div> 
    <div class='col-md-1'>
    <div class="form-group"> 
    <button type="submit" class="btn btn-success" >ค้นหา</button>
    </div>
    </div>
</div>
</form>
</div>

<script type="text/javascript">
    $(function () {
        $('#datetimepicker6').datetimepicker({
        	format: 'YYYY-MM-DD HH:mm:ss'
        });
        $('#datetimepicker7').datetimepicker({
        	format: 'YYYY-MM-DD HH:mm:ss',
            useCurrent: false
        });
        $("#datetimepicker6").on("dp.change", function (e) {
            $('#datetimepicker7').data("DateTimePicker").minDate(e.date);
        });
        $("#datetimepicker7").on("dp.change", function (e) {
            $('#datetimepicker6').data("DateTimePicker").maxDate(e.date);
        });
    });
</script>
</script>
<div>
    <div>
        <%
        dbm.createConnection();
        String data = "";
        try {

            String sql = "SELECT * FROM ( SELECT * FROM `alerts` ORDER BY id DESC LIMIT 7 ) sub ORDER BY id desc";
            ResultSet rs = dbm.executeQuery(sql);
        %>
        <table class="table table-hover">
        <%
            ResultSetMetaData resMetaData = rs.getMetaData();
            int nCols = resMetaData.getColumnCount();
        %>
        <tr>
        <%
            for (int kCol = 1; kCol <= nCols; kCol++) {
                out.print("<td class=\"success\"><b>" + resMetaData.getColumnName(kCol) + "</b></td>");
            }
        %></tr>
        <% 
                while (rs.next()){ 
        %>
        <tr>
        <%
                    for (int kCol = 1; kCol <= nCols; kCol++) {
                        out.print("<td>" + rs.getString(kCol) + "</td>");
                    }
        %>
        </tr>
        <%
                }
        %>
        </table>
        <%
        }catch(Exception ex){
        out.println("Unable to connect to database"+ex);
        }
        dbm.closeConnection();
        %>
    </div>
</div> 
</body>
</html>
