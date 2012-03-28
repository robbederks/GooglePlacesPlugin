# encoding: UTF-8
require 'cora'
require 'siri_objects'
#require 'google_places'
require 'httparty'
require 'json'

%w(client location request spot).each do |file|
  require File.join(File.dirname(__FILE__), 'google_places', file)
end

class SiriProxy::Plugin::GPP < SiriProxy::Plugin
  def initialize(config)
  end
  
  filter "SetRequestOrigin", direction: :from_iphone do |object|
  puts object
  if object["properties"]["status"] != "Denied"
    @locationLat = Float(object["properties"]["latitude"])
    @locationLong = Float(object["properties"]["longitude"])
  else
	@locationLat = nil
    @locationLong = nil
  end	
  end 
  
  
 listen_for /where am i/i do
	say "Searching..."
	if @locationLat != nil && @locationLong !=nil
		url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{@locationLat},#{@locationLong}&sensor=true&language=en-US"
		@response = Net::HTTP.get(URI.parse(url))
		@result = JSON.parse(@response)
		puts @result
		if @result != nil
			if @result["status"] == "ZERO_RESULTS"
				say "Your address could not be determined. I will show you a map."
				add_views = SiriAddViews.new
				add_views.make_root(last_ref_id)
				map_snippet = SiriMapItemSnippet.new
				item = SiriMapItem.new
				item.label = "My location"
				location = SiriLocation.new
				location.latitude = @locationLat
				location.longitude = @locationLong
				item.location = location
				map_snippet.items << item
				add_views.views << map_snippet
				send_object add_views
			elsif @result["status"] == "OK"
				@fullAddress = ""
				@number = ""
				@street = ""
				@city = ""
				@state = ""
				@country = ""
				@countrycode = ""
				@postalcode = ""
				if @result["results"][0]["formatted_address"] != nil
					@fullAddress = @result["results"][0]["formatted_address"]
				end
				if @result["results"][0]["address_components"][0]["long_name"] != nil
					@number = @result["results"][0]["address_components"][0]["long_name"]
				end
				if @result["results"][0]["address_components"][1]["long_name"] !=nil
					@street = @result["results"][0]["address_components"][1]["long_name"]
				end
				if @result["results"][0]["address_components"][2]["long_name"] !=nil
					@city = @result["results"][0]["address_components"][2]["long_name"]
				end
				if @result["results"][0]["address_components"][3]["short_name"] !=nil
					@state = @result["results"][0]["address_components"][3]["short_name"]
				end
				if @result["results"][0]["address_components"][5]["long_name"] !=nil
					@country = @result["results"][0]["address_components"][5]["long_name"]
				end
				if @result["results"][0]["address_components"][5]["short_name"] !=nil
					@countrycode = @result["results"][0]["address_components"][5]["short_name"]
				end
				if @result["results"][0]["address_components"][6]["long_name"] !=nil
					@postalcode = @result["results"][0]["address_components"][6]["long_name"]
				end
				add_views = SiriAddViews.new
				add_views.make_root(last_ref_id)
				map_snippet = SiriMapItemSnippet.new
				item = SiriMapItem.new
				item.label = "My location"
				location = SiriLocation.new
				location.label = @fullAddress
				location.latitude = @locationLat
				location.longitude = @locationLong
				location.street = @street
				location.city = @city
				location.stateCode = @state
				location.countryCode = @countrycode
				location.postalCode = @postalcode
				item.location = location
				map_snippet.items << item
				add_views.views << map_snippet
				say "You are here: #{@fullAddress}"
				send_object add_views
			else
				say "Your location couldn't be determined"
			end
		else
			say "Google Places didn't work at the moment. Try again later."
		end
	else
		say "No location data available. Please ensure your locations are turned on."
	end
	request_completed
 end
 
 listen_for /supported places/i do
	say "These are supported place types:"
	places_array = ["accounting"=>"accounting", "airport"=>"airport", "amusementpark"=>"amusement_park", "aquarium"=>"aquarium", "artgallery"=>"art_gallery", "atm"=>"atm", "bakery"=>"bakery", "bank"=>"bank", "bar"=>"bar", "beautysalon"=>"beauty_salon", "bicyclestore"=>"bicycle_store", "bookstore"=>"book_store", "bowlingalley"=>"bowling_alley", "busstation"=>"bus_station", "cafe"=>"cafe", "campground"=>"campground", "cardealer"=>"car_dealer", "carrental"=>"car_rental", "carrepair"=>"car_repair", "carwash"=>"car_wash", "casino"=>"casino", "cemetery"=>"cemetery", "church"=>"church", "cityhall"=>"city_hall", "clothingstore"=>"clothing_store", "conveniencestore"=>"convenience_store", "courthouse"=>"courthouse", "dentist"=>"dentist", "departmentstore"=>"department_store", "doctor"=>"doctor", "electrician"=>"electrician", "electronicsstore"=>"electronics_store", "embassy"=>"embassy", "establishment"=>"establishment", "finance"=>"finance", "firestation"=>"fire_station", "florist"=>"florist", "food"=>"food", "funeralhome"=>"funeral_home", "furniturestore"=>"furniture_store", "gasstation"=>"gas_station", "generalcontractor"=>"general_contractor", "geocode"=>"geocode", "groceryorsupermarket"=>"grocery_or_supermarket", "gym"=>"gym", "haircare"=>"hair_care", "hardwarestore"=>"hardware_store", "health"=>"health", "hindutemple"=>"hindu_temple", "homegoodsstore"=>"home_goods_store", "hospital"=>"hospital", "insuranceagency"=>"insurance_agency", "jewelrystore"=>"jewelry_store", "laundry"=>"laundry", "lawyer"=>"lawyer", "library"=>"library", "liquorstore"=>"liquor_store", "localgovernmentoffice"=>"local_government_office", "locksmith"=>"locksmith", "lodging"=>"lodging", "mealdelivery"=>"meal_delivery", "mealtakeaway"=>"meal_takeaway", "mosque"=>"mosque", "movierental"=>"movie_rental", "movietheater"=>"movie_theater", "movingcompany"=>"moving_company", "museum"=>"museum", "nightclub"=>"night_club", "painter"=>"painter", "park"=>"park", "parking"=>"parking", "petstore"=>"pet_store", "pharmacy"=>"pharmacy", "physiotherapist"=>"physiotherapist", "placeofworship"=>"place_of_worship", "plumber"=>"plumber", "police"=>"police", "postoffice"=>"post_office", "realestateagency"=>"real_estateagency", "restaurant"=>"restaurant", "roofingcontractor"=>"roofing_contractor", "rvpark"=>"rv_park", "school"=>"school", "shoestore"=>"shoe_store", "shoppingmall"=>"shopping_mall", "spa"=>"spa", "stadium"=>"stadium", "storage"=>"storage", "store"=>"store", "subwaystation"=>"subway_station", "synagogue"=>"synagogue", "taxistand"=>"taxi_stand", "trainstation"=>"train_station", "travelagency"=>"travel_agency", "university"=>"university", "veterinarycare"=>"veterinary_care", "zoo"=>"zoo"]
	namesArray = places_array[0].keys
	nameString = ""
	for name in namesArray do
		nameString << "#{name}, "
	end
	say "#{nameString}", spoken: ""
	request_completed
 end
 
 listen_for /nearby (.*)/i do |spokenPlace|
	if @locationLat != nil
		places_array = ["accounting"=>"accounting", "airport"=>"airport", "amusementpark"=>"amusement_park", "aquarium"=>"aquarium", "artgallery"=>"art_gallery", "atm"=>"atm", "bakery"=>"bakery", "bank"=>"bank", "bar"=>"bar", "beautysalon"=>"beauty_salon", "bicyclestore"=>"bicycle_store", "bookstore"=>"book_store", "bowlingalley"=>"bowling_alley", "busstation"=>"bus_station", "cafe"=>"cafe", "campground"=>"campground", "cardealer"=>"car_dealer", "carrental"=>"car_rental", "carrepair"=>"car_repair", "carwash"=>"car_wash", "casino"=>"casino", "cemetery"=>"cemetery", "church"=>"church", "cityhall"=>"city_hall", "clothingstore"=>"clothing_store", "conveniencestore"=>"convenience_store", "courthouse"=>"courthouse", "dentist"=>"dentist", "departmentstore"=>"department_store", "doctor"=>"doctor", "electrician"=>"electrician", "electronicsstore"=>"electronics_store", "embassy"=>"embassy", "establishment"=>"establishment", "finance"=>"finance", "firestation"=>"fire_station", "florist"=>"florist", "food"=>"food", "funeralhome"=>"funeral_home", "furniturestore"=>"furniture_store", "gasstation"=>"gas_station", "generalcontractor"=>"general_contractor", "geocode"=>"geocode", "groceryorsupermarket"=>"grocery_or_supermarket", "gym"=>"gym", "haircare"=>"hair_care", "hardwarestore"=>"hardware_store", "health"=>"health", "hindutemple"=>"hindu_temple", "homegoodsstore"=>"home_goods_store", "hospital"=>"hospital", "insuranceagency"=>"insurance_agency", "jewelrystore"=>"jewelry_store", "laundry"=>"laundry", "lawyer"=>"lawyer", "library"=>"library", "liquorstore"=>"liquor_store", "localgovernmentoffice"=>"local_government_office", "locksmith"=>"locksmith", "lodging"=>"lodging", "mealdelivery"=>"meal_delivery", "mealtakeaway"=>"meal_takeaway", "mosque"=>"mosque", "movierental"=>"movie_rental", "movietheater"=>"movie_theater", "movingcompany"=>"moving_company", "museum"=>"museum", "nightclub"=>"night_club", "painter"=>"painter", "park"=>"park", "parking"=>"parking", "petstore"=>"pet_store", "pharmacy"=>"pharmacy", "physiotherapist"=>"physiotherapist", "placeofworship"=>"place_of_worship", "plumber"=>"plumber", "police"=>"police", "postoffice"=>"post_office", "realestateagency"=>"real_estateagency", "restaurant"=>"restaurant", "roofingcontractor"=>"roofing_contractor", "rvpark"=>"rv_park", "school"=>"school", "shoestore"=>"shoe_store", "shoppingmall"=>"shopping_mall", "spa"=>"spa", "stadium"=>"stadium", "storage"=>"storage", "store"=>"store", "subwaystation"=>"subway_station", "synagogue"=>"synagogue", "taxistand"=>"taxi_stand", "trainstation"=>"train_station", "travelagency"=>"travel_agency", "university"=>"university", "veterinarycare"=>"veterinary_care", "zoo"=>"zoo"]
		spokenPlace = spokenPlace.gsub(/\s+/, "")
		typeOfPlace = places_array[0][spokenPlace]
		if typeOfPlace == nil
			say "That place type (#{spokenPlace}) isn't supported! Make sure you aren't using the plural. Say 'supported places' for a list of supported ones."
			request_completed
		else
		say "Searching..."
		add_views = SiriAddViews.new
		add_views.make_root(last_ref_id)
		map_snippet = SiriMapItemSnippet.new
		@client = GooglePlaces::Client.new("AIzaSyCstlsR2RirOI8wJxtgphqD3NE-bHex7X4")
		@places = @client.spots(@locationLat, @locationLong, :types => typeOfPlace, :radius => 5000)
		if @places[0] != nil
			for @place in @places do
				if @place.rating != nil 
					avg_rating = @place.rating
				else
					avg_rating = 0.0
				end		
				name = @place.name
				adress = @place.vicinity
				latitude = @place.lat
				longtitude = @place.lng
				icon = @place.icon
				location = SiriLocation.new
				location.label = name
				location.street, location.city = adress.split(/, /)
				location.latitude = latitude
				location.longitude = longtitude
				item = SiriMapItem.new
				item.label = name
				item.location = location
				map_snippet.items << item
			end	
			utterance = SiriAssistantUtteranceView.new("These are the #{spokenPlace}s in a range of 5km:")
			add_views.views << utterance	
			add_views.views << map_snippet
			#you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
			send_object add_views #send_object takes a hash or a SiriObject object
		else
			say "I haven't found any #{spokenPlace}s!"
		end
		end
	else
		say "No location data available. Please ensure your locations are turned on."
	end
	request_completed #always complete your request! Otherwise the phone will "spin" at the user!
end
  
  listen_for /Wo bin ich/i do
	say "Suche..."
	if @locationLat != nil
		url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{@locationLat},#{@locationLong}&sensor=true&language=en-US"
		@response = Net::HTTP.get(URI.parse(url))
		@result = JSON.parse(@response)
		puts @result
		if @result["status"] == "ZERO_RESULTS"
			say "Your address could not be determined. I will show you a map."
			add_views = SiriAddViews.new
			add_views.make_root(last_ref_id)
			map_snippet = SiriMapItemSnippet.new
			item = SiriMapItem.new
			item.label = "My location"
			location = SiriLocation.new
			location.latitude = @locationLat
			location.longitude = @locationLong
			item.location = location
			map_snippet.items << item
			add_views.views << map_snippet
			send_object add_views
		elsif @result != nil
			@fullAddress = ""
			@number = ""
			@street = ""
			@city = ""
			@state = ""
			@country = ""
			@countrycode = ""
			@postalcode = ""
			if @result["results"][0]["formatted_address"] != nil
				@fullAddress = @result["results"][0]["formatted_address"]
			end
			if @result["results"][0]["address_components"][0]["long_name"] != nil
				@number = @result["results"][0]["address_components"][0]["long_name"]
			end
			if @result["results"][0]["address_components"][1]["long_name"] !=nil
				@street = @result["results"][0]["address_components"][1]["long_name"]
			end
			if @result["results"][0]["address_components"][2]["long_name"] !=nil
				@city = @result["results"][0]["address_components"][2]["long_name"]
			end
			if @result["results"][0]["address_components"][3]["short_name"] !=nil
				@state = @result["results"][0]["address_components"][3]["short_name"]
			end
			if @result["results"][0]["address_components"][5]["long_name"] !=nil
				@country = @result["results"][0]["address_components"][5]["long_name"]
			end
			if @result["results"][0]["address_components"][5]["short_name"] !=nil
				@countrycode = @result["results"][0]["address_components"][5]["short_name"]
			end
			if @result["results"][0]["address_components"][6]["long_name"] !=nil
				@postalcode = @result["results"][0]["address_components"][6]["long_name"]
			end
			add_views = SiriAddViews.new
			add_views.make_root(last_ref_id)
			map_snippet = SiriMapItemSnippet.new
			item = SiriMapItem.new
			item.label = "My location"
			location = SiriLocation.new
			location.label = @fullAddress
			location.latitude = @locationLat
			location.longitude = @locationLong
			location.street = @street
			location.city = @city
			location.stateCode = @state
			location.countryCode = @countrycode
			location.postalCode = @postalcode
			item.location = location
			map_snippet.items << item
			add_views.views << map_snippet
			say "You are here: #{@fullAddress}"
			send_object add_views
		else
			say "Your location couldn't be determined"
		end
	else
		say "No location data available. Please ensure your locations are turned on."
	end
	request_completed	
 end
 
 listen_for /Unterstützte Orte/i do
	say "Dies sind alle Unterstützten Ort:"
	say "Dieses plugin ist noch nicht fertiggestellt!"
	request_completed
 end
 
 listen_for /(.*) In der nähe/i do |spokenPlace|
	if @locationLat != nil
		places_array = ["Buchhalter"=>"accounting", "Flughafen"=>"airport", "Vergnügunspark"=>"amusement_park", "Freizeitpark"=>"amusement_park", "Aquarium"=>"aquarium", "Kunstausstellung"=>"art_gallery", "Kunstmuseum"=>"art_gallery","Geldautomat"=>"atm", "Bäckerei"=>"bakery", "Bank"=>"bank", "Bar"=>"bar", "Schönheits Salon"=>"beauty_salon", "Fahrradgeschäft"=>"bicycle_store", "Buchladen"=>"book_store", "Bücherei"=>"book_store", "Bowlingbahn"=>"bowling_alley", "Bushaltestelle"=>"bus_station", "Cafe"=>"cafe", "Campingplatz"=>"campground", "Autohändler"=>"car_dealer", "Autovermietung"=>"car_rental", "Autoreparatur"=>"car_repair", "Kfz Werkstatt"=>"car_repair", "Waschstraße"=>"car_wash", "Casino"=>"casino", "Friedhof"=>"cemetery", "Kirche"=>"church", "Rathaus"=>"city_hall", "Kleidungsgeschäft"=>"clothing_store", "Supermarkt"=>"convenience_store", "Gericht"=>"courthouse", "Zahnarzt"=>"dentist", "Kaufhaus"=>"department_store", "Doctor"=>"doctor", "Arzt"=>"doctor", "Elektriker"=>"electrician", "Elektronikgeschäft"=>"electronics_store", "Botschaft"=>"embassy", "establishment"=>"establishment", "finance"=>"finance", "Feuerwehr"=>"fire_station", "Blumenhändler"=>"florist", "Essen"=>"food", "Bestattungsinstitut"=>"funeral_home", "Möbelhaus"=>"furniture_store", "Tankstelle"=>"gas_station", "generalcontractor"=>"general_contractor", "geocode"=>"geocode", "groceryorsupermarket"=>"grocery_or_supermarket", "Sporthalle"=>"gym", "Friseur"=>"hair_care", "hardwarestore"=>"hardware_store", "health"=>"health", "Hindutempel"=>"hindu_temple", "homegoodsstore"=>"home_goods_store", "Krankenhaus"=>"hospital", "Versicherung"=>"insurance_agency", "Juwelier"=>"jewelry_store", "Wäscherei"=>"laundry", "Anwalt"=>"lawyer", "library"=>"library", "Spirituosengeschäft"=>"liquor_store", "localgovernmentoffice"=>"local_government_office", "Schlosser"=>"locksmith", "Unterkunft"=>"lodging", "mealdelivery"=>"meal_delivery", "mealtakeaway"=>"meal_takeaway", "Moschee"=>"mosque", "Videothek"=>"movie_rental", "Kino"=>"movie_theater", "Filmhersteller"=>"moving_company", "Museum"=>"museum", "Nachtclub"=>"night_club", "Maler"=>"painter", "park"=>"park", "Parkplatz"=>"parking", "Tierhandlung"=>"pet_store", "Apotheke"=>"pharmacy", "physiotherapist"=>"physiotherapist", "placeofworship"=>"place_of_worship", "Klempner"=>"plumber", "Polizei"=>"police", "Post"=>"post_office", "Immobilienagentur"=>"real_estateagency", "Restaurant"=>"restaurant", "Dachdecker"=>"roofing_contractor", "rvpark"=>"rv_park", "Schule"=>"school", "Schuhgeschäft"=>"shoe_store", "Einkaufszentrum"=>"shopping_mall", "Spa"=>"spa", "Stadion"=>"stadium", "storage"=>"storage", "Geschäft"=>"store", "U-Bahnstation"=>"subway_station", "Synagogue"=>"synagogue", "Taxistand"=>"taxi_stand", "Bahnhof"=>"train_station", "Reisebüro"=>"travel_agency", "Universität"=>"university", "tieräztliche Versorgung"=>"veterinary_care", "Zoo"=>"zoo"]
		spokenPlace = spokenPlace.gsub(/\s+/, "")
		typeOfPlace = places_array[0][spokenPlace]
		if typeOfPlace == nil
			say "Dieser Ort (#{spokenPlace}) wird nich unterstützt! Vergewissern sie sich das sie nicht den Plural benutzen. Sagen sie 'unterstützte Orte' for a list of supported ones."
			request_completed
		else
		say "Suche..."
		add_views = SiriAddViews.new
		add_views.make_root(last_ref_id)
		map_snippet = SiriMapItemSnippet.new
		@client = GooglePlaces::Client.new("AIzaSyCstlsR2RirOI8wJxtgphqD3NE-bHex7X4")
		@places = @client.spots(@locationLat, @locationLong, :types => typeOfPlace, :radius => 5000)
		if @places[0] != nil
			for @place in @places do
				if @place.rating != nil 
					avg_rating = @place.rating
				else
					avg_rating = 0.0
				end		
				name = @place.name
				adress = @place.vicinity
				latitude = @place.lat
				longtitude = @place.lng
				icon = @place.icon
				location = SiriLocation.new
				location.label = name
				location.street, location.city = adress.split(/, /)
				location.latitude = latitude
				location.longitude = longtitude
				item = SiriMapItem.new
				item.label = name
				item.location = location
				map_snippet.items << item
			end	
			utterance = SiriAssistantUtteranceView.new("Das sind alle #{spokenPlace}s in einem Umkreis von 5km:")
			add_views.views << utterance	
			add_views.views << map_snippet
			#you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
			send_object add_views #send_object takes a hash or a SiriObject object
		else
			say "Ich konnte keine #{spokenPlace}s finden!"
		end
		end
	else
		say "No location data available. Please ensure your locations are turned on."
	end
	request_completed #always complete your request! Otherwise the phone will "spin" at the user!
end
 
end
