#!/usr/bin/env ruby
# Generate sitemap.xml for quick and easy search engine updating

# Useful tables:
#   hansard
#   epobject
#   member

require 'rubygems'
require 'active_record'
require "../../rblib/config"

# Load database information from the mysociety configuration
MySociety::Config.set_file("../conf/general")

class Member < ActiveRecord::Base
	set_table_name "member"
	
	def full_name
		"#{first_name} #{last_name}"
	end
	
	def Member.find_all_person_ids
		Member.find(:all, :group => "person_id").map{|m| m.person_id}
	end
	
	# Find the most recent member for the given person_id
	def Member.find_most_recent_by_person_id(person_id)
		Member.find_all_by_person_id(person_id, :order => "entered_house DESC", :limit => 1).first
	end
	
	# Returns the unique url for this member.
	# Obviously this doesn't really belong in the model but, you know, for the time being...
	def url
		domain = "http://www.openaustralia.org"
		if house == 1
			house_url = "mp"
		elsif house == 2
			house_url = "senator"
		else
			throw "Unexpected value for house"
		end
		# The url is made up of the full_name, constituency and house
		# TODO: Need to correctly encode the urls
		domain + "/" + house_url + "/" + full_name.downcase.tr(' ', '_') + '/' + constituency.downcase
	end
end

#ActiveRecord::Base.primary_key_prefix_type = :table_name_with_underscore

ActiveRecord::Base.establish_connection(
	:adapter  => "mysql",
	:host     => MySociety::Config.get('DB_HOST'),
	:username => MySociety::Config.get('DB_USER'),
	:password => MySociety::Config.get('DB_PASSWORD'),
	:database => MySociety::Config.get('DB_NAME')
)

member = Member.find_most_recent_by_person_id(10093)

p member

#member_urls = Member.find(:all).map {|member| member.url}.uniq.sort
#member_urls.each do |url|
#	puts url
#end

urls = Member.find_all_person_ids.map {|person_id| Member.find_most_recent_by_person_id(person_id).url}

urls.each do |url|
	p url
end
