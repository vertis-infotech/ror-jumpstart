What is this?
=============
A skeleton rails app that uses a number of gems and works 
out-of-the-box, on your local machine and on Heroku.
Using this, you can go from a data model to a Heroku deployed,
working app within an hour or less!

This app is NOT production-worthy and the author shall not be held
responsible for any use of this code.

Why bother?
===========
Hundreds, probably thousands of web apps are written every day, 
requiring some or all of the following:

* User login, registration, password management.
* CRUD and search for many business objects (a.k.a. domain objects).
* Access controls over domain objects.
* Deployment to a cloud based environment.

All of the above are solved problems and numorous great solutions exist
for each. This is especially true in the RoR world where you can readily
map these requirements to known "gems" capturing best practices:

* Devise for User login, registration, password management.
* ActiveScaffold for CRUD and search for many business objects (a.k.a. domain objects).
* Cancan for Access controls over domain objects.
* Heroku for Deployment to a cloud based environment.

In theory, all these components play together nicely out-of-the-box.
In practice, you are often required to know a lot more than you could
care to know, just to get everything to work together!

Anyone who has worked with several different gems across versions of
gems, rails and operating systems knows how long it actually takes to
get everything to play nice :).

Let's face it - all these gems are "tools", not a goal in themselves.
Anyone who needs to solve a real world problem is not interested in 
hours of experimentation to make the "tools" work. A tool that doesn't 
work out of the box is useless!

This is my attempt to make it easy for you to quickly get to a
"stable" configuration, without hours of painful experimentation while
not having to compromize on the best practices.

This may also be very useful if you are learning/evaluating any of these
gems, to get a "working sandbox" with these gem.

This is in no way a guide to or demonstration of how to use the gems
mentioned. Please refer to their respective documentation pages for
that. While this can give you a great starting point for a real app, the
author does not take any responsibility for anyone attempting to use
this code in any fashion whatsoever.

Where will this work "As Advertized"? 
=====================================

This is tested to work on:
--------------------------
RVM: 1.14.1
Ruby: 1.9.3 (via rvm)
OS: Mac OS X 10.7.4
bundler: 1.1.4
database: SQLite

However, it should be quite easy to follow the set up in other
environments.
If you git it to work in your environment, please "fork this" 
and save someone else the pain!

What's in the app?
==================
This is based on real-world requirements as follows:
1. An attendance system to log attendance of workers from various sites.
2. Supervisors at various customer sites can log attendance (only for
their "assigned" sites).
3. A Customer can log in to view attendance for their sites. They must
not be able to view/edit any other data.
4. Any Staff member should be able to create and manage Supervisor
logins.
5. The "Staff" logins are charged a subscription on a per-login basis. 
Only "Super Admin" should be able to manage "Staff" logins.

Let's do it then!
=================
1. Create the skeleton app by running ./create_app.sh

Add the following to config/routes.rb
  root :to => 'home#index'

Delete the file public/index.html

   Now start the rails server and verify that the app runs fine
   DONT CREATE ANY DATA YET. Just make sure the UI looks ok.

   http://localhost:3000
   http://localhost:3000/users
   http://localhost:3000/roles
   http://localhost:3000/customers
   http://localhost:3000/sites

2. Create a migration as follows and run it:
--------------------------------------------
cd ams
rails g migration UsersHaveAndBelongToManyRoles

class UsersHaveAndBelongToManyRoles < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.references :role, :user
    end
  end
 
  def self.down
    drop_table :roles_users
  end
end

rake db:migrate

3. Establish relationships as per the ER diagram:
-------------------------------------------------
In user.rb: 
	has_many :sites, :foreign_key => 'supervisor_id'
  has_and_belongs_to_many :roles
  belongs_to :customer

def role?(role)
    return !!self.roles.find_by_name(role)
end

def to_s
  "#{first_name} #{last_name} [#{email}]"
end

In role.rb:
  has_and_belongs_to_many :users

def to_s
  name
end

In site.rb:
	belongs_to :customer
	belongs_to :supervisor, :class_name => 'User'
	has_many :attendances

In customer.rb:
	has_many :sites
  has_many :users

In attendance.rb:
	belongs_to :supervisor, :class_name => 'User'
	belongs_to :site
	belongs_to :customer

4. Add the login/logout links:
------------------------------
In config/initializers/devise.rb - 
 config.sign_out_via = :get

In views/layouts/application.html.erb just under <body> -
<ul class="hmenu">
  <%= render 'devise/menu/registration_items' %>
  <%= render 'devise/menu/login_items' %>
</ul>

5. Set up the test (seed) data
------------------------------
rake db:seed

6. Add to all controllers - 
---------------------------
before_filter :authenticate_user!

7. Add authorization as per business rules -
-------------------------------------------- 
Follow instructions in app/models/ability.rb, initialize() method.
The authorization rules are clearly described in the Ability class.
For more details on how to define such rules, consult cancan
documentation.

Also add the following to ApplicationController - 

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => exception.message
  end

8. That's it! Now test the app as follows:
------------------------------------------
* Log in as email: super@test.com, password: @dmin123
  This user should be able to CRUD (Create/Update/Delete) all objects.
* Log in as email: staff@test.com, password: staff123
  This user should be able to CRUD everything other than users.
* Log in as email: customer@test.com, password customer123
  This user should not be able to access anything but attendance for
Site One(Customer One).

Deploying the app on Heroku:
============================
* Sign up for a free account on Heroku
* Refer to https://devcenter.heroku.com/articles/rails3

heroku login

#Precompile assets locally to avoid hassles due to untimely initializations in heroku 
# see https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar
RAILS_ENV=production bundle exec rake assets:precompile

git init

git add .

git commit -m "init"

heroku create demo8jun --stack cedar

git push heroku master


