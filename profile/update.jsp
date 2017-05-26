<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
	
<%
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
	String sssn = (String)session.getAttribute("SSSN");
		
	dbm.createConnection();
		
	try {
			
		String sql ="UPDATE `mobilise`.`patients` SET `firstname` = '"+fn+"', `lastname` = '"+ln+"',`sex` = '"+sex+"',`birthday` = '"+bd+"',`address` = '"+add+"',`weight` = '"+wg+"',`height` = '"+hg+"',`diseases` = '"+dis+"',`medicine` = '"+med+"',`AllergicMed` = '"+agmed+"',`AllergicFood` = '"+agfood+"',`apparent` = '"+app+"',`hospitalName` = '"+hos+"',`cousinName1` = '"+cn1+"',`cousinPhone1` = '"+cp1+"',`cousinRelation1` = '"+cr1+"',`cousinName2` = '"+cn2+"',`cousinPhone2` = '"+cp2+"',`cousinRelation2` = '"+cr2+"',`cousinName3` = '"+cn3+"',`cousinPhone3` = '"+cp3+"',`cousinRelation3` = '"+cr3+"' WHERE `patients`.`SSSN` = '"+sssn+"'";
			
		dbm.executeUpdate(sql);	
				  
	} catch (Exception e) {
		out.println(e.getMessage());
		e.printStackTrace();
	}
		
	dbm.closeConnection();

	response.sendRedirect("../profile/");

%>