require 'open3'
require 'logger'
require 'json'

class ApacheBenchmark
  def initialize(url:, concurrency:, time:, logger:)
    @url = url
    @concurrency = concurrency
    @time = time
    @logger = logger
  end

  def rps
    stdout, stderr, status = Open3.capture3("ab -k -t #{@time} -c #{@concurrency} #{@url}")

    unless status.success?
      @logger.error stderr
      return 0
    end

    # Извлекаем Requests Per Second из вывода
    match_data = /Requests per second:\s*([\d.]+)/.match(stdout)
    match_data[1].to_f
  end
end

class ThroughputWithConcurrency
  def initialize(url, concurrency:, accuracity: 0.95, logger:)
    @url = url
    @concurrency = concurrency
    @accuracity = accuracity
    @logger = logger
  end

  def rps
    warmup(1)

    stable_throughput
  end

  def stable_throughput
    time = 10
    current = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time: 10, logger: @logger).rps

    loop do
      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time:, logger: @logger).rps
      @logger.info "Measuring #{time} sec: #{new_value} r/s (acc #{accuracity(current, new_value).round(4) * 100}%)"

      if accuracity(current, new_value) > @accuracity
        current = new_value
        break
      else
        current = new_value
      end

      time = time * 2
    end

    current
  end

  def accuracity(value1, value2)
    1 - diviation(value1, value2)
  end

  def diviation(value1, value2)
    ((value1 - value2).abs.to_f / ([value1, value2].max))
  end

  def warmup(time)
    record = 0
    downs = 0

    loop do
      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time:, logger: @logger).rps

      diff = new_value - record

      if new_value < record
        downs += 1 
        diff_message = ""
      else
        downs = 0
        record = new_value
        diff_message = "(+#{diff.round(2)} r/s)"
      end

      @logger.info "Warming UP: #{new_value} r/s #{diff_message}"

      break if downs > 20
    end
  end
end

class Throughput
  def initialize(url, accuracity: 0.95, logger:)
    @url = url
    @accuracity = accuracity
    @logger = logger
  end

  def rps
    measurement[:rps]
  end

  def concurrency
    measurement[:concurrency]
  end

  def measurement
    @measurement ||= begin
      concurrency = 0
      rps = 0

      loop do
        concurrency += 1
        @logger.info "Concurrency = #{concurrency}"
        new_rps = ThroughputWithConcurrency.new(@url, concurrency:, accuracity: @accuracity, logger: @logger).rps

        if new_rps > rps
          rps = new_rps
          @logger.info "Throughput with concurrency=#{concurrency}: #{rps} r/s"
        else
          break
        end
      end

      { rps:, concurrency: concurrency - 1 }
    end
  end
end

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
  puts({ url: ARGV[0], accuracity:, rps: throughput.rps, concurrency: throughput.concurrency }.to_json)
else
  logger.error "Unknown output format '#{format}'"
end
