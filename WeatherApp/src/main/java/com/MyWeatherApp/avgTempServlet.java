package com.MyWeatherApp;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/avgTemp")
public class avgTempServlet extends HttpServlet {

	private static final String JSON_FILE_PATH = "C:/Users/kunal gahlot/eclipse-workspace/WeatherApp/src/main/webapp/temp.json";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String city = request.getParameter("city");

        LocalDate startDate = LocalDate.parse(startDateStr);
        LocalDate endDate = LocalDate.parse(endDateStr);

        if (endDate.isBefore(startDate)) {
            String errorMessage = "Error: End date cannot be before start date. Please enter correct dates.";
            request.setAttribute("averageTemperatureResult", errorMessage);
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }
        
        String jsonContent = readJsonFile(JSON_FILE_PATH);
        Map<String, Object> jsonData = parseJson(jsonContent);

        Map<String, Double> temperatures = findTemperatures(jsonData, city);

        double averageTemperature = calculateAverageTemperature(temperatures, startDate, endDate);

        String resultMessage = String.format("Average temperature from %s to %s in %s: %.2f °C",
                startDateStr, endDateStr, city, averageTemperature);

        // Set result message in request attribute to be accessed in JSP
        request.setAttribute("averageTemperatureResult", resultMessage);

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
//        request.getRequestDispatcher("/avgTemp.jsp").forward(request, response);
    }

    private String readJsonFile(String filePath) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            return reader.lines().collect(Collectors.joining());
        }
    }

    private Map<String, Object> parseJson(String jsonContent) {
        Map<String, Object> jsonData = new HashMap<>();

        try {
            JSONObject jsonObject = new JSONObject(jsonContent);
            JSONArray citiesArray = jsonObject.getJSONArray("cities");

            for (int i = 0; i < citiesArray.length(); i++) {
                JSONObject cityObject = citiesArray.getJSONObject(i);
                String cityName = cityObject.getString("city");
                JSONObject temperaturesObject = cityObject.getJSONObject("temperatures");

                // Modify this part according to your JSON structure
                Map<String, Double> cityTemperatures = new HashMap<>();
                for (String key : temperaturesObject.keySet()) {
                    double temperature = temperaturesObject.getDouble(key);
                    cityTemperatures.put(key, temperature);
                }

                jsonData.put(cityName, cityTemperatures);
            }
        } catch (Exception e) {
            e.printStackTrace(); 
        }

        return jsonData;
    }

    private Map<String, Double> findTemperatures(Map<String, Object> jsonData, String city) {
        if (jsonData.containsKey(city)) {
            return (Map<String, Double>) jsonData.get(city);
        }
        return new HashMap<>();
    }

    private double calculateAverageTemperature(Map<String, Double> temperatures, LocalDate startDate, LocalDate endDate) {
        double sum = 0.0;
        int count = 0;

        // Calculate average temperature for the specified date range
        for (Map.Entry<String, Double> entry : temperatures.entrySet()) {
            LocalDate date = LocalDate.parse(entry.getKey());
            if (!date.isBefore(startDate) && !date.isAfter(endDate)) {
                sum += entry.getValue();
                count++;
            }
        }

        if (count > 0) {
            return sum / count;
        } else {
            return 0.0;
        }
    }
}
