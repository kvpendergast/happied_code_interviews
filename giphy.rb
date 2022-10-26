# Hello! Today we're going to build an application 
# that grabs gifs from giphy based on a search input from a user, 
# and returns those gifs to our magical front-end.

# For this test, your goal is only to return gifs to the front-end. We aren't building a UI.
# Below, you will see our "get" request that receives input "text" from the user.

# We want to send the search input to giphy, parse the response, and then return relevant results. 
# In general, here are different concepts we expect you to deliver on:
#   - How are you deciding what results, and each result's respective subdata,
#     to return to the user?
#   - How would you alter this get request to handle a user clicking 
#     through pages of gifs rather than a limited amount?
#   - Let's pretend that the user likes some gifs and wants to return 
#     to visit them later. How should we handle storing the user's preferences?
#       - For this one, map out a proposed data schema.

# Helpful info to get you started: 
#   - base url for giphy is: https://api.giphy.com/v1/gifs/search
#   - api key you can use is: GaQz73BYzGEogZIsMO9YODtH0Ce2rVuO
#   - giphy documentation: https://developers.giphy.com/docs/api/endpoint#search
#   - Performing http requests with ruby: https://www.twilio.com/blog/5-ways-make-http-requests-ruby
#   - if you want to better visualize the api response, you can use https://www.postman.com/


require 'json'
require 'net/http'

def get(user_input)
    # Your api response object should go in this data object
    data = {}

    # Your code goes here.
    print "Fun with giphy!"
    
    # fetch data
    base_url = 'http://api.giphy.com/v1/gifs/search?'
    api_key = 'GaQz73BYzGEogZIsMO9YODtH0Ce2rVuO'
    url = "#{base_url}&api_key=#{api_key}&q=#{user_input}&limit=1&offset=#{page_number}"
    
    res = Net::HTTP.get_response(URI.parse(url))
    result = JSON.parse(res.body)

    # filter out unused key value pairs from results and save to an array
    giphy_results = []
    result.values.first.each do |gif|
        giphy_results << {title: gif["title"], id: gif['id'], slug: gif['slug'], url: gif['url'],imoprt_datetime: gif['import_datetime'], images: {thumbnail: gif['images']['downsized'], original: gif['images']['original']}}
    end

    # save pagination data for frontend navigation
    pagination = result.assoc 'pagination'

    # add striped giphy and pagination data to the returned data object
    data = {giphy_results: giphy_results, pagination: pagination[1]}
    p data

    return data
end

def run
    get('funny dogs')
end

# to run, open your terminal and type ruby giphy.rb
run

__END__

== Returned Results ==

    - The search api endpoint required a q param to be passed in the url. The user_input argument is used as the query. Once the returned data is parsed, I looped through each returned object and saved a new object with the id, title, url, slug, and two differnt image objects. The two images used are a small version to use in thumbnails on an index view and the larger version is used on a show view. The slug would be used for aria labeling, the id would be used in the saved_giphy join table if the user decides to save the giphy. The url to link back to the original gif. And finally title to label the gif. The import_datetime and title can also be used to sort the results alphabetically or by newest || oldest

== Alter Request ==

    -I added a second argument to the get method that defaults to 0. This argument is used to set the offset property on the api request. The pagination meta data returned from the api request also give the total_count and count. These variables can be used to generate and navigate page numbers on the frontend.

== User Saving Gifs ==

    -For a user to save favorite a gif, you can add a saved_giphys array to the user object. This array would hold a list of giphy id's. If the fetched giphy's id is in the saved_giphy array, it will be marked as favorite. 

    -Or you can create a giphy model and a saved_giphy model. When a user saves a giphy, a new giphy is created in the database as well as a new saved_giphy. The saved_giphy would act as a join table between the user and the giphy

    -The saved_giphy schema would look like: 

        create_table 'saved_giphy', force: :cascade do |t|
            t.string 'user_id'
            t.string 'giphy_id'
            t.datetime "created_at", null: false
            t.datetime "updated_at", null: false
        end