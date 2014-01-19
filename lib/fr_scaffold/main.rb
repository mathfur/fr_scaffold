# coding: utf-8

module FrScaffold
  class Main
    attr_reader :info

    def initialize
    end

    def data=(data)
      @info = Main.convert(data)
    end

    def self.convert(input_arr)
      result = {}

      header_name, para_name, code_block_src = nil
      input_arr.each do |elem|
        elem_name = elem.keys.first
        val = elem.values.first

        if elem_name == "Header" && header?(val)
          header_name = self.header_name(val)
          para_name = nil
        elsif elem_name == "Para" && para?(val)
          para_name = self.para_name(val)
        elsif elem_name == "CodeBlock" && code_block?(val)
          code_block_src = self.code_block_src(val)
        end

        if header_name && para_name && code_block_src
          result[header_name] ||= {}
          raise "Para_nameに重複があります" if result[header_name][para_name]
          result[header_name][para_name] = code_block_src
          para_name = nil
          code_block_src = nil
        end
      end

      result
    end

    # =================================================================
    # pandoc処理後に含まれる要素の列から情報を得るためのラッパー関数
    # =================================================================

    def self.header_name(header)
      raise "#{header.inspect} has to be Header element" if !header || !self.header?(header)

      header.last.map{|e| e["Str"] }.join
    end

    def self.para_name(para)
      raise "#{para.inspect} has to be Para element" if !para || !self.para?(para)

      para[0]["Str"]
    end

    def self.code_block_src(block)
      raise "#{block.inspect} has to be CodeBlock element" if !block || !self.code_block?(block)

      block[1]
    end

    def self.header?(header)
      header.kind_of?(Array) &&
      header.last.kind_of?(Array) &&
      header.last.all?{|e| e.kind_of?(Hash) && e["Str"].kind_of?(String) }
    end

    def self.para?(para)
      !!(para.kind_of?(Array) &&
      para.size == 1 &&
      para[0].kind_of?(Hash) &&
      para[0]["Str"])
    end

    def self.code_block?(block)
      !!(block.kind_of?(Array) &&
      block.size == 2 &&
      block[1].kind_of?(String) &&
      block[1])
    end
  end
end
