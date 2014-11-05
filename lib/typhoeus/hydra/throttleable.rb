module Typhoeus
  class Hydra

    # This module handles the request throttling
    #
    # @api private
    module Throttleable
      def available_throttled_capacity
        now = Time.now

        @throttle_buffer.capacity.times do
          if (oldest_timestamp = @throttle_buffer.front) && oldest_timestamp < (now - 1)
            @throttle_buffer.pop
          else
            break
          end
        end

        @throttle_buffer.capacity - @throttle_buffer.size
      end

      def add(request)
        @throttle_buffer.push(Time.now) if throttling_enabled?
        super
      end

      def throttling_enabled?
        !!@throttle_buffer
      end
    end
  end
end
