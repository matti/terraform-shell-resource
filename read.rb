require 'json'

files = JSON.parse(STDIN.read)

result = {}
files.each_pair do |name, path|
  result[name] = if File.exist? path
    File.read path
  else
    ""
  end
end

puts result.to_json
