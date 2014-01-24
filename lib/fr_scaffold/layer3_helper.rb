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
  end
end
