require 'logger'
require 'json'
require_relative "lib/apache_benchmark"

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end

if ENV.fetch('VERBOSE', 'true') == 'true'
  logger.level = :debug
else
  logger.level = :error
end

url = ARGV[0]
number = ENV.fetch("NUMBER", "50000").to_i
concurrency = ENV.fetch("CONCURRENCY", "1").to_i

rps = ApacheBenchmark.new(url:, number: , concurrency:, logger:).rps

puts({ name: ENV.fetch("TEST_NAME", "set TEST_NAME ENV"), url: url, rps:, concurrency:, number: }.to_json)
