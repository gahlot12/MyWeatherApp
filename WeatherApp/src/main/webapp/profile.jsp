<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    // Check if session_name is not set, redirect to login.jsp
    if (session.getAttribute("session_name") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Profile Page</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/profileStyle.css">
<script>
	async function fetchWeatherByCoordinates() {
	    const lat = document.getElementById('latitudeInput').value.trim();
	    const lon = document.getElementById('longitudeInput').value.trim();
	    
	    if (lat === "" || lon === "") {
	        alert("Please enter latitude and longitude.");
	        return;
	    }
	    
	    try {
	        const url = "${pageContext.request.contextPath}/weatherData?lat=" + lat + "&lon=" + lon;
	        const response = await fetch(url);
	        
	        if (!response.ok) {
	            throw new Error('Network response was not ok');
	        }
	        
	        const data = await response.json();
	        
	        console.log(data);
	        
	        // Update UI with weather data
	        updateWeatherUI(data);
	    } catch (error) {
	        console.error('Error fetching weather data:', error);
	        alert('Error fetching weather data. Please try again later.');
	    }
	}
	
	async function fetchWeatherByCityName() {
	    const cityName = document.getElementById('cityNameInput').value.trim();
	    
	    if (cityName === "") {
	        alert("Please enter a city name.");
	        return;
	    }
	    
	    try {
	        const url = "${pageContext.request.contextPath}/weatherData?cityName=" + encodeURIComponent(cityName);
	        const response = await fetch(url);
	        
	        if (!response.ok) {
	            throw new Error('Network response was not ok');
	        }
	        
	        const data = await response.json();
	        
	        console.log(data);
	        
	        // Update UI with weather data
	        updateWeatherUI(data);
	    } catch (error) {
	        console.error('Error fetching weather data:', error);
	        alert('Error fetching weather data. Please try again later.');
	    }
	}
	
	function updateWeatherUI(data) {
        const cityNameElement = document.getElementById('cityName');
        const temperatureElement = document.getElementById('temperature');
        const descriptionElement = document.getElementById('description');

        if (data.name) {
            cityNameElement.textContent = data.name;
        } else {
            cityNameElement.textContent = "City not found";
        }

        if (data.main && data.main.temp) {
            temperatureElement.textContent = data.main.temp + "°C";
        } else {
            temperatureElement.textContent = "Temperature data not available";
        }

        if (data.weather && data.weather.length > 0 && data.weather[0].description) {
            descriptionElement.textContent = data.weather[0].description;
        } else {
            descriptionElement.textContent = "Weather description not available";
        }
    }
	
	async function addToProfilePage() {
	    const cityName = document.getElementById('cityNameInput').value.trim();
	    const email = '${session_name}';
	    
	    if (cityName === "") {
	        alert("Please enter a city name.");
	        return;
	    }
	    
	    try {
	        const url = "${pageContext.request.contextPath}/addCityToProfile";
	        const params = new URLSearchParams();
	        params.append('cityName', cityName);
	        params.append('email', email);
	        
	        const response = await fetch(url, {
	            method: 'POST',
	            body: params
	        });
	        
	        if (!response.ok) {
	            throw new Error('Network response was not ok');
	        }
	        
	        const result = await response.text();
	        alert(result); // Display the response message
	        
	        location.reload();
	        
	    } catch (error) {
	        console.error('Error adding city to profile:', error);
	        alert('Error adding city to profile. Please try again later.');
	    }
	}

	async function fetchWeatherForCitiesInDatabase() {
		const email = '${session_name}';
	    try {
	        const url = "${pageContext.request.contextPath}/fetchCities";
// 	        const response = await fetch(url);
	        const params = new URLSearchParams();
	        params.append('email', email);
	        const response = await fetch(url, {
	            method: 'POST',
	            body: params
	        });
	        console.log(response);
	        if (!response.ok) {
	            throw new Error('Failed to fetch city data');
	        }
	        
	        const cities = await response.json();
	        
	        const promises = cities.map(async cityName => {
	            const url = "${pageContext.request.contextPath}/weatherData?cityName=" + encodeURIComponent(cityName);
	            const response = await fetch(url);

	            if (!response.ok) {
	                throw new Error('Network response was not ok');
	            }

	            const data = await response.json();
	            console.log(data);
	            return data;
	        });

	        const results = await Promise.all(promises);

	        results.forEach(data => {
	            addCityWeatherToUI(data);
	        });
	    } catch (error) {
	        console.error('Error fetching weather data:', error);
	        alert('Error fetching weather data. Please try again later.');
	    }
	}

// 	Call fetchWeatherForCitiesInDatabase when the page loads
	window.onload = function() {
	    fetchWeatherForCitiesInDatabase();
	};

	function addCityWeatherToUI(data) {
	    const profileCitiesDiv = document.getElementById('profileCities');

	    const cityWeatherInfo = document.createElement('div');
	    cityWeatherInfo.classList.add('city-weather-info');

	    var cityName = data.name || "City not found";
	    var temperature = data.main?.temp || "Temperature data not available";
	    var description = data.weather?.[0]?.description || "Weather description not available";

	    const cityNameElement = document.createElement('h3');
	    const temperatureElement = document.createElement('p');
	    const descriptionElement = document.createElement('p');

	    cityNameElement.textContent = cityName;
	    temperatureElement.textContent = "Temperature: " + temperature + "°C";
	    descriptionElement.textContent = "Description: " + description;

	    cityWeatherInfo.appendChild(cityNameElement);
	    cityWeatherInfo.appendChild(temperatureElement);
	    cityWeatherInfo.appendChild(descriptionElement);

	    profileCitiesDiv.appendChild(cityWeatherInfo);
	}
	
	function fetchAndCalculateAverage(startDate, endDate, cityName) {
		if (endDate < startDate) {
	        const averageResult = document.getElementById('averageResult');
	        averageResult.innerHTML = "<p>Error: End date cannot be before start date. Please enter correct dates.</p>";
	        return;
	    }
	    fetch('./temp.json')
	        .then(res => res.json())
	        .then(data => {
	            const cities = data.cities; // Corrected variable name
	            const cityData = cities.find(city => city.city === cityName); // Corrected variable name
	            if (cityData) {
	                const temperatures = cityData.temperatures;
	                let total = 0;
	                let count = 0;

	                // Iterate through each date in the temperatures object
	                for (const date in temperatures) {
	                    if (date >= startDate && date <= endDate) {
	                        total += temperatures[date];
	                        count++;
	                    }
	                }

	                if (count > 0) {
	                    const average = total / count;
	                    // Display average temperature on the web page
	                    const averageResult = document.getElementById('averageResult');
	                    averageResult.innerHTML = "<p>Average temperature in " + cityName +" between " + startDate + " and " + endDate + " is " + average.toFixed(2) + " °C</p>";
	                } else {
	                    console.log("No temperature data found between " + startDate + " and " + endDate);
	                    // Display message if no data found
	                    const averageResult = document.getElementById('averageResult');
	                    averageResult.innerHTML = "<p>No temperature data found between " + startDate + " and " + endDate + "</p>";
	                }
	            } else {
	                console.log("City '" + cityName + "' not found in the data");
	                // Display message if city not found
	                const averageResult = document.getElementById('averageResult');
	                averageResult.innerHTML = "<p>City '" + cityName + "' not found in the data</p>";
	            }
	        })
	        .catch(err => console.error('Error fetching data:', err));
	}


	
	//fetchAndCalculateAverage('2023-07-10', '2023-09-20','Delhi');


</script>
</head>
<body>
    <div class="navbar">
        <div class="left">
            <h3>Welcome ${session_name}</h3>
        </div>
        <div class="right">
            <a href="logout"><button>Logout</button></a>
        </div>
    </div>

    <div id="content-container">

        <div id="left-container">
            <div class="CityNameSearch">
                <div class="search-container">
                    <input id="cityNameInput" type="text" placeholder="Enter City Name" spellcheck="false" />
                    <button onclick="fetchWeatherByCityName()">Search by City Name</button>
                    <button onclick="addToProfilePage()">Add to Profile</button>
                </div>
            </div>

            <div class="LatLongSearch">
                <div class="search-container">
                    <input id="latitudeInput" type="text" placeholder="Enter Latitude" spellcheck="false"/>
                    <input id="longitudeInput" type="text" placeholder="Enter Longitude" spellcheck="false"/>
                    <button onclick="fetchWeatherByCoordinates()">Search by Lat/Lon</button>
                </div>
            </div>

            <div class="weather-container">
                <h2>Weather in <span id="cityName"></span></h2>
                <p>Temperature: <span id="temperature"></span></p>
                <p>Description: <span id="description"></span></p>
            </div>

            <div class="profile-cities">
                <h2>Weather in Your Profile Cities</h2>
                <div id="profileCities">
                    <!-- Cities will be dynamically added here -->
                </div>
            </div>
        </div>

        <div id="right-container">
            <div>
                <h2>Calculate Average Temperature</h2>
                <form onsubmit="event.preventDefault(); fetchAndCalculateAverage(startDate.value, endDate.value, city.value);">
                    
                    <label for="startDate">Start Date:</label>
                    <input type="text" id="startDate" name="startDate" placeholder="yyyy-mm-dd"><br><br>
                    
                    <label for="endDate">End Date:</label>
                    <input type="text" id="endDate" name="endDate" placeholder="yyyy-mm-dd"><br><br>
        
                    <label for="city">Select City:</label>
                    <select id="city" name="city">
                        <option value="select">select</option>
                        <option value="Jaipur">Jaipur</option>
                        <option value="Pune">Pune</option>
                        <option value="Delhi">Delhi</option>
                        <option value="Mumbai">Mumbai</option>
                    </select><br><br>
                    
                    <button type="submit">Calculate</button>
                </form>
                <div id="averageResult">
                    <!-- Average temperature result will be displayed here -->
                </div>
            </div>
            
            <div>
		        <h2>Calculate Average Temperature</h2>
		        <form action="avgTemp" method="post">
		            <label for="startDate">Start Date:</label>
		            <input type="text" id="startDate" name="startDate" placeholder="yyyy-mm-dd"><br><br>
		            
		            <label for="endDate">End Date:</label>
		            <input type="text" id="endDate" name="endDate" placeholder="yyyy-mm-dd"><br><br>
		
		            <label for="city">Select City:</label>
		            <select id="city" name="city">
		                <option value="select">select</option>
		                <option value="Jaipur">Jaipur</option>
		                <option value="Pune">Pune</option>
		                <option value="Delhi">Delhi</option>
		                <option value="Mumbai">Mumbai</option>
		            </select><br><br>
		            
		            <button type="submit">Calculate</button>
		        </form>
		        <div id="averageResult">
		            <!-- Average temperature result will be displayed here -->
		            <c:if test="${not empty averageTemperatureResult}">
<!-- 		                <h2>Average Temperature Result</h2> -->
		                <p>${averageTemperatureResult}</p>
		            </c:if>
		<%--             <c:if test="${empty averageTemperatureResult}"> --%>
		<!--                 <p>No average temperature result available</p> -->
		<!--             </c:if> -->
		        </div>
		    
        	</div>
	</div>
    
    </div>

    
</body>
</html>