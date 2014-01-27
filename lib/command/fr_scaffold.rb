# coding: utf-8

usage = <<EOS
Usage: fr_scaffold [options] input_filename output_filename
-h  --help           Display help.
-v  --version        Display version information and exit.
-t  --template=fname Specify template file
-l1 --layer1-to-2    Convert layer1 to layer2
-l2 --layer2-to-3    Convert layer2 to layer3
-r  --run            Run layer3 script
EOS

opts = GetoptLong.new(
  ['--help',        '-h', GetoptLong::NO_ARGUMENT],
  ['--version',     '-v', GetoptLong::NO_ARGUMENT],
  ['--template',    '-t', GetoptLong::REQUIRED_ARGUMENT],
  ['--layer1-to-2', '-1', GetoptLong::NO_ARGUMENT],
  ['--layer2-to-3', '-2', GetoptLong::NO_ARGUMENT],
  ['--layer3-to-4', '-3', GetoptLong::NO_ARGUMENT],
  ['--run-layer4',  '-r', GetoptLong::NO_ARGUMENT]
)

command = nil
template = nil
begin
  opts.each do |opt, arg|
    case opt
    when '--help'; puts usage; exit
    when '--version'; puts FrScaffold::VERSION; exit
    when '--template'
      template = arg
    when '--layer1-to-2'
      command = :layer1_to_2
    when '--layer2-to-3'
      command = :layer2_to_3
    when '--layer3-to-4'
      command = :layer3_to_4
    when '--run-layer4'
      command = :run_layer4
    end
  end
rescue StandardError => e
  puts "wrong option" + e.inspect
  puts e.backtrace
  exit
end

input_filename = ARGV[0]
output_filename = ARGV[1]

# ================================================
# Validate existence of required options

unless command
  STDERR.puts "[ERROR] --layer* or --run option is required."
  exit
end

unless input_filename
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

# ================================================

outputter = FrScaffold::Outputter.new

case command
when :layer1_to_2
  output_content = YAML.load(ERB.new(File.read(input_filename), nil, '-').result)

  open(output_filename, "w") do |f|
    f.write YAML.dump(output_content)
  end
when :layer2_to_3
  outputter.layer2_input = YAML.load(ERB.new(File.read(input_filename), nil, '-').result)

  raise "[ERROR] --template option is required." unless template

  outputter.load_template_from_md(template)
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
