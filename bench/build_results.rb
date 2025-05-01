require 'json'
require 'csv'

# Define the input and output files
input_file = ARGV[0]
output_file = 'output.csv'

# Read the input file line by line
lines = File.readlines(input_file)

# Hash to store parsed JSON data
tests_data = {}

# Parse each line as JSON and store it in a hash for comparison
lines.each do |line|
  test = JSON.parse(line)

  key = [test['name'], test['url'], test['concurrency']]

  # If the test (name, url) is not yet in the hash, initialize an empty array
  tests_data[key] ||= []

  # Append the rps value to the corresponding test
  tests_data[key] << test
end

# Prepare to write to CSV file
CSV.open(output_file, 'w', headers: ['name', 'url', 'concurrency', 'rps', 'error']) do |csv|
  # Iterate over each unique test (name, url)
  tests_data.each do |key, tests|
    if tests.length == 2
      test1, test2 = tests
      error = (test1['rps'].to_f - test2['rps'].to_f).abs / test1['rps'].to_f

      # Write to CSV
      csv << [test1['name'], test1['url'], test1['concurrency'], (test1['rps'] + test2['rps'])/2, error]
    end
  end
end
