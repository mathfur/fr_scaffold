# coding: utf-8

require "spec_helper"

describe FrScaffold::Outputter do
  Outputter = FrScaffold::Outputter

  before(:all) do
    @dst_dir = Dir.mktmpdir
  end

  describe "#to_file_content_pairs" do
    before(:all) do
      @outputter = Outputter.new
      @outputter.l2_template = {
         "ruby初期設定" => {
                             ".gitignore"      => "log/",
                             "lib/アプリ名.rb" => ["# coding: utf-8", "", "print 'hello'"].join("\n")
                           },
         "haskell初期設定" => {
                             ".gitignore"  => %w{cabal-dev *.o}.join("\n"),
                             "src/Main.hs" => "main = print 'hello'"
                           }
      }
    end

    describe "case 1" do
      before(:all) do
        @outputter.layer2_input = [
          {'tag' => "template", 'name' => "haskell初期設定"}
        ]
      end

      specify do
        @outputter.to_file_content_pairs.should == [
          ['.gitignore', "cabal-dev\n*.o"],
          ['src/Main.hs', "main = print 'hello'"],
        ]
      end
    end

    describe "case 2" do
      before(:all) do
        @outputter.layer2_input = [
          {'tag' => "template", 'name' => "ruby初期設定"},
          {'tag' => "template", 'name' => "haskell初期設定"},
          {'tag' => "entry",    'name' => 'README.md'}
        ]
      end

      specify do
        @outputter.to_file_content_pairs.sort.should == [
          ['.gitignore', "cabal-dev\n*.o"],
          ['.gitignore', "log/"],
          ['lib/アプリ名.rb', "# coding: utf-8\n\nprint 'hello'"],
          ['src/Main.hs', "main = print 'hello'"],
          ['README.md', '']
        ].sort
      end
    end
  end
end
