require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "52a816c4142a34897aadfd15c557c79f"

get "/" do
  # show a view that asks for the location
  view "home"
end

get "/weather" do
  # do everything else
  @Location = params["location"]
  results = Geocoder.search(@Location)
  lat_lng = results.first.coordinates
  lat = lat_lng[0]
  lng = lat_lng[1]

  # entering in 
  forecast = ForecastIO.forecast(lat,lng).to_hash
  @current_temp = forecast["currently"]["temperature"]
  @current_summary = forecast["currently"]["summary"]

  daily_forecast_data = forecast["daily"]["data"]
  @daily_high = []
  @daily_low = []
  @daily_summary = []
	
	for day in daily_forecast_data
		@daily_high << day["temperatureHigh"]
		@daily_low << day["temperatureLow"]
		@daily_summary << day["summary"]
  end

	# news api
	url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=341f5b707fa44326944bd9903e37301b"
	@news = HTTParty.get(url).parsed_response.to_hash
	num_results = @news["totalResults"]
	@articles = @news["articles"]

  view "weather"
end
