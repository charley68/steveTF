import requests
import json

# Define the API endpoint
url = "https://2zbtwrbhwj.execute-api.eu-west-2.amazonaws.com/development"

# Define the headers
headers = {
    "Content-Type": "application/json",  # Ensure the content type is JSON
    "x-api-key": "aFywy3hzAn4rpMtR5bxPY5iuBud6k3Ie9bQzEq3s"
}

# Define the JSON body
data = {
    "Server": "ICTradingMT5",
    "Account": "237262",
    "Equity": 1000,
    "Balance": 99999
}


# Make the POST request
response = requests.post(url, headers=headers, json=data)

# Check the response
if response.status_code == 200:
    print("Request was successful!")
    print("Response data:", response.json())
else:
    print(f"Request failed with status code {response.status_code}")
    print("Response text:", response.text)

