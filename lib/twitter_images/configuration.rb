module TwitterImages
  class Configuration
    attr_accessor :search, :directory, :output, :consumer_key, :access_token,
      :address, :request, :http, :response

    def initialize()
      @search = search
      @directory = directory
      @output = output
      @consumer_key = consumer_key
      @access_token = access_token
      @address = address
      @request = request
      @http = http
      @response = response
    end

    def prepare
      setup_credentials
      get_directory
      change_dir
      get_search
      establish_connection
    end

    def establish_connection
      setup_address
      setup_http
      build_request
      issue_request
      get_output
    end

    private

    def setup_credentials
      decide

      @consumer_key = OAuth::Consumer.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"])

      @access_token = OAuth::Token.new(ENV["ACCESS_TOKEN"], ENV["ACCESS_SECRET"])
    end

    def decide
      puts "Would your like to update your Twitter credentials now? [y/n]"
      decision = gets.chomp

      if decision == "y"
        puts "Please enter your Consumer Key: "
        ENV["CONSUMER_KEY"] = gets.chomp
        puts "Please enter your Consumer Secret: "
        ENV["CONSUMER_SECRET"] = gets.chomp

        puts "Please enter your Access Token: "
        ENV["ACCESS_TOKEN"] = gets.chomp
        puts "Please enter your Access Secret: "
        ENV["ACCESS_SECRET"] = gets.chomp
      elsif decision == "n"
      else
        puts "Wrong answer, please select [y/n]"
        decide
      end
    end

    def setup_http
      # Set up Net::HTTP to use SSL, which is required by Twitter.
      @http = Net::HTTP.new(address.host, address.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def build_request
      # Build the request and authorize it with OAuth.
      @request = Net::HTTP::Get.new(address.request_uri)
      request.oauth!(http, consumer_key, access_token)
    end

    def issue_request
      # Issue the request and return the response.
      http.start
      @response = http.request(request)
    end

    def get_output
      @output = JSON.parse(response.body)
    end

    def setup_address
      @address = URI("https://api.twitter.com/1.1/search/tweets.json?q=%23#{search}&mode=photos&count=100")
    end

    def get_directory
      puts "Please enter the absolute path to the directory to save the images in: "
      @directory = gets.chomp
      raise StandardError, "Directory doesn't exist" unless Dir.exists?(@directory)
    end

    def change_dir
      Dir.chdir(@directory)
    end

    def get_search
      puts "Please enter the search terms: "
      @search = gets.chomp.gsub(/\s/, "%20")
    end
  end
end
