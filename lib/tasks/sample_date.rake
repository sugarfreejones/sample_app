require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    User.create!(:name => "Example User",
                :email => "user@railstutorial.org",
                :password => "foobar",
                :password_conformation => "foobar")
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!(:name => name,
                    :email => email,
                    :password => password,
                    :password_conformation => password)
    end
  end
end

