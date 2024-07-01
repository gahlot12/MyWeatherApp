package com.MyWeatherApp;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Register")
public class Register extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();

        String myName = req.getParameter("name1");
        String myEmail = req.getParameter("email1");
        String myPass = req.getParameter("pass1");
        String myGender = req.getParameter("gender1");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/UserRegistration", "root", "Kunal1234@");

            String sql = "INSERT INTO UserData (name, email, password, gender) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, myName);
            ps.setString(2, myEmail);
            ps.setString(3, myPass);
            ps.setString(4, myGender);

            int count = ps.executeUpdate();
            if (count > 0) {
                out.println("<h3 style='color:green'>User registered Successfully</h3>");
            } else {
                out.println("<h3 style='color:red'>Error registering user</h3>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h3 style='color:red'>Exception Occurred: " + e.getMessage() + "</h3>");
        }
    }
}
