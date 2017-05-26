<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.TimeZone"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />	
<%
	String sssn = request.getParameter("sssn");
	long start = Long.parseLong(request.getParameter("start"));
        long end = Long.parseLong(request.getParameter("end"));  
    
        double total = Double.parseDouble(request.getParameter("total"));
	double sittostand = Double.parseDouble(request.getParameter("sittostand"));
	double fw = Double.parseDouble(request.getParameter("forward"));
	double t = Double.parseDouble(request.getParameter("turn"));
	double back = Double.parseDouble(request.getParameter("backward"));
	double standtosit = Double.parseDouble(request.getParameter("standtosit"));     
    
        long unixstart = start;	
	Date datestart = new Date(unixstart);		
	SimpleDateFormat sdfstart = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");		
	sdfstart.setTimeZone(TimeZone.getTimeZone("GMT+7"));    
        String starttime = sdfstart.format(datestart);
    
        long unixend = end;	
	Date dateend = new Date(unixend);		
	SimpleDateFormat sdfend = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");		
	sdfend.setTimeZone(TimeZone.getTimeZone("GMT+7"));    
        String endtime = sdfend.format(dateend);
    
    dbm.createConnection();    
    try {            
        String sql ="INSERT INTO `mobilise`.`MobilityTest` (`SSSN`, `type_id`, `start`, `end`, `time_total`, `time_stand2sit`, `time_sit2stand`, `time_forward`, `time_turn`, `time_return`) VALUES ('"+sssn+"', '1', '"+starttime+"', '"+endtime+"', '"+total+"', '"+standtosit+"', '"+sittostand+"', '"+fw+"', '"+t+"', '"+back+"')";			
        dbm.executeUpdate(sql);
        out.println(sql);                
    } catch (Exception e) {
        out.println(e.getMessage());
        e.printStackTrace();
    }         
    dbm.closeConnection();		
	
    
    out.print(total);
    
    

%>