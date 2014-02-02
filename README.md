FrScaffold
==================
Generate files for first commit.

Install
-------
 1. gem build fr_scaffold.gemspec
 2. gem install fr_scaffold-0.0.3.gem

Usage
-----
 1. Create project directory.
 2. Create fr_scaffold_files directry in the project directory.
 3. Prepare markdown file as follow to use template.
```
# language name
## group1
### first commit
filename
codeblock
filename
codeblock
...

## group2
```
 4. Run "fr_scaffold --init --template=foo.md"
 5. Edit layer1.yaml.erb
 6. Run "fr_scaffold --layer1-to-2" to create layer2.yaml.erb
 7. Edit layer2.yaml.erb
 8. Run "fr_scaffold --layer2-to-3" to create layer3.rb
 9. Edit layer3.rb
 10. Run "fr_scaffold --run" to create target project files.

Memo
----
* templateの作成するファイル名部分の【】, ()はコメントと見なされ、ファイル名作成には使われない

Layer3 Memo
-----------
```
create_source("/foo/bar") do |f|
  f.puts(ERB.new(<<-'IIIIIII',  nil,  '-').result)
aaaa
                     IIIIIII
  f.klass 'User' do |f2|
    f2.def_ 'full_name'
  end
end
```

Code Status
------------------
![build status](https://travis-ci.org/mathfur/fr_scaffold.png)

License
-------
Copyright &copy; 2013 mathfur
Distributed under the [MIT License][mit].
[MIT]: http://www.opensource.org/licenses/mit-license.php
