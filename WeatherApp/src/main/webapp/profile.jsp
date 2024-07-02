<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
	        
	        // Optionally update UI or perform any other action after adding the city
	        // Example: Refresh the list of profile cities
	        // fetchProfileCities();
	    } catch (error) {
	        console.error('Error adding city to profile:', error);
	        alert('Error adding city to profile. Please try again later.');
	    }
	}

	async function fetchWeatherForCitiesInDatabase() {
	    try {
	        const url = "${pageContext.request.contextPath}/fetchCities";
	        const response = await fetch(url);
	        
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

	// Call fetchWeatherForCitiesInDatabase when the page loads
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
		
		<div class="LatLongSearch">
        <div class="search-container">
            <input id="latitudeInput" type="text" placeholder="Enter Latitude" spellcheck="false"/>
            <input id="longitudeInput" type="text" placeholder="Enter Longitude" spellcheck="false"/>
            <button onclick="fetchWeatherByCoordinates()">Search by Lat/Lon</button>
        </div>
    </div>
    
    <div class="CityNameSearch">
        <div class="search-container">
            <input id="cityNameInput" type="text" placeholder="Enter City Name" spellcheck="false" />
            <button onclick="fetchWeatherByCityName()">Search by City Name</button>
            <button onclick="addToProfilePage()">Add to Profile</button>
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
		
</body>
</html>