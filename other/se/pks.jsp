<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="dbm" class="th.ac.utcc.database.DBManager" />
<%
	request.setCharacterEncoding("UTF-8");
	dbm.createConnection();
	try {
	
		String car = request.getParameter("car");
		
		String sql = "SELECT * FROM se WHERE carid = '" + car + "';";
		ResultSet rs = dbm.executeQuery(sql);
		
		String output = "{";	
		if(!rs.next())
		{
			sql = "SELECT * FROM se WHERE status = 0 ;";
			rs = dbm.executeQuery(sql);
			String cin = "";
			if(!rs.next())
			{
				output += "\"status\":0";
			} else {			
				output += "\"status\":1";
				cin = rs.getString("id");				
				output += ",\"id\":\""+cin+"\"";
				output += ",\"car\":\""+car+"\"";
				
				sql = "UPDATE `mobilise`.`se` SET `carid` = '"+car+"', `status` = '1' WHERE `se`.`id` = '"+cin+"';";
				dbm.executeUpdate(sql);	
				
				sql = "SELECT DATE_FORMAT(time_in,'%H:%i') as time FROM se WHERE id = '"+cin+"';";
				rs = dbm.executeQuery(sql);			
				if(rs.next())
				{ 
					String timein = rs.getString("time");
					output += ",\"timein\":\""+timein+"\"";
				}
				
				sql = "SELECT COUNT(*) as free FROM `se` WHERE status = 0";
				rs = dbm.executeQuery(sql);			
				if(rs.next())
				{ 
					String free = rs.getString("free");
					output += ",\"free\":\""+free+"\"";
				}
			}
		} else {
			output += "\"status\":2";
			String id= rs.getString("id");
			output += ",\"id\":\""+id+"\"";	
			String timein = "";
			String timeout = "";
			String timetotal = "";
			String datein = "";
			String dateout = "";
			int price = 0; 
			long ts_timein = 0;
			long ts_timeout = 0;
			int t = 0;
			int h = 0;
			int m = 0;
			String time = "";
			output += ",\"carid\":\""+car+"\"";	
			sql = "SELECT DATE_FORMAT(time_in,'%H:%i') as time , UNIX_TIMESTAMP(time_in) as ts_time  , time_in as datee FROM se WHERE carid = '" + car + "';";
			rs = dbm.executeQuery(sql);			
			if(rs.next())
			{ 
				timein = rs.getString("time");
				output += ",\"timein\":\""+timein+"\"";	
				ts_timein = rs.getLong("ts_time");
				datein = rs.getString("datee");
			}
			
			sql = "UPDATE `mobilise`.`se` SET `carid` = ' ', `status` = '0' WHERE `se`.`id` = '"+id+"';";
			dbm.executeUpdate(sql);	
			
			sql = "SELECT DATE_FORMAT(time_in,'%H:%i') as time , UNIX_TIMESTAMP(time_in) as ts_time , time_in as datee FROM se WHERE id = '" + id + "';";
			rs = dbm.executeQuery(sql);			
			if(rs.next())
			{ 
				timeout = rs.getString("time");
				output += ",\"timeout\":\""+timeout+"\"";	
				dateout = rs.getString("datee");
				ts_timeout = rs.getLong("ts_time");
			}
			
			time = "" + (ts_timeout - ts_timein);
			t = Integer.parseInt(time);
			m = (t/60)+1 ;
			h = m/60 ;			
			timetotal = h+" ชั่วโมง"+(m%60)+" นาที";
			output += ",\"timetotal\":\""+timetotal+"\"";
			
			if(h<1){
				price = 20;
			} else {
				if(m>0){
					h++;
				}
				price = (h*10)+10;
			}
			output += ",\"price\":\""+price+"\"";
			
			sql = "SELECT COUNT(*) as free FROM `se` WHERE status = 0";
			rs = dbm.executeQuery(sql);			
			if(rs.next())
			{ 
				String free = rs.getString("free");
				output += ",\"free\":\""+free+"\"";
			}
			
			sql = "INSERT INTO `mobilise`.`se_history` (`id`, `carid`, `timein`, `timeout`) VALUES (NULL, '"+car+"', '"+datein+"', '"+dateout+"');";
			dbm.executeUpdate(sql);
						
		}
		
		output += "}";
		out.print(output);
		
	} catch (SQLException e) {System.out.println("Exception e: "+e);}	
	dbm.closeConnection();
%>