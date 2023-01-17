desc 'Adds a user to the blocklist. ' \
     'Use "rake add_blocklisted_user some_gh_name"'
task add_blocklisted_user: [:environment] do
  ARGV.each { |a| task(a.to_sym {}) }
  name = ARGV[1]

  if name.present?
    User.create!(github_name: name, blacklisted: true)
  else
    warn 'Invalid or missing GitHub name param'
    warn 'Use "rake add_blocklisted_user some_gh_name"'
    exit(255)
  end
end
