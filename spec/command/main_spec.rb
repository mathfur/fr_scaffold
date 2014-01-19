# coding: utf-8

require "spec_helper"

describe "command test" do
  specify "pandoc --versionが実行できる" do
    result = `pandoc --version`
    result.split("\n").first.should =~ /^pandoc [0-9.]+$/
  end

  describe "pandocが期待通りに動いていることの確認" do
    specify "例1" do
md_src = <<EOS
#foo
```
print "hello"
```
EOS
      fname = "#{TMP_DIR}/testdata.md"
      open(fname, "w"){|f| f.write md_src }

      json = JSON.parse(`pandoc --from=markdown --to=json #{fname}`)

      json.size.should == 2
      json[1][0]["Header"].first.should == 1
      json[1][0]["Header"].last.should == [{"Str" => "foo"}] # [ヘッダレベル,  [内容,[],[]], [{"Str"=>中身}]]
      json[1][1]["CodeBlock"].size.should == 2
      json[1][1]["CodeBlock"][0].should == ["", [], []]    # ["",  [ブロックのfiletype],  []]
      json[1][1]["CodeBlock"][1].should == %Q!print "hello"! # ソース
    end

    specify "例2" do
md_src = <<EOS
### each文
```ruby
%w{一 あ ア 亜 〜 ～ 申 能 表}.each do |e|
  print e
end
```

## 〜～申能表
あああ
EOS
      fname = "#{TMP_DIR}/testdata.md"
      open(fname, "w"){|f| f.write md_src }

      json = JSON.parse(`pandoc --from=markdown --to=json #{fname}`)

      json.size.should == 2
      json[1].size.should == 4
      json[1][0]["Header"].first.should == 3
      json[1][0]["Header"].last.should  == [{"Str" => "each文"}]
      json[1][1]["CodeBlock"].size.should == 2
      json[1][1]["CodeBlock"][0].should == ["", ["ruby"], []]  # ["",  [ブロックのfiletype],  []]
      json[1][1]["CodeBlock"][1].should == <<EOS.rstrip
%w{一 あ ア 亜 〜 ～ 申 能 表}.each do |e|
  print e
end
EOS

      json[1][2]["Header"].first.should == 2
      json[1][2]["Header"].last.should == [{"Str" => "〜～申能表"}]
      json[1][3]["Para"].should == [{"Str" => "あああ"}]
    end

    def teardown
      FileUtils.rm(fname)
    end
  end
end
