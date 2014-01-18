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
