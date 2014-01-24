# coding: utf-8

class Object
  def tee(options={}, &block)
    label = options[:label] || options[:l]
    method_name = options[:method] || options[:m] || :inspect

    STDERR.puts ">> #{label}"

    if block_given?
      STDERR.puts block.call(self)
    else
      STDERR.puts (method_name == :nothing) ? self : self.send(method_name)
    end

    STDERR.puts ">>"

    self
  end

  def present_or(obj)
    self.present? ? self : obj
  end

  def try(*args)
    (self == nil) ? nil : self.send(*args)
  end

  def present?
    !self.blank?
  end

  def blank?
    [nil, false, [], '', {}].include?(self)
  end
end

class String
  def underscore
    self.to_s.gsub(/::/, '/').
              gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
              gsub(/([a-z\d])([A-Z])/,'\1_\2').
              tr("-", "_").
              downcase
  end
end

class Hash
  # Usage: options.assert_valid_keys(:unique, :order)
  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      raise ArgumentError.new("Unknown key: #{k}") unless valid_keys.include?(k)
    end
  end
end

def have_git_change?(fname)
  Dir.chdir(File.dirname(fname)) do
    return (`git diff -- #{fname}` != '')
  end
end
