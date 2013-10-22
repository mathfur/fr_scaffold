#!/usr/bin/env ruby
# encoding: utf-8

require 'getoptlong'

usage = <<EOS
Usage: fr_scaffold [options]
-v --version Display version information and exit.
EOS

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--version', '-v', GetoptLong::NO_ARGUMENT]
)

begin
  opts.each do |opt, arg|
    case opt
    when '--help'; puts usage; exit
    when '--version'; puts FrScaffold::VERSION; exit
    end
  end
rescue StandardError => e
  puts "wrong option" + e.inspect
  exit
end

raise "TODO: 以下リファクタリング"

require "erb"

BASE_DIR = "#{ENV['HOME']}/.my_scaffold"
SCAFFOLD_NAME = ENV['SCAFFOLD_NAME'] or raise 'Environment variable SCAFFOLD_NAME has to be specified.'

CP_LIST = "#{BASE_DIR}/CP_LIST"
MY_SCAFFOLD_ORIGIN = "#{BASE_DIR}/tmp/#{SCAFFOLD_NAME}"

#system("git status")
#
#if $? > 0
#  raise "need git"
#end

open(CP_LIST, 'w') do |f|
  Dir.chdir(MY_SCAFFOLD_ORIGIN) do
    f.write ERB.new(<<-'EOS', nil, '-').result(binding)
#!/usr/bin/env ruby

require "fileutils"

def mkdir_and_copy(src, dst)
  puts "#{src.inspect} => #{dst.inspect}"
  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.cp(src, dst)
end

MY_SCAFFOLD_TARGET_DIR = Dir.pwd
Dir.chdir('<%= MY_SCAFFOLD_ORIGIN %>') do
  <%- Dir["**/*"].select{|dir| File.file?(dir) }.each do |dir| -%>
  mkdir_and_copy('<%= dir %>', "#{MY_SCAFFOLD_TARGET_DIR}/<%= dir %>")
  <%- end -%>
end
    EOS
  end
end

system("vim #{CP_LIST}")

if File.size(CP_LIST) > 0
  system("ruby #{CP_LIST}")
end
