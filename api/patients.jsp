<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<% 
Vector<String> SSSN = new Vector<String>();
Vector<String> firstname = new Vector<String>();
Vector<String> lastname = new Vector<String>();
Vector<String> nickname = new Vector<String>();
Vector<String> sex = new Vector<String>();
Vector<String> birthday = new Vector<String>();
Vector<String> address = new Vector<String>();
Vector<String> imgPath = new Vector<String>();
Vector<String> weight = new Vector<String>();
Vector<String> height = new Vector<String>();
Vector<String> apparent = new Vector<String>();
Vector<String> diseases = new Vector<String>();
Vector<String> medicine = new Vector<String>();
Vector<String> AllergicMed = new Vector<String>();
Vector<String> AllergicFood = new Vector<String>();
Vector<String> doctorName = new Vector<String>();
Vector<String> doctorPhone = new Vector<String>();
Vector<String> hospitalName = new Vector<String>();
Vector<String> cousinName1 = new Vector<String>();
Vector<String> cousinPhone1 = new Vector<String>();
Vector<String> cousinRelation1 = new Vector<String>();
Vector<String> cousinName2 = new Vector<String>();
Vector<String> cousinPhone2 = new Vector<String>();
Vector<String> cousinRelation2 = new Vector<String>();
Vector<String> cousinName3 = new Vector<String>();
Vector<String> cousinPhone3 = new Vector<String>();
Vector<String> cousinRelation3 = new Vector<String>();

dbm.createConnection();

try {

String sql = "SELECT SSSN , firstname , lastname , nickname , sex , birthday , address , imgPath , weight , height , apparent , diseases , medicine , AllergicMed , AllergicFood , doctorName , doctorPhone, hospitalName , cousinName1 , cousinPhone1 , cousinRelation1, cousinName2,cousinPhone2 , cousinRelation2 , cousinName3,cousinPhone3,cousinRelation3 FROM `patients`";
		ResultSet rs = dbm.executeQuery(sql);
	
    
	   while (rs.next()) {	
     
        SSSN.addElement(rs.getString("SSSN"));
		firstname.addElement(rs.getString("firstname"));
		lastname.addElement(rs.getString("lastname"));
		nickname.addElement(rs.getString("nickname"));
		sex.addElement(rs.getString("sex"));
		birthday.addElement(rs.getString("birthday"));
		address.addElement(rs.getString("address"));
		imgPath.addElement(rs.getString("imgPath"));
		weight.addElement(rs.getString("weight"));
		height.addElement(rs.getString("height"));
		apparent.addElement(rs.getString("apparent"));
		diseases.addElement(rs.getString("diseases"));
		medicine.addElement(rs.getString("medicine"));
		AllergicMed.addElement(rs.getString("AllergicMed"));
		AllergicFood.addElement(rs.getString("AllergicFood"));
		doctorName.addElement(rs.getString("doctorName"));
		doctorPhone.addElement(rs.getString("doctorPhone"));
		hospitalName.addElement(rs.getString("hospitalName"));
		cousinName1.addElement(rs.getString("cousinName1"));
		cousinPhone1.addElement(rs.getString("cousinPhone1"));
		cousinRelation1.addElement(rs.getString("cousinRelation1"));
		cousinName2.addElement(rs.getString("cousinName2"));
		cousinPhone2.addElement(rs.getString("cousinPhone2"));
		cousinRelation2.addElement(rs.getString("cousinRelation2"));
		cousinName3.addElement(rs.getString("cousinName3"));
		cousinPhone3.addElement(rs.getString("cousinPhone3"));
cousinRelation3.addElement(rs.getString("cousinRelation3"));
        
	
	  }
		
			
			
}	catch (Exception e) {
			out.println(e.getMessage());
			e.printStackTrace();
		}
		
		dbm.closeConnection();

String jsonStr = "[";
for(int i=0; i<SSSN.size(); i++){
	jsonStr += "{\"SSSN\":\""+ SSSN.elementAt(i) +"\",";
	jsonStr += "\"firstname\":\""+ firstname.elementAt(i) +"\",";
	jsonStr += "\"lastname\":\""+ lastname.elementAt(i) +"\",";
	jsonStr += "\"nickname\":\""+ nickname.elementAt(i) +"\",";
	jsonStr += "\"sex\":\""+ sex.elementAt(i) +"\",";
	jsonStr += "\"birthday\":\""+ birthday.elementAt(i) +"\",";
	jsonStr += "\"address\":\""+ address.elementAt(i) +"\",";
	jsonStr += "\"imgPath\":\""+ imgPath.elementAt(i) +"\",";
	jsonStr += "\"weight\":\""+ weight.elementAt(i) +"\",";
	jsonStr += "\"height\":\""+ height.elementAt(i) +"\",";
	jsonStr += "\"apparent\":\""+ apparent.elementAt(i) +"\",";
	jsonStr += "\"diseases\":\""+ diseases.elementAt(i) +"\",";
	jsonStr += "\"medicine\":\""+ medicine.elementAt(i) +"\",";
	jsonStr += "\"AllergicMed\":\""+ AllergicMed.elementAt(i) +"\",";
	jsonStr += "\"AllergicFood\":\""+ AllergicFood.elementAt(i) +"\",";
	jsonStr += "\"doctorName\":\""+ doctorName.elementAt(i) +"\",";
	jsonStr += "\"doctorPhone\":\""+ doctorPhone.elementAt(i) +"\",";
	jsonStr += "\"hospitalName\":\""+ hospitalName.elementAt(i) +"\",";
	jsonStr += "\"cousinName1\":\""+ cousinName1.elementAt(i) +"\",";
	jsonStr += "\"cousinPhone1\":\""+ cousinPhone1.elementAt(i) +"\",";
	jsonStr += "\"cousinRelation1\":\""+ cousinRelation1.elementAt(i) +"\",";
	jsonStr += "\"cousinName2\":\""+ cousinName2.elementAt(i) +"\",";
	jsonStr += "\"cousinPhone2\":\""+ cousinPhone2.elementAt(i) +"\",";
	jsonStr += "\"cousinRelation2\":\""+ cousinRelation2.elementAt(i) +"\",";
	jsonStr += "\"cousinName3\":\""+ cousinName3.elementAt(i) +"\",";
	jsonStr += "\"cousinPhone3\":\""+ cousinPhone3.elementAt(i) +"\",";
	jsonStr += "\"cousinRelation3\":\""+ cousinRelation3.elementAt(i) +"\"}";

 

		if((i+1) != SSSN.size()){
		jsonStr += ",";
	}
}
		jsonStr += "]";


		out.print(jsonStr);


%>