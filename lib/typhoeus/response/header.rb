module Typhoeus
  class Response

    # This class represents the response header.
    # It can be accessed like a hash.
    # Values can be strings (normal case) or arrays of strings (for duplicates headers)
    #
    # @api private
    class Header < Hash

      # Create a new header.
      #
      # @example Create new header.
      #   Header.new(raw)
      #
      # @param [ String ] raw The raw header.
      def initialize(raw)
        @raw = raw
        parse
      end

      def [](key)
        super(key.to_s.downcase)
      end

      # Parses the raw header.
      #
      # @example Parse header.
      #   header.parse
      def parse
        case @raw
        when Hash
          raw.each do |k, v|
            process_pair(k, v)
          end
        when String
          raw.lines.each do |header|
            header.strip!
            next if header.empty? || header.start_with?( 'HTTP/1.' )
            process_line(header)
          end
        end
      end

      private

      # Processes line and saves the result.
      #
      # @return [ void ]
      def process_line(header)
        key, value = header.split(':', 2)
        process_pair(key.strip, value.strip)
      end

      # Sets key value pair for self.
      #
      # @return [ void ]
      def process_pair(key, value)
        set_value(key.downcase, value, self)
      end

      # Sets value for key in specified hash
      #
      # @return [ void ]
      def set_value(key, value, hash)
        current_value = hash[key]
        if current_value
          if current_value.is_a? Array
            current_value << value
          else
            hash[key] = [current_value, value]
          end
        else
          hash[key] = value
        end
      end

      # Returns the raw header or empty string.
      #
      # @example Return raw header.
      #   header.raw
      #
      # @return [ String ] The raw header.
      def raw
        @raw || ''
      end
    end
  end
end
