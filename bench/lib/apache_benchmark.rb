require 'open3'

class ApacheBenchmark
  def initialize(url:, concurrency:, number: 1000, logger:)
    @url = url
    @concurrency = concurrency
    @number = number
    @logger = logger
  end

  def rps
    stdout, stderr, status = Open3.capture3("ab -k -c #{@concurrency} -n #{@number} #{@url}")

    unless status.success?
      @logger.error stderr
      return 0
    end

    # Извлекаем Requests Per Second из вывода
    match_data = /Requests per second:\s*([\d.]+)/.match(stdout)
    match_data[1].to_f
  end
end
