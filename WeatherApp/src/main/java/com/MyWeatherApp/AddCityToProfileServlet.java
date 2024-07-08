package com.MyWeatherApp;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/addCityToProfile")
public class AddCityToProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");

        String email = request.getParameter("email");
        String cityName = request.getParameter("cityName");

        if (email == null || email.isEmpty() || cityName == null || cityName.isEmpty()) {
            response.getWriter().write("Invalid request.");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/UserRegistration", "root", "Kunal1234@");

            // Check if city already exists for the user
            String checkSql = "SELECT COUNT(*) AS count FROM usersCity WHERE email = ? AND cityname = ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setString(1, email);
            stmt.setString(2, cityName);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt("count");
                if (count > 0) {
                    response.getWriter().write("City is already added to your profile.");
                    return;
                }
            }

            // If city doesn't exist, insert it into the database
            String insertSql = "INSERT INTO usersCity (email, cityname) VALUES (?, ?)";
            stmt = conn.prepareStatement(insertSql);
            stmt.setString(1, email);
            stmt.setString(2, cityName);

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                response.getWriter().write("City added to your profile!");
            } else {
                response.getWriter().write("Failed to add city to your profile.");
            }

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.getWriter().write("<h3 style='color:red'>Exception Occurred: " + e.getMessage() + "</h3>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
