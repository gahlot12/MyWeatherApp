package com.MyWeatherApp;

import java.io.IOException;
//import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;

@WebServlet("/addCityToProfile")
public class AddCityToProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
//        PrintWriter out = response.getWriter();

//        HttpSession session = request.getSession();
//        String email = (String)request.getParameter("email");
        String cityName = request.getParameter("cityName");

        if (cityName != null && !cityName.isEmpty()) {
            Connection conn = null;
            PreparedStatement stmt = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/UserRegistration", "root", "Kunal1234@");

                String sql = "INSERT INTO CityName (cityname) VALUES (?)";
                stmt = conn.prepareStatement(sql);
//                stmt.setString(1, email);
                stmt.setString(1, cityName);

                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    // City added successfully
                    response.getWriter().write("City added to profile!");
                } else {
                    // Failed to add city
                    response.getWriter().write("Failed to add city to profile.");
                }

            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
                response.getWriter().write("<h3 style='color:red'>Exception Occurred: " + e.getMessage() + "</h3>");
            } finally {
                // Close resources in finally block to ensure they are released
                try {
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

        } else {
            response.getWriter().write("Invalid request.");
        }
    }
}

