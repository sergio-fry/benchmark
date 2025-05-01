require 'net/http'
require 'uri'

# Define the URL to check
url = URI.parse(ARGV[0])

# Function to check if the web service is available
def service_available?(url)
  begin
    # Make a GET request to the specified URL
    response = Net::HTTP.get_response(url)

    # Check if the response status code indicates success
    return response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    puts "Error checking service availability: #{e.message}"
    return false
  end
end

max_retries = 999
retry_delay = 5 # seconds

(1..max_retries).each do |attempt|
  puts "Checking if the web service is available (Attempt #{attempt}/#{max_retries})..."

  if service_available?(url)
    puts "Web service is now available!"
    break
  else
    puts "Service not yet available, retrying in #{retry_delay} seconds..."
    sleep(retry_delay)
  end

  # If the maximum number of retries is reached, exit with an error message
  if attempt == max_retries
    puts "Maximum retries reached. Exiting."
    exit(1)
  end
end
