begin
  ENV.update YAML.safe_load(File.read('config/application.yml'))
rescue Errno::ENOENT
  puts 'You have to add a correct application.yml file'
end
