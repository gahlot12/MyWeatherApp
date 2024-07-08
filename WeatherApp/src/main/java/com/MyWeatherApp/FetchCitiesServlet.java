package com.MyWeatherApp;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


import org.json.JSONArray;
import org.json.JSONException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/fetchCities")
public class FetchCitiesServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        
        // Connect to the database
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        HttpSession session = request.getSession();
        String userEmail = request.getParameter("email");
        
        if (userEmail == null || userEmail.isEmpty()) {
            response.getWriter().write("{\"error\": \"User not logged in\"}");
            return;
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/UserRegistration", "root", "Kunal1234@");

            String sql = "SELECT cityname FROM usersCity WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, userEmail);
            rs = stmt.executeQuery();
            
            List<String> cities = new ArrayList<>();
            while (rs.next()) {
                String cityName = rs.getString("cityname");
                cities.add(cityName);
            }
            
            // Convert list to JSON array
            JSONArray jsonArray = new JSONArray(cities);
            
            // Send JSON response
            PrintWriter out = response.getWriter();
            out.print(jsonArray);
            
        } catch (ClassNotFoundException | SQLException | JSONException e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"Error fetching cities\"}");
        } finally {
            // Close resources
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
