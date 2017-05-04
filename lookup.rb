# encoding: UTF-8

require 'net/http'
require 'json'

class Lookup
  SERVER  = "http://localhost:5000"
  #SERVER  = "http://routes.ibikecph.dk"
  STD_HASTIGHED = 16.4    # fra cykelsekretariatet


  def route from,to,out_file, n, direction
    a = "#{from[4]},#{from[3]}"
    b = "#{to[4]},#{to[3]}"
    uri = URI.parse "#{SERVER}/route/v1/fast/#{a};#{b}?geometries=geojson&overview=full"
    response = Net::HTTP.get uri
    json = JSON.parse response

    code = json["code"]
    if code != 'Ok'
      puts
      puts "ERROR: #{code}"
      p from
      p to
      p str
      p uri
      p json
      exit
    end

    route = json["routes"][0]
    distance = route["distance"]
    duration = route["duration"]
    str = [
            n,
            direction,
            from,
            to,
            code,
            distance,
            duration,
            (distance.to_f/duration.to_f)*3.6,
            (distance.to_f/(STD_HASTIGHED/3.6)).to_i
          ].flatten.join(',')+"\n"
    #print '.'

    @geometries << JSON.generate(route["geometry"])
    @distance_sum = @distance_sum + distance
    return str
  end

  def run
    homes = []
    works = []
    @distance_sum = 0

    path_home = 'home.loc.csv'
    path_work = 'work.loc.csv'
    path_out = "result.csv"

    if File.exists? path_out
      puts "#{path_out} already exits."
      exit
    end

    out_file = File.open(path_out, 'w')

    File.open("./#{path_home}").each_line do |line|
        address = line.chop
        homes <<  address.split(',')
    end

    File.open("./#{path_work}").each_line do |line|
        address = line.chop
        works <<  address.split(',')
    end


    #out_file.write "id, retning, from address,from nr, from zip, from lon, from lat, to address,to nr, to zip, to lon, to lat, kode, afstand, tid, hastighed, tid (standardhastighed)\n"
    #n = 0
    #print "Calculating #{2 * homes.length * works.length} routes..."
    #homes.each do |home|
    #  works.each do |work|
    #    out_file.write route(home,work,out_file, n, 'hjem > arbejde')
    #    n = n + 1
    #    out_file.write route(work,home,out_file, n, 'arbejde > hjem')
    #    n = n + 1
    #  end
    #end

    n = 0
    @geometries = []
    homes.each do |home|
      works.each do |work|
        route(home,work,out_file, n, 'hjem > arbejde')
        n = n + 1
        route(work,home,out_file, n, 'arbejde > hjem')
        n = n + 1
      end
    end

    @geometries.map! do |geometry|
      <<-EOF
        {
          "type": "Feature",
          "properties": {
            "stroke": "#f00",
            "stroke-width": 3,
            "stroke-opacity": 0.3
          },
          "geometry": #{geometry}
        }
    EOF
    end

    geojson = <<-EOF
      {
        "type": "FeatureCollection",
        "features": [
          #{@geometries.join(',')}
        ]
      }
    EOF

    print geojson

    #puts
    #puts "Distance sum: #{@distance_sum}"
    #puts 'Done'
  end

end


Lookup.new.run