class CloudMade

  @api_key =  nil
  @style_id = 1
  @http_root = nil
  @cache_path = nil

  class << self
    attr_accessor :api_key, :style_id, :http_root, :cache_path

    def cache_dir
      return Pathname(CloudMade.http_root)+Pathname(CloudMade.cache_path) if CloudMade.http_root && CloudMade.cache_path

      # if they only have one set, it's likely an error:
      raise "\n\nYou must specify BOTH your http_root and your cache_path for caching to work:\n\nIn init.rb (or whatever):\nCloudMade.http_root = './public'\nCloudMade.cache_path = 'images/maps'\n\n* cache_path is relative to your http_root\n\n" if CloudMade.http_root || CloudMade.cache_path
    end

  end

  # Creates and returns a new CloudMade object
  #
  # @param [String] key Your CloudMade API key
  #
  # @example
  #   cm = CloudMade.new 'ASOIU32432SD3KS4AD23I32UOIJ4A234SKJ3D4HADS'
  #
  # @return [CloudMade] CloudMade object with your embedded API key 
  #
  def initialize(key=nil)
    CloudMade.api_key = key if key
    FileUtils.mkdir_p CloudMade.cache_dir if CloudMade.cache_dir
    raise "\n\nYou must provide your API key to use the CloudMade service.\n\nIn init.rb (or whatever):\nCloudMade.api_key = 'YOUR_API_KEY_HERE'\n - or - \nCloudMade.new('YOUR_API_KEY_HERE')\n\n" unless CloudMade.api_key
  end


  # Creates and returns a new CloudMade::StaticMap object
  #
  # @param [Hash] params Params Hash to override default values
  # @option params [String] :api_key Your CloudMade API key. Only required if different than the one provided to {CloudMade#new}
  #
  # @option params [String, Integer] :width (480) Map image width (required)
  # @option params [String, Integer] :height (360) Map image height (required)
  #
  # @option params ['png','jpg'] :format ('png') Desired image format
  # @option params [String,Integer] :style_id (1) CloudMade Style ID, defaults to their in-house style.
  # @option params [String] :domain ('staticmap.cloudmade.com') StaticMap domain - maybe you want to use a proxy?
  #
  # @overload static_map ( :lat=>lat, :lng=>lng, :zoom=>zoom, ... )
  #   Creates a static map with a fixed center and zoom level. These options will override any bbox settings, if supplied.
  #   @option params [String, Float] :lat Map center latitude
  #   @option params [String, Float] :lng Map center longitude
  #   @option params [String, Integer] :zoom (15) Desired zoom level
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     map = cm.static_map :lat=>43.6304, :lng=>-72.5897, :zoom=>15
  #
  # @overload static_map ( :bbox=>bbox, :padding=>padding, ... )
  #   Creates a static map with a specific bounding box - the bbox will expand with optional padding. NOTE: bbox will be expanded to match the aspect ratio of the image.
  #   @option params [String, Array<Float,Float,Float,Float>, Array<Float,Float,Float,Float,FLoat>] :bbox Bounding Box coordinates, either as an Array of four Floats or a comma separated String.
  #   @option params [Float] :padding (0.125) Percentage of width / height to pad by. Defaults to 1/8th width & height
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     map = cm.static_map :width=>320, :height=>200, :bbox=>[ 43.6304, -72.5897, 43.8304, -72.4897 ], :padding=>0.125
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     map = cm.static_map :width=>320, :height=>200, :bbox=>[ 43.6304, -72.5897, 43.8304, -72.4897, 0.125 ]
  #
  # @option params [Array<CloudMade::Path,...>] :paths A collection of zero or more Path objects to render on the map. See {CloudMade#path} for path syntax.
  #
  # @option params [Array<CloudMade::Marker,...>] :markers A collection of zero or more Marker objects to render on the map. See {CloudMade#marker} for marker syntax.
  #
  # @return [CloudMade::StaticMap] a static map opject that can be altered, although it will almost certainly be rendered to a String (map image URL) eventually with #to_s
  #
  def static_map(params={}) 
    CloudMade::StaticMap.new(params)
  end

  def self.static_map(params={})
    CloudMade::StaticMap.new(params)
  end

  # Creates and returns a new CloudMade::Path object, likely for including in a StaticMap
  #
  # @param [Hash] params Params Hash to override default values
  # @option params [String,Fixnum] :color ('black') Path colour, defaults to black. You can also use hex codes: 0x0088ff
  # @option params [String, Integer] :weight (2) Path width in pixels
  # @option params [String, Float] :opacity (1) Path opacity. 0..1
  # @option params [Array< Array< Float, Float >, ... >] :points (1) An array of point arrays [ [lat1,lng1], [lat2,lng2], ... ]
  #
  # @example
  #   cm = CloudMade.new API_KEY
  #   map = cm.static_map :lat=>43.6304, :lng=>-72.5897, :zoom=>15
  #   path = cm.path :color=>'blue', :weight=>3, :opacity=>0.8, :path=>[ [43.6304,-72.5897], [43.6315,-72.5897], [43.6315,-72.5833], ... ]
  #   map.paths << path
  #
  # @example
  #   cm = CloudMade.new API_KEY
  #   path = cm.path :color=>0xff8800, :weight=>3, :opacity=>0.4, :path=>[ [43.6304,-72.5897], [43.6315,-72.5897], [43.6315,-72.5833], ... ]
  #   map = cm.static_map :lat=>43.6304, :lng=>-72.5897, :zoom=>15, :paths=> [ path ]
  #
  # @return [CloudMade::Path] a {CloudMade::Path} object that can be altered, although it will almost certainly be appended to CloudMade::StaticMap#paths<< eventually
  #
  def path(params={})
    CloudMade::Path.new(params)
  end

  def self.path(params={})
    CloudMade::Path.new(params)
  end


  # Creates and returns a new CloudMade::Marker object, likely for including in a StaticMap
  #
  # @param [Hash] params Params Hash to override default values
  # @option params [Float] :lat Marker latitude, represents bottom-right corner of an image
  # @option params [Float] :lng Marker longitude, represents bottom-right corner of an image
  # @option params [String, Float] :opacity (1) Marker opacity. 0..1
  #
  # @overload marker ( :url=>'http://your.domain/image.png', :lat=>43.6304, :lng=>-72.5897 )
  #   Creates a Marker object from an image you provide via URL. Be sure to include an absolute URL, including domain
  #   @option params [String] :url The URL to your marker image 
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     marker = cm.marker :url=>'http://your.domain/image.png', :lat=>43.6304, :lng=>-72.5897, :opacity=>0.8
  #
  # @overload marker ( :size=>'big', :label=>'X', :lat=>43.6304, :lng=>-72.5897 )
  #   Creates a Marker object that supports an optional single character label
  #   @option params ['big','small'] :size ('big') The size of your marker label ( big | small )
  #   @option params [String] :label ('A') The label text. NOTE: SINGLE CHARACTER ONLY (Why, CloudMade? WHY????)
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     marker = cm.marker :size=>'small', :label=>'X', :lat=>43.6304, :lng=>-72.5897, :opacity=>0.4
  #
  # @return [CloudMade::Marker] a {CloudMade::Marker} object that can be altered, although it will almost certainly be appended to CloudMade::StaticMap#marker<< eventually
  #
  def marker(params={})
    CloudMade::Marker.new(params)
  end

  def self.marker(params={})
    CloudMade::Marker.new(params)
  end


  # Creates and returns a new CloudMade::BoundingBox object
  #
  # @param [Hash] params Params Hash to override default values
  # @option params [Float] :lat Marker latitude, represents bottom-right corner of an image
  # @option params [Float] :lng Marker longitude, represents bottom-right corner of an image
  # @option params [String, Float] :opacity (1) Marker opacity. 0..1
  #
  # @overload marker ( :url=>'http://your.domain/image.png', :lat=>43.6304, :lng=>-72.5897 )
  #   Creates a Marker object from an image you provide via URL. Be sure to include an absolute URL, including domain
  #   @option params [String] :url The URL to your marker image 
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     marker = cm.marker :url=>'http://your.domain/image.png', :lat=>43.6304, :lng=>-72.5897, :opacity=>0.8
  #
  # @overload marker ( :size=>'big', :label=>'X', :lat=>43.6304, :lng=>-72.5897 )
  #   Creates a Marker object that supports an optional single character label
  #   @option params ['big','small'] :size ('big') The size of your marker label ( big | small )
  #   @option params [String] :label ('A') The label text. NOTE: SINGLE CHARACTER ONLY (Why, CloudMade? WHY????)
  #
  #   @example
  #     cm = CloudMade.new API_KEY
  #     marker = cm.marker :size=>'small', :label=>'X', :lat=>43.6304, :lng=>-72.5897, :opacity=>0.4
  #
  # @return [CloudMade::Marker] a {CloudMade::Marker} object that can be altered, although it will almost certainly be appended to CloudMade::StaticMap#marker<< eventually
  #
  def bounding_box(*params)
    CloudMade::BoundingBox.new(*params)
  end

  def self.bounding_box(*params)
    CloudMade::BoundingBox.new(*params)
  end

  alias :bbox :bounding_box

  alias :static :static_map

  class StaticMap
    attr_accessor :api_key, :width, :height, :zoom, :bbox, :padding, :lat, :lng, :format, :style_id, :markers, :paths, :domain

    # @param (see CloudMade#initialize)
    def initialize(params={})
      @api_key = params.fetch :api_key, CloudMade.api_key # the cloudmade object
      @width = params.fetch :width, 320
      @height = params.fetch :height, 200
      @zoom = params.fetch :zoom, 15
      @bbox = params.fetch :bbox, nil
      @padding = params.fetch :padding, 0.125
      @lat = params.fetch :lat, nil
      @lng = params.fetch :lng, nil
      @format = params.fetch :format, 'png'
      @style_id = params.fetch :style_id, CloudMade.style_id
      @markers = params.fetch :markers, []
      @paths = params.fetch :paths, []
      @domain = params.fetch :domain, 'staticmap.cloudmade.com'
    end
      
    def to_s
      raise "\n\nYou must provide your API key to use the CloudMade service.\n\nIn init.rb (or whatever):\nCloudMade.api_key = 'YOUR_API_KEY_HERE'\n - or - \nCloudMade.new('YOUR_API_KEY_HERE')\n\n" unless @api_key

      require 'zlib'
      require 'pathname'

      #TODO: if no bbox or lat/lng given, generate bbox to include all paths & markers

      uri = "http://#{@domain}/#{@api_key}/map?format=#{@format}&size=#{@width}x#{@height}&styleid=#{@style_id}"

      if @lat && @lng
        uri << "&center=#{@lat},#{@lng}"
        uri << "&zoom=#{@zoom}"
      elsif @bbox
        @bbox = CloudMade::BoundingBox.new(@bbox)
        uri << @bbox.to_s
      else
        raise "\n\nFATAL: You must supply EITHER centre coordinates OR a bounding box\n\n"
      end
    
      @paths.map{|p| uri << "#{p}" }
      @markers.map{|m| uri << "#{m}" }

      # warnings
      $stderr.puts "WARNING: generated CloudMade::StaticMap URL is too long for IE: #{__FILE__}:#{__LINE__}" if uri.length > 2048
      
      # caching?
      return cache(uri, format) if CloudMade.cache_dir

      # send cloudmade URI
      return uri
    end

    def cache(uri,format)
      # determine the local filename
      @cached_map = Pathname(CloudMade.cache_dir + "/#{Zlib.crc32(uri).to_i.to_s(16)}.#{format}")
      
      # send cached map URI, if it exists
      return Pathname(CloudMade.cache_path + "/#{Zlib.crc32(uri).to_i.to_s(16)}.#{format}") if @cached_map.file?
        
      # cache the map after the url is sent
      pid = fork do
        require 'net/http'
        require 'uri'
        require 'zlib'

        url = URI.parse(uri)
        Net::HTTP.start(url.host,url.port) { |http|
          res = http.get("#{url.path}?#{url.query}")
          raise 'Error fetching CloudMade map for cache' unless res.code == '200'
          open(@cached_map, "wb") { |file|
            file.write(res.body)
           }
        }
      end
      Process.detach(pid)
      
      return uri
    end

  end

  class Path
    attr_accessor :color, :weight, :opacity, :points

    # @param (see CloudMade::path)
    def initialize(params={})
      @color = params.fetch :color, 'blue'
      @weight = params.fetch :weight, 2
      @opacity = params.fetch :opacity, 0.5
      @points = params.fetch :points, []
    end

    def to_s
      # warnings
      if @points.empty?
        $stderr.puts "WARNING: to_s called on a CloudMade::Path with no points: #{__FILE__}:#{__LINE__}"
        return '' 
      end
      @color.to_s(8) if @color.is_a? Integer
      # output
      "&path=color:#{@color.is_a?(Integer) ? @color.to_s(16) : @color}|weight:#{@weight}|opacity:#{@opacity}|#{@points.compact.map{|ll|ll.join(',')}.join('|')}"
    end

  end

  class Marker
    attr_accessor :url, :size, :opacity, :lat, :lng, :label

    # @param (see CloudMade::marker)
    def initialize(params={})
      @size = params.fetch :size, 'big' # big | small
      @opacity = params.fetch :opacity, 1
      @lat = params.fetch :lat, nil
      @lng = params.fetch :lng, nil
      @lat_offset = params.fetch :lat_offset, -0.002
      @lng_offset = params.fetch :lng_offset, 0.0
      @url = params.fetch :url, nil
      @id = params.fetch :id, nil
      @label = params.fetch(:label,'A').trim[0] # first character only :-(
    end

    def to_s
      # warnings
      unless @lat && @lng
        $stderr.puts "WARNING: to_s called on a CloudMade::Marker with no position: #{__FILE__}:#{__LINE__}" 
        return '' 
      end
      unless @url || @id
        $stderr.puts "WARNING: to_s called on a CloudMade::Marker with neither url nor id: #{__FILE__}:#{__LINE__}"
        return ''
      end

      # output
      uri = "&marker=opacity:#{@opacity}"
      uri << @url ? "|url:#{@url}" : "|size:#{@size}|label:#{@label}"
      uri << "|#{@lat+@lat_offset},#{@lng+@lng_offset}"
    end

  end # Marker

  class BoundingBox
    attr_accessor :top, :left, :bottom, :right, :debug
    
    # @param (see CloudMade::bounding_box)
    def initialize(params)
      return params if params.is_a? CloudMade::BoundingBox # it's already a BoundingBox
      if params.is_a?(String) && params.to_s.split(',').length >= 4
        params = params.to_s.split(',').flatten
      end
      @bottom, @top = [ params[0].to_f, params[2].to_f ].sort
      @left, @right = [ params[1].to_f, params[3].to_f ].sort

      self.pad!(params[4].to_f) if params[4]
      raise "\n\nBounding Box should be either an Array ( [lat0,lng0,lat1,lng1] ) or a comma delimited String ( 'lat0,lng0,lat1,lng1' )\n\n" unless (@top && @left && @bottom && @right)
    end
        
    def width() @right-@left end
    def height() @top-@bottom end

    def pad(*padding)
      padding = scrub(padding)
      top, bottom = [ @top + height * padding[0], @bottom - height * padding[2] ]
      left, right = [ @left - width * padding[1], @right + width * padding[3] ]
      self.class.new(top,right,bottom,left)
    end

    def pad!(*padding)
      padding = scrub(padding)
      @top, @bottom = [ @top + height * padding[0], @bottom - height * padding[2] ]
      @left, @right = [ @left - width * padding[1], @right + width * padding[3] ]
      self
    end
    
    def to_s
      if @debug
        $stderr.puts "DEBUG: CloudMade::BoundingBox debugging active: #{__FILE__}:#{__LINE__}"
        debug_shape = [ [ @top,@left ], [ @bottom,@left ], [ @top,@right ], [ @bottom,@right ] ]
        return "&bbox=" << [@top,@right,@bottom,@left].map{|x|x.to_s}.join(',') << "&path=fill:red|color:green|weight:1|opacity:0.3|#{debug_shape.map{|ll|ll.join(',')}.join('|')}"
      end

      "&bbox=" << [@top,@right,@bottom,@left].map{|x|x.to_s}.join(',')
    end
    
    private
    
    def scrub(padding)
      raise "\n\nCloudMade::BoundingBox requires 1, 2 or 4 padding values (CSS style)\n\n" unless [1,2,4].include? padding.length
      padding * (4 / padding.length) # expand the padding array, css style
    end
  end # BoundingBox
  
end