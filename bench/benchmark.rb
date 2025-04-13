require 'open3'

class ApacheBenchmark
  def initialize(url:, concurrency:, time:)
    @url = url
    @concurrency = concurrency
    @time = time
  end

  def rps
    stdout, stderr, status = Open3.capture3("ab -k -t #{@time} -c #{@concurrency} #{@url}")

    unless status.success?
      return 0
    end

    # Извлекаем Requests Per Second из вывода
    match_data = /Requests per second:\s*([\d.]+)/.match(stdout)
    match_data[1].to_f
  end
end

class ThroughputWithConcurrency
  def initialize(url, concurrency:, accuracity: 0.05)
    @url = url
    @concurrency = concurrency
    @accuracity = accuracity
  end

  def rps
    warmup(1)

    stable_throughput
  end

  def stable_throughput
    time = 3
    current = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time: 1).rps

    loop do
      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time:).rps
      puts "Measuring #{time} sec: #{new_value} r/s (acc #{accuracity(current, new_value).round(4) * 100}%)"

      break if diviation(current, new_value) < @accuracity

      current = new_value
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
      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time:).rps

      diff = new_value - record

      if new_value < record
        downs += 1 
        diff_message = ""
      else
        downs = 0
        record = new_value
        diff_message = "(+#{diff.round(2)} r/s)"
      end

      puts "Warming UP: #{new_value} r/s #{diff_message}"

      break if downs > 10
    end
  end
end

class Throughput
  def initialize(url, accuracity: 0.05)
    @url = url
    @accuracity = accuracity
  end

  def rps
    concurrency = 0
    rps = 0

    loop do
      concurrency += 1
      puts "Concurrency = #{concurrency}"
      new_rps = ThroughputWithConcurrency.new(@url, concurrency:, accuracity: @accuracity).rps

      if new_rps > rps
        rps = new_rps
        puts "Throughput with concurrency=#{concurrency}: #{rps} r/s"
      else
        break
      end
    end

    rps
  end
end

puts Throughput.new(ARGV[0], accuracity: 0.01).rps
