package com.MyWeatherApp;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONException;
import org.json.JSONObject;

@WebServlet("/weatherData")
public class WeatherDataServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");

        // Retrieve latitude and longitude from request parameters
        String latitude = request.getParameter("lat");
        String longitude = request.getParameter("lon");
        String cityName = request.getParameter("cityName"); // For city name search
        String APIKey = "24d3c018caabc4ce62383f54acff7d81"; // Replace with your OpenWeatherMap API key

        // Validate inputs
        if ((latitude == null || latitude.isEmpty() || longitude == null || longitude.isEmpty()) && (cityName == null || cityName.isEmpty())) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("Latitude and longitude or city name must be provided.");
            return;
        }

        // Construct API URL based on input type
        String APIURL = "";
        if (latitude != null && !latitude.isEmpty() && longitude != null && !longitude.isEmpty()) {
            APIURL = "https://api.openweathermap.org/data/2.5/weather?lat=" + latitude + "&lon=" + longitude
                    + "&appid=" + APIKey + "&units=metric";
        } else if (cityName != null && !cityName.isEmpty()) {
            APIURL = "https://api.openweathermap.org/data/2.5/weather?q=" + cityName
                    + "&appid=" + APIKey + "&units=metric";
        }

        try {
            URL url = new URL(APIURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuffer responseContent = new StringBuffer();

                while ((inputLine = in.readLine()) != null) {
                    responseContent.append(inputLine);
                }
                in.close();

                // Parse JSON response
                JSONObject jsonResponse = new JSONObject(responseContent.toString());
                response.getWriter().print(jsonResponse);
            } else {
                // Handle HTTP errors
                response.setStatus(responseCode);
                response.getWriter().print("Error fetching weather data: HTTP status code " + responseCode);
            }
        } catch (IOException e) {
            // Handle IO exceptions
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("Error fetching weather data: " + e.getMessage());
        } catch (JSONException e) {
            // Handle JSON parsing errors
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("Error parsing weather data: " + e.getMessage());
        }
    }
}
