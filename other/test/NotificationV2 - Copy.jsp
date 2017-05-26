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
<div id="page-selection">
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
</div>
<script>
        $('.demo4_top,.demo4_bottom').bootpag({
    total: 50,
    page: 2,
    maxVisible: 5,
    leaps: true,
    firstLastUse: true,
    first: '←',
    last: '→',
    wrapClass: 'pagination',
    activeClass: 'active',
    disabledClass: 'disabled',
    nextClass: 'next',
    prevClass: 'prev',
    lastClass: 'last',
    firstClass: 'first'
}).on("page", function(event, num){
    $(".content4").html("Page " + num); // or some ajax content loading...
}); 
        $('#page-selection').bootpag({
            total: 10
        }).on("page", function(event, /* page number here */ num){
             $("#content").html("Insert content"); // some ajax content loading...
        });
    </script>
</body>
</html>