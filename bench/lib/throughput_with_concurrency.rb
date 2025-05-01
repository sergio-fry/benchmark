require_relative "apache_benchmark"

class ThroughputWithConcurrency
  def initialize(url, concurrency:, accuracity: 0.95, logger:)
    @url = url
    @concurrency = concurrency
    @accuracity = accuracity
    @logger = logger
  end

  def rps
    warmup(5)

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

      break if time > 600

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
