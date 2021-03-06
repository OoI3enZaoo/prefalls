<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<% String path = request.getRequestURI().toString(); %>
<%@ page import="java.sql.*"%>


<nav class="navbar navbar-default navbar-static-top">
   <div class="container-fluid">
      <div class="navbar-header">
         <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
         </button>
         <a class="header-brand" href="../listname/"><img src="../images/logo.png" style = "width: 178px; height: 35px;   margin-top: 8px;"></a>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
         <ul class="nav navbar-nav">
            <li <% if(path.equals("/prefalls/activity/index.jsp")) {%>class="active"<% } %>><a href="../activity/">Real-time Activity</a></li>
            <li <% if(path.equals("/prefalls/history/index.jsp") || path.equals("/prefalls/history/show.jsp")) {%>class="active"<% } %>><a href="../history/">Activity Log</a></li>
            <li <% if(path.equals("/prefalls/notifications/index.jsp")) {%>class="active"<% } %>><a href="../notifications/">Notifications</a></li>
            <%-- <li <% if(path.equals("/mobilise/comment/index.jsp")) {%>class="active"<% } %>><a href="../comment/">Medical advices</a></li> --%>
            <li <% if(path.equals("/prefalls/mobility/index.jsp") || path.equals("/prefalls/mobility/mobility.jsp")) {%>class="active"<% } %>><a href="../mobility/">Fall history</a></li>
            <li <% if(path.equals("/prefalls/profile/index.jsp") || path.equals("/prefalls/profile/edit.jsp")) {%>class="active"<% } %>><a href="../profile/">Patient Information</a></li>
            <li class="end<% if(path.equals("/prefalls/setting/index.jsp") || path.equals("/prefalls/setting/edit.jsp")) {%> active<% } %>"><a href="../setting/">Settings</a></li>


         </ul>
         <ul class="nav navbar-nav navbar-right">
            <!--<li><a>แจ้งเตือน</a></li>-->
            <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><%=ssfn%> <span class="caret"></span></a>
                <ul class="dropdown-menu">
                    <li><a href="../logout.jsp">Sign out</a></li>
                </ul>
            </li>
         </ul>
      </div>
   </div>
</nav>
