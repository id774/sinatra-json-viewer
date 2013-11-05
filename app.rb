#!/opt/ruby/current/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'

class SinatraJsonViewer < Sinatra::Base
  # require './helpers/render_partial'

  configure :development do
    register Sinatra::Reloader
  end

  def open_file(file = 'json.txt', &block)
    open(file) do |file|
      file.each_line do |line|
        block.call(line)
      end
    end
  end

  def open_json(file = 'json.txt')
    array = []
    hash  = {}

    split_line = lambda {|line|
      hash['key'], hash['tag'], hash['value'] = line.strip.split("\t")
      array << hash
    }

    open_file(file, &split_line)
    return array
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end

    def paginate
      will_paginate @contents, :renderer => BootstrapPaginationRenderer
    end
  end

  def initialize(app = nil, params = {})
    super(app)
  end

  get '/' do
    @json = open_json("json.txt")
    haml :index
  end

  run! if app_file == $0
end
