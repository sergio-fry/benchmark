require_relative "throughput_with_concurrency"

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

