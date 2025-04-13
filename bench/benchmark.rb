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
    warmup(1)

    ApacheBenchmark.new(url: @url, concurrency: @concurrency, time: 10).rps
  end

  def warmup(time)
    request_per_second = 0
    downs = 0

    loop do
      new_value = ApacheBenchmark.new(url: @url, concurrency: @concurrency, time:).rps

      puts({downs:, request_per_second:, new_value:})

      if new_value < request_per_second
        downs += 1 
      else
        request_per_second = new_value
      end


      break if downs > 10
    end
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

    { concurrency:, rps: }
  end
end

puts OptimalConcurrency.new(ARGV[0]).value
