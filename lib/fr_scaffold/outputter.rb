# coding: utf-8

module FrScaffold
  class Outputter
    attr_reader :working_dir
    attr_accessor :layer2_input
    attr_accessor :layer3_input

    attr_accessor :l2_template

    def initialize(options={})
      options.assert_valid_keys(:working_dir)

      @working_dir = options[:working_dir] || TMP_DIR
    end

    def load_from_md(fname)
      lines = File.read(fname).split("\n")

      inside_code_block = false
      last_line = nil
      code_block_lines = []
      result = [{}]

      lines.each do |line|
        if inside_code_block
          case line
          when /\A```\Z/
            result.last[:code_block] = code_block_lines.join("\n")
            result << result.last.clone

            result.last[:fname]      = nil
            result.last[:other]      = nil
            result.last[:code_block] = nil

            code_block_lines = []
            inside_code_block = false
          else
            code_block_lines << line
          end
        else
          # outside code_block
          case line
          when /\A```\Z/
            inside_code_block = true
          when /\A# (.*)\Z/
            result.last[:header1]    = $1
            result.last[:header2]    = nil
            result.last[:header3]    = nil
            result.last[:fname]      = nil
            result.last[:code_block] = nil
            result.last[:other]      = nil
          when /\A## (.*)\Z/
            result.last[:header2]    = $1
            result.last[:header3]    = nil
            result.last[:fname]      = nil
            result.last[:code_block] = nil
            result.last[:other]      = nil
          when /\A### (.*)\Z/
            result.last[:header3]    = $1
            result.last[:fname]      = nil
            result.last[:code_block] = nil
            result.last[:other]      = nil
          else
            line_ = line.strip.gsub(/【.*?】/, '').gsub(/\(.*?\)/, '')

            if line_ =~ /\A(.*?([a-z0-9_]\s*|\s+))を?作成\??\s*\Z/
              result.last[:fname]      = line_
              result.last[:code_block] = nil
              result.last[:other]      = nil
            else
              result.last[:other]      = line

              result << result.last.clone
              result.last[:other]      = nil
              result.last[:fname]      = nil
              result.last[:code_block] = nil
            end
          end
        end
      end

      result.select{|hash| hash[:fname] }.map{|hash| {:header => hash[:header2], :fname => hash[:fname], :code_block => hash[:code_block]}}
    end

    def to_file_content_pairs
      files = []

      self.layer2_input.each do |elem|
        case elem['tag']
        when "template"
          files += self.l2_template[elem['name']].to_a
        when "entry"
          files << [elem['name'], '']
        end
      end

      files
    end

    def layer3_output(dst_dir, options={})
      output = []

      output << "#coding: utf-8"
      output << "require 'erb'"
      output << ""
      output << "include FrScaffold::Layer3Helper"

      self.layer3_input.each do |path, content|
        output << <<EOS
  target = "#{dst_dir}/#{path}"
  not_exist_then_create_dir(target)
  if_git_change_then_exit(target)

  open(target, "w") do |f|
    f.puts(ERB.new(<<-'IIIIIII', nil, '-').result)
#{content}
                      IIIIIII
  end
EOS
        output << ""
      end

      output.join("\n")
    end
  end
end
