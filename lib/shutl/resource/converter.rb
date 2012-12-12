module Shutl::Resource::Converter
  def convert *attr_names, options
    @converters ||= {}

    attr_names.map(&:to_sym).each do |attr_name|
      @converters[attr_name] = {
        converter_classes: Array(options[:with]),
        methods: Array(options[:only] || [:to_back_end, :to_front_end])
      }
    end
  end

  %w(to_front_end to_back_end).each do |conversion|
    define_method conversion do |attrs|
      attrs = attrs.dup.with_indifferent_access
      @converters.each do |attr_name, o|
        if o[:methods].include?(conversion.to_sym)
          attrs = convert_attribute(
            attr_name, conversion, o[:converter_classes], attrs)
        end
      end
      attrs
    end
  end

  def convert_attribute attr_name, method, converter_classes, attrs
    converter_classes.each do |converter_class|
      if attrs.has_key?(attr_name)
        attrs[attr_name] = converter_class.send(method, attrs[attr_name])
      end
    end
    attrs
  end

  def self.class_for resource_class
    begin
      "#{resource_class}Converter".constantize
    rescue NameError => e
      Shutl::Resource::NoConverter
    end
  end
end
