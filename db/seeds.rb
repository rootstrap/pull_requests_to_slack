AdminUser.create!(email: 'admin@example.com', password: 'password')

User.create!(github_name: 'dependabot', blacklisted: true)
