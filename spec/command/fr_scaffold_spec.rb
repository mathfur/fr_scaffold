# coding: utf-8

require "spec_helper"

describe "Command fr_scaffold test" do
  before do
    # TODO: Dir.tmpdirで書きなおす
    @working_dir = File.expand_path("#{TMP_DIR}/for_command_test_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    FileUtils.mkdir_p("#{@working_dir}/fr_scaffold_files")

    @layer1_fname = "#{@working_dir}/fr_scaffold_files/layer1.yaml.erb"
    @layer2_fname = "#{@working_dir}/fr_scaffold_files/layer2.yaml.erb"
    @layer3_fname = "#{@working_dir}/fr_scaffold_files/layer3.yaml.erb"
    @layer4_fname = "#{@working_dir}/fr_scaffold_files/layer4.rb"

    open(@layer1_fname, 'w') do |f|
      f.write <<-EOS
- tag: template
  name: ruby初期ファイル
EOS
    end

    @template_fname = "#{@working_dir}/template.md"
    open(@template_fname, 'w') do |f|
      f.write <<-EOS
********************************************************
## ruby初期ファイル

### first commit
lib/アプリ名/ 作成

bin/hello 作成
```
puts "HELLO"
```

【コメント】spec/hello/hello_spec.rb 作成
```
# coding: utf-8

describe "about hello" do
  specify { 1.should == 1 }
end
```
EOS
    end
  end

  it "" do
    STDERR.puts @working_dir
    Dir.chdir(@working_dir) do
      STDERR.puts `git init`
      STDERR.puts Dir.pwd

      STDERR.puts "[layer1-2]"
      STDERR.puts `#{BASE_DIR}/bin/fr_scaffold --layer1-to-2                               #{@layer1_fname} #{@layer2_fname}`.inspect
      STDERR.puts "[layer2-3]"
      STDERR.puts `#{BASE_DIR}/bin/fr_scaffold --layer2-to-3 --template=#{@template_fname} #{@layer2_fname} #{@layer3_fname}`.inspect
      STDERR.puts "[layer3-4]"
      STDERR.puts `#{BASE_DIR}/bin/fr_scaffold --layer3-to-4                               #{@layer3_fname} #{@layer4_fname}`.inspect
      STDERR.puts "[run]"
      STDERR.puts `#{BASE_DIR}/bin/fr_scaffold --run                                       #{@layer4_fname}`.inspect

      `rspec`.should =~ /\b1 example, 0 failures\b/
      `ruby #{@working_dir}/bin/hello`.should be_include("HELLO")
    end
  end
end
