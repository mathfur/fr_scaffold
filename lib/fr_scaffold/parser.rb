# coding: utf-8

LANGUAGE_REGEX = /### (?<language>.+) +first +commit *$/u
FNAME_REGEX = /^(?<fname>.*)(?:を?作成(?:する)?) *$/u
START_QUOTE_REGEX = /^>>>/u
END_QUOTE_REGEX = /^<<<$/u

module FrScaffold
  class Parser
    def initialize(input)
      @lines = input.split("\n")
      @debug_stack = []
      @fname2content = {} # fname2content[:language][:fname] :: そのソース

      parse
    end

    def parse
      content = []
      state = :outside
      fname = nil

      @lines.each do |line|
        case state
        when :outside
          case line
          when LANGUAGE_REGEX
            @debug_stack << [state, :language]

            language = $~[:language]

            state = :inside
          end
        when :inside
          case line
          when FNAME_REGEX
            @debug_stack << [state, :fname]

            fname = $~[:fname]
          when START_QUOTE_REGEX
            @debug_stack << [state, :start_quote]

            raise "quote has to be after title" unless fname

            state = :inside_quote
          end
        when :inside_quote
          case line
          when END_QUOTE_REGEX
            @fname2content[language] ||= {}
            @fname2content[language][fname] = content.join("\n")

            fname = nil
            state = :outside
          else
            content << line
          end
        end
      end
    end

    def result
      @fname2content
    end
  end
end
