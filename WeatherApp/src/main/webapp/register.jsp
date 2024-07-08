<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register Here</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/registerPageStyle.css">
</head>
<body>

    <div class="container">
        <form id="signup" action="Register" method="post">
            <div class="header">
                <h3>Sign Up</h3>  
            </div>
            <div class="sep"></div>
            <div class="inputs">
                Name: <input type="text" name="name1"/> <br/><br/>
                Email: <input type="email" name="email1"/> <br/><br/>
                Password: <input type="password" name="pass1"/> <br/><br/>
                Gender: 
                <input type="radio" name="gender1" value="Male"/> Male 
                <input type="radio" name="gender1" value="Female"/> Female
                <br/><br/>
                
                <input type="submit" value="Register" class="submit-button">

            </div>
        </form>
    </div>
</body>
</html>
