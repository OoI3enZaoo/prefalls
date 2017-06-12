<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
	
<%
	String sn = request.getParameter("sn");
	String fn = request.getParameter("fn");
	String ln = request.getParameter("ln");
	String sex = request.getParameter("sex");
	String bd = request.getParameter("bd");
	String add = request.getParameter("add");
	String wg = request.getParameter("wg");
	String hg = request.getParameter("hg");
	String dis = request.getParameter("dis");
	String med = request.getParameter("med");
	String agmed = request.getParameter("agmed");
	String agfood = request.getParameter("agfood");
	String app = request.getParameter("app");
	String hos = request.getParameter("hos");
	String cn1 = request.getParameter("cn1");
	String cp1 = request.getParameter("cp1");
	String cr1 = request.getParameter("cr1");
	String cn2 = request.getParameter("cn2");
	String cp2 = request.getParameter("cp2");
	String cr2 = request.getParameter("cr2");
	String cn3 = request.getParameter("cn3");
	String cp3 = request.getParameter("cp3");
	String cr3 = request.getParameter("cr3");
		
	dbm.createConnection();

	String sql ="INSERT INTO `mobilise`.`patients` (`SSSN`, `firstname`, `lastname`, `nickname`, `sex`, `birthday`, `address`, `imgPath`, `weight`, `height`, `apparent`, `diseases`, `medicine`, `AllergicMed`, `AllergicFood`, `doctorName`, `doctorPhone`, `minHeartRate`, `maxHeartRate`, `hospitalName`, `cousinName1`, `cousinPhone1`, `cousinRelation1`, `cousinName2`, `cousinPhone2`, `cousinRelation2`, `cousinName3`, `cousinPhone3`, `cousinRelation3`, `status`, `dateAdd`, `dateUpdate`, `updateBy`) VALUES ('"+sn+"', '"+fn+"', '"+ln+"', 'Nick name', '"+sex+"', '"+bd+"', '"+add+"', 'default.png', '"+wg+"', '"+hg+"', '"+app+"', '"+dis+"', '"+med+"', '"+agmed+"', '"+agfood+"', NULL, '', '', '', '"+hos+"', '"+cn1+"', '"+cp1+"', '"+cr1+"', '"+cn2+"', '"+cp2+"', '"+cr2+"', '"+cn3+"', '"+cp3+"', '"+cr3+"', '10',now(), CURRENT_TIMESTAMP, '1');";

	dbm.executeUpdate(sql);
	
	//----------------------

	String sql2 = "insert into supervise(SSSN,UID) values('"+sn+"',"+session.getAttribute("ssuid")+")";

	dbm.executeUpdate(sql2);
	
	//----------------------


	//insert into supervise(SSSN,UID) values('"+sn+"',"+session.getAttribute("ssuid")+")";

	  String sql3 = "CREATE TABLE `archive_"+sn+"` (";
	  sql3 += "`ID` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,";
	  sql3 += "`SSSN` varchar(10) COLLATE utf8_unicode_ci NOT NULL,";
	  sql3 += "`tstamp` datetime NOT NULL,";
	  sql3 += "`step` int(11) NOT NULL,";
	  sql3 += "`spo2` int(11) NOT NULL,";
	  sql3 += "`calories` double NOT NULL,";
	  sql3 += "`dist` double NOT NULL,";
	  sql3 += "`hr` float NOT NULL,";
	  sql3 += "`hrinv` float NOT NULL,";
	  sql3 += "`pace` int(11) NOT NULL,";
	  sql3 += "`act_type` int(3) NOT NULL,";
	  sql3 += "`act_group` int(3) NOT NULL,";
	  sql3 += "`ismobile` tinyint(1) NOT NULL,";
	  sql3 += "`long_active` int(11) NOT NULL,";
	  sql3 += "`long_hactive` int(11) NOT NULL,";
	  sql3 += "`long_stationary` int(11) NOT NULL,";
	  sql3 += "`long_sleep` int(11) NOT NULL,";
	  sql3 += "`long_bedsores` int(11) NOT NULL DEFAULT '0'";
	  sql3 += ") ";

	dbm.executeUpdate(sql3);
	
	//----------------------

	dbm.closeConnection();

	response.sendRedirect("index.jsp");
%>