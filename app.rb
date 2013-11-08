#!/opt/ruby/current/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'json'

class SinatraJsonViewer < Sinatra::Base
  # require './helpers/render_partial'


  def open_json(file = 'json.txt')
    array = []

    split_line = lambda {|line|
      hash  = {}
      hash['key'], hash['tag'], json = line.strip.split("\t")
      begin
        hash['value'] = JSON.parse(json)
      rescue JSON::ParserError
        hash['value'] = json
      end
      array << hash
    }

    def open_file(file = 'json.txt', &block)
      open(file) do |file|
        file.each_line do |line|
          block.call(line)
        end
      end
    end

    open_file(file, &split_line) if File.exist?(file) if /\.txt\Z/ =~ file
    return array
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  def initialize(app = nil, params = {})
    super(app)
    @json = []
    @root = Sinatra::Application.environment == :production ? '/sinatra-json-viewer/' : '/'
  end

  def logger
    env['app.logger'] || env['rack.logger']
  end

  get '/' do
    @files = Dir::entries('.').sort
    haml :index
  end

  get '/:file_name' do
    @json = open_json(@params[:file_name])
    redirect '/' if @json.length == 0
    # haml @params[:file_name].to_sym
    haml :json
  end

  run! if app_file == $0
end
