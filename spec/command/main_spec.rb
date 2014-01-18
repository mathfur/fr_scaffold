# coding: utf-8

describe "command test" do
  specify "pandoc --versionが実行できる" do
    result = `pandoc --version`
    result.split("\n").first.should =~ /^pandoc [0-9.]+$/
  end
end
