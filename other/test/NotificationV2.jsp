<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />

<!DOCTYPE html>
<html lang="en">
<head>
    <title>jQuery Bootstrap Data Table Plugin Demo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">
    <link href="css/jquery.bdt.css" type="text/css" rel="stylesheet">
    <link href="http://www.jqueryscript.net/css/jquerysctipttop.css" rel="stylesheet" type="text/css">

    <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <script src="//raw.github.com/botmonster/jquery-bootpag/master/lib/jquery.bootpag.min.js"></script>
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
</head>
<body>

<div class="container" style="margin-top:150px;">
    <div class="row">
        <div class="col-md-8">

            <table class="table table-hover table-striped" id="bootstrap-table" data-show-pagination-switch="true"
           data-pagination="true">
                <thead>
                <tr>
                    <th>วัน - เวลา</th>
                    <th>ประเภทการแจ้งเตือน</th>
                    <th>ระดับความสำคัญ</th>
                </tr>
                </thead>
                <tbody>
                <%
                    dbm.createConnection();
                        String date ="";
                        try {

                            String sql = "SELECT * FROM `alerts`";
                            ResultSet rs = dbm.executeQuery(sql);
                            
                             
                            while((rs!=null) && (rs.next())){%>
                            <tr>
                                <td><%= rs.getString("start")%></td>
                                <td><%= rs.getString("SSSN")%></td>
                                <td><%= rs.getString("end")%></td>
                            </tr>        
                            <%}
                        } catch (Exception e) {
                                out.print(e);
                        }
                        
                    dbm.closeConnection();
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

    <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <script src="//raw.github.com/botmonster/jquery-bootpag/master/lib/jquery.bootpag.min.js"></script>
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

    <script src="http://code.jquery.com/jquery-2.1.1.min.js" type="text/javascript"></script>
    <script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
    <script src="js/vendor/jquery.sortelements.js" type="text/javascript"></script>
    <script src="js/jquery.bdt.js" type="text/javascript"></script>
    <script>
    $(document).ready( function () {
        $('#bootstrap-table').bdt();
    });
</script>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-36251023-1']);
  _gaq.push(['_setDomainName', 'jqueryscript.net']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();



</script>

</body>
</html>