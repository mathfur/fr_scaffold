# coding: utf-8

require "spec_helper"

describe FrScaffold::Main do
  Main = FrScaffold::Main

  before do
    @main = Main.new
  end

  describe '.header?' do
    specify "headerと認識されない例" do
      Main.header?(nil).should be_false
      Main.header?([1, [], [{}]]).should be_false
      Main.header?([2, [nil, [], []], [{"Str" => nil}]]).should be_false
    end

    specify "headerと認識される例" do
      Main.header?([1, [], []]).should be_true
      Main.header?([1, ["初期作成", [], []], [{"Str" => "初期作成"}]]).should be_true
      Main.header?([1, ["初期作成", [], []], [{"Str" => "aaa"}, {"Str" => "初期作成"}]]).should be_true
    end
  end

  describe '.para?' do
    specify "paraと認識されない例" do
      Main.para?(nil).should be_false
      Main.para?({}).should be_false
      Main.para?([{"aa" => "あああ"}]).should be_false
    end

    specify "paraと認識される例" do
      Main.para?([{"Str" => "あああ"}]).should be_true
    end
  end

  describe '.code_block?' do
    specify "code_blockと認識されない例" do
      Main.code_block?(nil).should be_false
      Main.code_block?([]).should be_false
      Main.code_block?([["", [], []], nil]).should be_false
      Main.code_block?([["", [], []], []]).should be_false
    end

    specify "code_blockと認識される例" do
      Main.code_block?([["", [], []], %Q!tmp/!]).should be_true
    end
  end


  describe '.header_name' do
    specify "2個目の要素の先頭要素を名前として取得する" do
      Main.header_name([1, ["ruby初期ファイル", [], []], [{"Str" => "ruby初期ファイル"}]]).should == "ruby初期ファイル"
      Main.header_name([2, ["その他", [], []], [{"Str" => "C初期ファイル"}]]).should == "C初期ファイル"
      Main.header_name([2, ["その他", [], []], [{"Str" => "aa"}, {"Str" => "C初期ファイル"}]]).should == "aaC初期ファイル"
    end

    specify "header?でなければRuntimeError" do
      proc { Main.header_name(nil) }.should raise_error(RuntimeError)
    end
  end

  describe '.para_name' do
    specify "'Str'の値を名前として取得する" do
      Main.para_name([{"Str" => ".gitignore 作成"}]).should == ".gitignore 作成"
      Main.para_name([{"Str" => "lib/アプリ名.rb"}]).should == "lib/アプリ名.rb"
    end

    specify "para?でなければRuntimeError" do
      proc { Main.para_name(nil) }.should raise_error(RuntimeError)
    end
  end

  describe '.code_block_src' do
    specify "" do
      Main.code_block_src([["", [], []], %Q!tmp/!]).should == "tmp/"
    end

    specify "code_block?でなければRuntimeError" do
      proc { Main.para_name(nil) }.should raise_error(RuntimeError)
    end
  end

  describe ".convert" do
    specify "例1" do
      Main.convert([
        {"Header" => [1, ["初期作成", [], []], [{"Str" => "初期作成"}]]},
        {"Para"   => [{"Str" => ".gitignore"}]},  # TODO: あとで".gitignore 作成"でもOKなようにする
        {"CodeBlock" => [["", ["ruby"], []], %Q!tmp/!]}
      ]).should == {"初期作成" => {".gitignore" => "tmp/"}}
    end

    specify "例2" do
      Main.convert([
        {"Header" => [1, ["初期作成", [], []], [{"Str" => "初期作成"}]]},
        {"Para"   => [{"Str" => ".gitignore"}]},
        {"CodeBlock" => [["", ["ruby"], []], %Q!tmp/!]},
        {"Para"   => [{"Str" => "lib/アプリ名.rb"}]},
        {"CodeBlock" => [["", ["ruby"], []], %Q!# coding: utf-8!]},
      ]).should == {"初期作成" => {
                                   ".gitignore" => "tmp/",
                                   "lib/アプリ名.rb" => "# coding: utf-8",
                                  }}
    end
  end

  describe "TODO" do
    specify "" do
      @main.data = [
        {"Header" => [1, ["その他", [], []], [{"Str" => "ruby初期設定"}]]},
        {"Para"   => [{"Str" => ".gitignore"}]},
        {"CodeBlock" => [["", ["ruby"], []], %Q!tmp/!]}
      ]

      @main.info.should == {
        "ruby初期設定" => {
          ".gitignore"      => "tmp/"
        }
      }
    end

    specify "#info" do
      @main.data = [
        {"Header" => [1, ["ruby初期設定", [], []], [{"Str" => "ruby初期設定"}]]},
        {"Para"   => [{"Str" => ".gitignore"}]},
        {"CodeBlock" => [["", [], []], %Q!tmp/!]},
        {"Para"   => [{"Str" => "lib/アプリ名.rb"}]},
        {"CodeBlock" => [["", ["ruby"], []], %Q!# coding: utf-8!]}
      ]

      @main.info.should == {
        "ruby初期設定" => {
                            ".gitignore"      => "tmp/",
                            "lib/アプリ名.rb" => "# coding: utf-8"
                          }
      }
    end
  end
end
