<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/loginPageStyle.css">
</head>
<body>
    <div class="login">
        <h1>Login</h1>
        <form action="loginForm" method="post">
            <input type="text" name="email1" placeholder="Email" required="required" /> <br/><br/>
            <input type="password" name="pass1" placeholder="Password" required="required" /> <br/><br/>
            <button type="submit" class="btn btn-primary btn-block btn-large">Login</button>
        </form>
    </div>
</body>
</html>
