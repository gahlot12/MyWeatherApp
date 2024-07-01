<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MyWeatherApp</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
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
    
    async function fetchWeatherForBigCities() {
        const cities = ['New York', 'London', 'Paris', 'Tokyo', 'Beijing']; // Example cities
        try {
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


    function addCityWeatherToUI(data) {
        const cityWeatherDiv = document.getElementById('bigCityWeather');

        const cityWeatherInfo = document.createElement('div');
        cityWeatherInfo.classList.add('city-weather-info');

        var cityName = data.name || "City not found";
        var temperature = data.main?.temp || "Temperature data not available";
        var description = data.weather?.[0]?.description || "Weather description not available";
		console.log(cityName);
		console.log(temperature);
		console.log(description);
		
		const cityNameElement = document.createElement('h3');
		const temperatureElement = document.createElement('p');
		const descriptionElement = document.createElement('p');
		
		cityNameElement.innerHTML = cityName
		temperatureElement.innerHTML = "Temperature: " + temperature
		descriptionElement.innerHTML = "Description:" + description
		
       // cityWeatherInfo.innerHTML += `
	   //     <h3>${data.name}</h3>
	   //     <p>Temperature: ${{temperature}}°C</p>
	   //     <p>Description: ${{description}}</p>
       // `;
       cityWeatherInfo.appendChild(cityNameElement)
       cityWeatherInfo.appendChild(temperatureElement)
       cityWeatherInfo.appendChild(descriptionElement)
       console.log(cityWeatherInfo)

        cityWeatherDiv.appendChild(cityWeatherInfo);
    }
    
    // Call fetchWeatherForBigCities when the page loads
    window.addEventListener('load', () => {
        fetchWeatherForBigCities().catch(error => {
            console.error('Error fetching weather for big cities:', error);
            alert('Error fetching weather data for big cities. Please try again later.');
        });
    });

</script>
</head>
<body>
    <div class="navbar">
        <div class="left">
            <img height="40px" width="120px" src="${pageContext.request.contextPath}/images/weatherApp.JPG" alt="MyWeatherApp">
        </div>
        <div class="right">
            <a href="register.jsp"><button>Register</button></a>
            <a href="login.jsp"><button>Login</button></a>
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
        </div>
    </div>

    <div class="weather-container">
        <h2>Weather in <span id="cityName"></span></h2>
        <p>Temperature: <span id="temperature"></span></p>
        <p>Description: <span id="description"></span></p>
    </div>
    
    <div class="big-cities">
        <h2 style="text-align: center;">Weather in Big Cities</h2>
        <div class="city-weather" id="bigCityWeather">
            <!-- Weather data for big cities will be dynamically added here -->
        </div>
    </div>
    
</body>
</html>