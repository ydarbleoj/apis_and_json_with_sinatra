require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
  </form></body></html>
  )
end

post '/result' do
  search_str = params[:movie]

  response = Typhoeus.get( "http://www.omdbapi.com/", :params => { :s => search_str } )
  search_str = response.body
  result = JSON.parse(search_str)
  
  # Modify the html output so that a list of movies is provided.
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"

  result["Search"].map do |i| 
    html_str += "<li><a href=/poster/#{i["imdbID"]}>#{i["Title"]} - #{i["Year"]}</a></li>" 
  end
    html_str += "</ul></body></html>"
end

get '/poster/:imdb' do |imdb_id|

  # refactor this 
  response = Typhoeus.get( "www.omdbapi.com", :params => { :i => imdb_id } )
  result = JSON.parse(response.body)


  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str += "<h3><img src= #{result["Poster"]}></h3>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

