

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>



<%


String userDB = "root";
String passDB = "sysadmin2017";
String urlDB = "jdbc:mysql://sysnet.utcc.ac.th/mobilise?";




Vector<Integer> cnt =  new Vector<Integer>();
Vector<String> fname =  new Vector<String>();
Vector<String> lname =  new Vector<String>();
Vector<String> user_id =  new Vector<String>();

 try {
	  Class.forName("com.mysql.jdbc.Driver");
	  Connection con = DriverManager.getConnection(urlDB,userDB,passDB);

	 	String sql = "select count(*) as cnt , firstname,lastname from caregiver where email='test01' and password='test01'";
     
      ResultSet rs = stmt.executeQuery(sql);
	  int rowCnt = 0;
	   while (rs.next()) {
        cnt.addElement(rs.getInt("cnt"));
        fname.addElement(rs.getString("firstname"));
        lname.addElement(rs.getString("lastname"));
        //user_id.addElement(rs.getString("user_id"));
	  }
	  stmt.close();
      con.close();

}catch(Exception e){
	out.println("exception = "+e);
}

String jsonStr = "[";
for(int i=0; i<cnt.size(); i++){
	jsonStr += "{\"cnt\":\""+cnt.elementAt(i)+"\",";
  jsonStr += "\"fname\":\""+fname.elementAt(i)+"\",";
	jsonStr += "\"lname\":\""+lname.elementAt(i)+"\"}";
  

		if((i+1) != cnt.size()){
		jsonStr += ",";
	}
}
		jsonStr += "]";


		out.print(jsonStr);


%>
