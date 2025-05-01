require 'logger'
require 'json'
require_relative "lib/throughput"

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end

if ENV.fetch('VERBOSE', 'true') == 'true'
  logger.level = :debug
else
  logger.level = :error
end

accuracity = ENV.fetch("ACCURACITY", "0.9").to_f
logger.info "Target accuracity = #{accuracity}"

format = ENV.fetch("FORMAT", "text")
throughput = Throughput.new(ARGV[0], accuracity:, logger:)
case format
when "text"
  puts "URL='#{ARGV[0]}', accuracity=#{accuracity}, rps = #{throughput.rps}, concurrency = #{throughput.concurrency}"
when "json"
  throughput = Throughput.new(ARGV[0], accuracity:, logger:)
  puts({ name: ENV.fetch("TEST_NAME", "set TEST_NAME ENV"), url: ARGV[0], accuracity:, rps: throughput.rps, concurrency: throughput.concurrency }.to_json)
else
  logger.error "Unknown output format '#{format}'"
end
