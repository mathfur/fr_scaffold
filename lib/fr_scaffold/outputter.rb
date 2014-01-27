# coding: utf-8

module FrScaffold
  class Outputter
    attr_reader :working_dir
    attr_accessor :layer2_input
    attr_accessor :layer2_output_todo
    attr_accessor :layer3_input
    attr_accessor :layer4_input

    attr_accessor :l2_template

    def initialize(options={})
      options.assert_valid_keys(:working_dir)

      self.layer2_output_todo ||= []

      @working_dir = options[:working_dir] || TMP_DIR
    end

    def load_template_from_md(fname)
      template_data = self.load_from_md(fname)

      self.l2_template = {}
      template_data.select{|hash| hash[:fname] }.each do |hash|
        self.l2_template[hash[:header2]] ||= {}
        self.l2_template[hash[:header2]][hash[:fname]] = hash[:code_block]
      end

      self.layer2_output_todo = template_data.map{|hash| hash[:other] }.compact
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

            if line_ =~ /\A(?<fname>.*?([a-z0-9_\/]\s*|\s+))を?作成\??\s*\Z/
              if result.last[:fname]
                result << result.last.clone
              end

            result.last[:fname]      = $~[:fname].strip
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

      result
    end

    def to_file_content_pairs
      paths = []

      self.layer2_input.each do |elem|
        case elem['tag']
        when "template"
          paths += self.l2_template[elem['name']].to_a
        when "entry"
          paths << [elem['name'], '']
        end
      end

      paths
    end

    # Output Example:
    # todo:
    #   - aaa
    #   - bbb
    # candidates:
    #   - file: Gemfile
    #   - file: lib/fr_scaffold/main.rb
    #   - dir: spec/
    # contents:
    #   - file: lib/fr_scaffold/main.rb
    #   - content: ..
    #
    def layer3_output(options={})
      output = []

      output << "candidates:"
      self.layer3_input.each do |path, _|
        if path =~ %r{\/$}
          output << "  - dir: #{path}"
        else
          output << "  - file: #{path}"
        end
      end

      output << ""

      output << "task:"
      output << "  - replace:"
      output << "    - 'アプリ名': 'アプリ名'"
      output << "      '0.0.0': '0.0.0'"

      output << ""

      output << "todo:"
      self.layer2_output_todo.each do |line|
        output << "  - '#{line.gsub("'", "\\'")}'"
      end

      output << ""
      output << "contents:"
      self.layer3_input.each do |path, content|
        if path !~ %r{\/$}
          output << "  - file: #{path}"
          output << "    content: |+"
          output << "     #{content.split("\n").join("\n     ")}"
        end
      end

      output.join("\n")
    end

    def layer4_output(dst_dir, options={})
      output = []

      output << "#coding: utf-8"
      output << "require 'erb'"
      output << ""
      output << "include FrScaffold::Layer3Helper"
      output << ""

      output << "# TODO:"
      output += self.layer4_input["todo"].map{|line| "# #{line}" }

      output << ""
      output << ""

      self.layer4_input["candidates"].each do |hash|
        tag = hash.keys.first
        path = hash.values.first
        content = self.layer4_input["contents"].map{|hash| hash['file'] == path ? hash['content'] : nil }.compact.first

        if tag == "dir" or tag == "file"
          output << %Q!  target = "#{dst_dir}/#{path}"!
        end

        case tag
        when 'dir'
          output << "  FileUtils.mkdir_p(target)"
        when 'file'
          output << <<EOS
  not_exist_then_create_dir(target)
  if_git_change_then_exit(target)

  open(target, "w") do |f|
    f.puts(ERB.new(<<-'IIIIIII', nil, '-').result)
#{content}
                      IIIIIII
  end
EOS
        when 'tag'
          raise "No Implementation"
        else
          raise "tag #{tag.inspect} is wrong"
        end

        output << ""
      end

      result = output.join("\n")

      self.layer4_input['task'][0]['replace'].each do |hash|
        hash.each do |from, to|
          result = result.gsub(from, to)
        end
      end

      result
    end
  end
end
