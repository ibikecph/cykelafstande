# encoding: UTF-8

require 'net/http'
require 'json'

SERVER  = "http://localhost:5000"
#SERVER  = "http://routes.ibikecph.dk"


path_home = 'home.loc.csv'
path_work = 'work.loc.csv'

path_out = "result.csv"

STD_HASTIGHED = 16.4    # fra cykelsekretariatet

if File.exists? path_out
  puts "#{path_out} already exits."
  exit
end

out_file = File.open(path_out, 'w')

homes = []
works = []

File.open("./#{path_home}").each_line do |line|
    address = line.chop
    homes <<  address.split(',')
end

File.open("./#{path_work}").each_line do |line|
    address = line.chop
    works <<  address.split(',')
end



def route from,to,out_file, n, direction
  a = "#{from[3]},#{from[4]}"
  b = "#{to[3]},#{to[4]}"
  uri = URI.parse "#{SERVER}/viaroute?loc=#{a}&loc=#{b}&output=json&instructions=true&alt=false&z=10"
  response = Net::HTTP.get uri
  json = JSON.parse response
  status = json["status"]
  distance = json["route_summary"]["total_distance"]
  time = json["route_summary"]["total_time"]
  route_name = json["route_name"].first
  str = [n,direction,from,to,status,route_name,distance,time, (distance.to_f/time.to_f)*3.6, (distance.to_f/(STD_HASTIGHED/3.6)).to_i].flatten.join(',')+"\n"
  out_file.write str
  if status != 0
    puts
    puts "ERROR: #{status}"
    p from
    p to
    p str
    p uri
    p json
    exit
  end
  print '.'
end

out_file.write "id, retning, from address,from nr, from zip, from lon, from lat, to address,to nr, to zip, to lon, to lat, fejlkode, rutenavn, meter, sekunder, hastighed, sek ved std hastighed\n"

n = 0
print "Calculating #{2 * homes.length * works.length} routes "
homes.each do |home|
  works.each do |work|
    route home,work,out_file, n, 'hjem > arbejde'
    n = n + 1
    route work,home,out_file, n, 'arbejde > hjem'
    n = n + 1
  end
end

puts
puts 'Done'

