# coding: utf-8

require "spec_helper"

describe "About command fr_scaffold" do
  before do
    # TODO: Dir.tmpdirで書きなおす
    @working_dir = File.expand_path("#{TMP_DIR}/for_command_test/#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    FileUtils.mkdir_p("#{@working_dir}/fr_scaffold_files")

    @layer1_fname = "#{@working_dir}/fr_scaffold_files/layer1.yaml.erb"
    @layer2_fname = "#{@working_dir}/fr_scaffold_files/layer2.yaml.erb"
    @layer3_fname = "#{@working_dir}/fr_scaffold_files/layer3.yaml.erb"
    @layer4_fname = "#{@working_dir}/fr_scaffold_files/layer4.rb"

    @template_fname = "#{@working_dir}/fr_scaffold_files/template.md"
    open(@template_fname, 'w') do |f|
      f.write <<-EOS
********************************************************
# ruby

### 初期ファイル
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

  def exec_command(working_dir, option_str="")
    STDERR.puts "=== EXECUTE fr_scaffold #{option_str}"

    result = Dir.chdir(working_dir) { `#{BASE_DIR}/bin/fr_scaffold #{option_str} 2>&1` }

    STDERR.puts result.inspect
    result
  end

  describe "About fr_scaffold --init" do
    describe "templateオプションがなければエラー" do
      specify do
        result = exec_command(@working_dir, "--init")

        result.should =~ /\[ERROR\]/
        File.exist?(@layer1_fname).should be_false
      end
    end

    describe "コマンド実行時にfr_scaffold_files/layer1.yaml.erbが作成されること" do
      specify do
        exec_command(@working_dir, "--init --template=#{@template_fname}")

        File.read(@layer1_fname).should =~ /ruby::初期ファイル/
      end
    end
  end
  describe "layer1からrunまで結合して動作する" do
    before do
      open(@layer1_fname, 'w') do |f|
        f.write <<-EOS
- tag: template
  name: ruby::初期ファイル
EOS
      end
    end

    specify do
      STDERR.puts `git init`
      STDERR.puts Dir.pwd

      exec_command(@working_dir, "--layer1-to-2 --input=#{@layer1_fname} --output=#{@layer2_fname}")
      exec_command(@working_dir, "--layer2-to-3 --input=#{@layer2_fname} --output=#{@layer3_fname} --template=#{@template_fname}")
      exec_command(@working_dir, "--layer3-to-4 --input=#{@layer3_fname} --output=#{@layer4_fname}")
      exec_command(@working_dir, "--run         --input=#{@layer4_fname}")

      Dir.chdir(@working_dir) do
        `rspec`.should =~ /\b1 example, 0 failures\b/
        `ruby #{@working_dir}/bin/hello 2>&1`.should be_include("HELLO")
      end
    end
  end
end
