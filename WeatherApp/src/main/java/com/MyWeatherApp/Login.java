package com.MyWeatherApp;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/loginForm")
public class Login extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();

        String myEmail = req.getParameter("email1");
        String myPass = req.getParameter("pass1");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/UserRegistration", "root", "Kunal1234@");
            
            ps = con.prepareStatement("SELECT * FROM UserData WHERE Email=? AND Password=?");
            ps.setString(1, myEmail);
            ps.setString(2, myPass);
            
            rs = ps.executeQuery();
            if (rs.next()) {
                String userName = rs.getString("name");
                
                // Create a session if none exists, otherwise get the existing session
                HttpSession session = req.getSession(true);
                session.setAttribute("session_name", userName);
                session.setAttribute("session_email", myEmail);
                
                // Redirect to profile.jsp upon successful login
                resp.sendRedirect(req.getContextPath() + "/profile.jsp");
            } else {
                out.println("<h3 style='color:red'>Email Id and Password didn't match</h3>");
                RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
                rd.include(req, resp);
            }
            
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            out.println("<h3 style='color:red'>Exception Occurred :" + e.getMessage() + "</h3>");
            RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
            rd.include(req, resp);
        } finally {
            // Close resources in finally block to ensure they are released
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
