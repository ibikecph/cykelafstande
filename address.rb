# encoding: UTF-8

require 'net/http'
require 'json'




path_in = "#{ARGV[0]}.csv"
path_out = "#{ARGV[0]}.loc.csv"


out_file = File.open(path_out, 'w')


File.open("./#{path_in}").each_line do |line|
    begin
      address = line.chop
      uri = URI.parse "http://geo.oiorest.dk/adresser/#{URI.escape(address)}.json"
      response = ''
      Timeout.timeout(10) do
        response = Net::HTTP.get uri
      end
      json = JSON.parse response
      lat = json['wgs84koordinat']["bredde"]
      lon = json['wgs84koordinat']["længde"]
      out_file.write "#{address},#{lat},#{lon}\n"
  rescue
      puts "#{address} not found"
    end
end

#curl http://geo.oiorest.dk/adresser/Alleshavevej,11,4593.json

