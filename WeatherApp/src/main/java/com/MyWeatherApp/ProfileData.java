package com.MyWeatherApp;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
//import javax.annotation.Resource;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import javax.sql.DataSource;

@WebServlet("/ProfileData")
public class ProfileData extends HttpServlet {
    
    // Injecting DataSource for database connection
    @Resource(name="jdbc/UserRegistration")
    private DataSource dataSource;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve cityName parameter from the request
        String cityName = request.getParameter("cityName").trim();
        
        // Retrieve user_id from session (you need to set this when the user logs in)
        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("user_id"); // Assuming user_id is stored in session
        
        // Set content type for response
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        if (cityName.isEmpty()) {
            out.write("City name is required");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // Get connection from the connection pool
            conn = dataSource.getConnection();
            
            // SQL query to insert weather data
            String sql = "INSERT INTO WeatherData (user_id, city_name) VALUES (?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setString(2, cityName);
            
            // Execute the query
            int rowsInserted = pstmt.executeUpdate();
            
            if (rowsInserted > 0) {
                out.write("City '" + cityName + "' added successfully to your profile!");
            } else {
                out.write("Failed to add city '" + cityName + "' to your profile");
            }
        } catch (SQLException e) {
            out.write("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Close PreparedStatement and Connection
            try {
                if (pstmt != null) {
                    pstmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
