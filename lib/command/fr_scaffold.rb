# coding: utf-8

usage = <<EOS
Usage: fr_scaffold [options]
-h  --help           Display help.
-v  --version        Display version information and exit.
-V  --verbose        Verbose mode

-t  --template=fname Specify template file
-i  --input          Input filename
-o  --output         Output filename

-l  --list-templates List available template names by using template files

-I  --init           Create fr_scaffold_files directory and layer1.yaml.erb
-l1 --layer1-to-2    Convert layer1 to layer2
-l2 --layer2-to-3    Convert layer2 to layer3
-r  --run            Run layer3 script
EOS

opts = GetoptLong.new(
  ['--help',           '-h', GetoptLong::NO_ARGUMENT],
  ['--version',        '-v', GetoptLong::NO_ARGUMENT],
  ['--verbose',        '-V', GetoptLong::NO_ARGUMENT],

  ['--template',       '-t', GetoptLong::REQUIRED_ARGUMENT],
  ['--input',          '-i', GetoptLong::REQUIRED_ARGUMENT],
  ['--output',         '-o', GetoptLong::REQUIRED_ARGUMENT],

  ['--list-templates', '-l', GetoptLong::NO_ARGUMENT],

  ['--init',           '-I', GetoptLong::NO_ARGUMENT],
  ['--layer1-to-2',    '-1', GetoptLong::NO_ARGUMENT],
  ['--layer2-to-3',    '-2', GetoptLong::NO_ARGUMENT],
  ['--layer3-to-4',    '-3', GetoptLong::NO_ARGUMENT],
  ['--run-layer4',     '-r', GetoptLong::NO_ARGUMENT]
)

command = nil
template = nil
input_filename = nil
output_filename = nil

begin
  opts.each do |opt, arg|
    case opt
    when '--help'; puts usage; exit
    when '--version'; puts FrScaffold::VERSION; exit
    when '--verbose'
      $VERBOSE = true

    when '--template'
      template = arg
    when '--input'
      input_filename = arg.gsub('~'){ "#{ENV['HOME']}/" }
    when '--output'
      output_filename = arg.gsub('~'){ "#{ENV['HOME']}/" }

    when '--list-templates'
      command = :list_templates

    when '--init'
      command = :init
    when '--layer1-to-2'
      command = :layer1_to_2
    when '--layer2-to-3'
      command = :layer2_to_3
    when '--layer3-to-4'
      command = :layer3_to_4
    when '--run-layer4'
      command = :run_layer4
    else
      raise
    end
  end
rescue StandardError => e
  puts "wrong option" + e.inspect
  puts e.backtrace
  exit
end

# ================================================
# If filenames are not specified, use read .fr_scaffold.yaml

config = File.exist?(CONFIG_FILE) && YAML.load_file(CONFIG_FILE)

if !input_filename and !output_filename and config
  case command
  when :layer1_to_2
    input_filename  = config['layer1']
    output_filename = config['layer2']
  when :layer2_to_3
    input_filename  = config['layer2']
    output_filename = config['layer3']
  when :layer3_to_4
    input_filename  = config['layer3']
    output_filename = config['layer4']
  when :run_layer4
    input_filename  = config['layer4']
  end
end

template ||= (config && config['template'])


# ================================================
# Expansion

[input_filename, output_filename, template].each do |fname|
  fname.gsub!('~'){ "#{ENV['HOME']}/" } if fname
end

# ================================================
# Validate existence of required options

unless command
  STDERR.puts "[ERROR] --layer* or --run option is required."
  exit
end

if command != :init and command != :list_templates and !input_filename
  STDERR.puts "input_filename is required."
  exit
end

if command.to_s =~ /^layer/
  unless output_filename
    STDERR.puts "[ERROR] output_filename is required."
    exit
  end

  if have_git_change?(output_filename)
    STDERR.puts "[ERROR] output target have change."
    exit
  end
end

if command == :init and !template
  STDERR.puts "[ERROR] --init has to template option."
  exit
end

if command == :list_templates and !template
  STDERR.puts "[ERROR] --list-templates has to template option."
  exit
end

# ================================================

outputter = FrScaffold::Outputter.new(:template => template)

case command
when :list_templates
  outputter.load_from_md(template)
  outputter.l2_template.each do |header, hash|
    puts header

    if $VERBOSE
      hash.each do |fname, code_block|
        puts fname.inspect
        puts "```"
        puts code_block
        puts "```"
      end
    end
  end

when :init
  FileUtils.mkdir_p(FR_SCAFFOLD_DIR)
  output_filename ||= "#{FR_SCAFFOLD_DIR}/layer1.yaml.erb"

  outputter.load_from_md(template)

  open(output_filename, "w") do |f|
    outputter.template_names.each do |name|
      f.write <<EOS
# - tag: template
#   name: #{name}
EOS
    end
  end

  open("#{BASE_DIR}/.fr_scaffold.yml", "w") do |f|
    f.write <<EOS
layer1: fr_scaffold_files/layer1.yaml.erb
layer2: fr_scaffold_files/layer2.yaml.erb
layer3: fr_scaffold_files/layer3.yaml.erb
layer4: fr_scaffold_files/layer4.rb
template: fr_scaffold_files/template.md
EOS
  end

when :layer1_to_2
  output_content = YAML.load(ERB.new(File.read(input_filename), nil, '-').result)

  open(output_filename, "w") do |f|
    f.write YAML.dump(output_content)
  end

when :layer2_to_3
  raise "[ERROR] --template option is required." unless template

  outputter.layer2_input = YAML.load(ERB.new(File.read(input_filename), nil, '-').result)
  outputter.layer3_input = outputter.to_file_content_pairs

  open(output_filename, "w") do |f|
    f.write outputter.layer3_output(TARGET_DIR)
  end
when :layer3_to_4
  outputter.layer4_input = YAML.load(ERB.new(File.read(input_filename), nil, '-').result)

  open(output_filename, "w") do |f|
    f.write outputter.layer4_output(TARGET_DIR)
  end
when :run_layer4
  load input_filename
else
  raise "wrong command: #{command.inspect}"
end
