<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*,java.util.*"%>
<jsp:useBean id="um" class="th.ac.utcc.upload.UploadManager" />
<%
	String contentType = request.getContentType();
	if ((contentType.indexOf("multipart/form-data") >= 0)) {
		Vector<String> filePathVec = um.uploadFile(request);
		out.println("<p>file is successfully uploaded</p>"); 
		Properties param = um.getParamProp();

		for(int i=0; i<filePathVec.size(); i++){
			out.println("file url: "+filePathVec.elementAt(i)+"<br>");
		}
		
		out.println("first name = "+param.getProperty("fname"));
	 }else{
	      out.println("<html>");
	      out.println("<head>");
	      out.println("<title>Servlet upload</title>");  
	      out.println("</head>");
	      out.println("<body>");
	      out.println("<p>No file uploaded</p>"); 
	      out.println("</body>");
	      out.println("</html>");
	   }
%>