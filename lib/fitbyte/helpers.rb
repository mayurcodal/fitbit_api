module Fitbyte
  class Client

    def format_date(date)
      if [Date, Time, DateTime].include?(date.class)
        date.strftime("%Y-%m-%d")
      elsif date.is_a? String
        if date =~ /\d{4}\-\d{2}\-\d{2}/
          date
        else
          raise ArgumentError, "Invalid argument [\"#{date}\"] - string must follow yyyy-MM-dd format."
        end
      else
        raise ArgumentError, "Invalid type [#{date.class}] - provide a Date/Time/DateTime or a String(yyyy-MM-dd format)."
      end
    end

    def format_scope(scope)
      scope.is_a?(Array) ? scope.join(" ") : scope
    end

    def deep_keys_to_snake_case!(object)
      deep_transform_keys!(object) { |key| to_snake_case(key) }
    end

    def deep_keys_to_camel_case!(object)
      deep_transform_keys!(object) { |key| to_camel_case(key, lower: true) }
    end

    def deep_symbolize_keys!(object)
      deep_transform_keys!(object) { |key| key.to_sym rescue key }
    end

    # Inspired by ActiveSupport's implementation
    def deep_transform_keys!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = deep_transform_keys!(value) { |key| yield(key) }
        end
        object
      when Array
        object.map! { |e| deep_transform_keys!(e) { |key| yield(key) } }
      else
        object
      end
    end

    def to_snake_case(word)
      string = word.to_s.dup
      return string.downcase if string.match(/\A[A-Z]+\z/)
      string.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      string.gsub!(/([a-z])([A-Z])/, '\1_\2')
      string.downcase
    end

    def to_camel_case(word, opts={})
      string = word.to_s
      return string if string.match(/[A-Z]|[a-z]([A-Z0-9]*[a-z][a-z0-9]*[A-Z]|[a-z0-9]*[A-Z][A-Z0-9]*[a-z])[A-Za-z0-9]*/)
      string = word.to_s.split("_").collect(&:capitalize).join
      string.gsub!(/^\w{1}/) { |word| word.downcase } if opts[:lower]
      return string
    end

  end
end
