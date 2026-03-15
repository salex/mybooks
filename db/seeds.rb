# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

client = Client.create({                                                                                    
 "name"=>"VFW Post 8600",                                                                    
 "acct"=>"8600",                                                                             
 "address"=>"PO Box 8601",                                                                   
 "city"=>"Gadsden",                                                                          
 "state"=>"AL",                                                                              
 "zip"=>"35902",                                                                             
 "phone"=>"256.456.2440",                                                                    
 "subdomain"=>"post8600",                                                                    
 "domain"=>"vfwpost8600.org"})
