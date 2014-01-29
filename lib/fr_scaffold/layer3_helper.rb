# coding: utf-8

module FrScaffold
  module Layer3Helper
    def not_exist_then_create_dir(path)
      dir = File.dirname(path)
      unless File.exist?(dir)
        FileUtils.mkdir_p(dir)
      end
    end

    def if_git_change_then_exit(fname)
      if (`git diff -- #{fname}` != '')
        STDERR.puts "#{fname} has been already changed."
        exit
      end
    end

    def create_source(fname, &block)
      open(fname, 'w') do |f|
        Sandbox.new(self).instance_exec(FilePointerWrapper.new(f), &block)
      end
    end

    class FilePointerWrapper
      attr_accessor :indent

      def initialize(fp, indent=0)
        @fp = fp
        @indent = indent
      end

      def klass(klass_name, &block)
        indent = ' '*@indent

        @fp.puts "#{indent}class #{klass_name}"
        new_fp = FilePointerWrapper.new(@fp, @indent+2)
        block.call(new_fp) if block_given?
        @fp.puts "#{indent}end"
      end

      def def_(name, &block)
        indent = ' '*@indent

        @fp.puts "#{indent}def #{name}"
        new_fp = FilePointerWrapper.new(@fp, @indent+2)
        block.call(new_fp) if block_given?
        @fp.puts "#{indent}end"
      end

      def method_missing(name, *args, &block)
        @fp.send(name, *args, &block)
      end
    end

    class Sandbox
      def initialize(base)
        @base = base
      end

      def klass(klass_name, &block)
      end

      def method_missing(name, *args, &block)
        @base.send(name, *args, &block)
      end
    end
  end
end
