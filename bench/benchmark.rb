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

class Throughput
  def initialize(url, concurrency:)
    @url = url
    @concurrency = concurrency
  end

  def rps
    warmup

    ApacheBenchmark.new(url: @url, concurrency: @concurrency, time: 10).rps
  end

  def warmup
    request_per_second = 0
    times = 0
    runs = 0

    loop do
      times += 1
      runs += 1

      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time: 1).rps

      puts({times:, request_per_second:, new_value:, diff: diff_in_percent(request_per_second, new_value)})

      if diff_in_percent(request_per_second, new_value) > 10
        times = 0
        break if runs > 15
      else
        if times > 5
          break
        end
      end

      request_per_second = new_value
    end
  end

  def diff_in_percent(value1, value2)
    return 100 if value2.zero?

    ((value1 - value2).to_f.abs / value2) * 100
  end
end

class OptimalConcurrency
  def initialize(url)
    @url = url
  end

  def value
    concurrency = 0
    rps = 0

    loop do
      new_rps = Throughput.new(@url, concurrency: concurrency + 1).rps

      if new_rps > rps
        rps = new_rps
        concurrency += 1
        puts({concurrency:, rps:})
      else
        break
      end
    end

    concurrency
  end
end

puts OptimalConcurrency.new(ARGV[0]).value
