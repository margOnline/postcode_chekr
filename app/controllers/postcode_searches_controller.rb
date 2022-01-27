# frozen_string_literal: true

require 'net/http'
require 'uri'

class PostcodeSearchesController < ApplicationController
  SERVED_AREAS = {
    lambeth: [],
    southwark: ['sh241aa', 'sh241ab']
  }.freeze
  # ALLOWED_POSTCODES = .freeze
  # SERVED_AREAS = %w[Lambeth Southwark].freeze
  POSTCODE_API = 'http://postcodes.io/postcodes'

  def create
    @allowed = false
    @result = nil

    @postcode = params[:postcode].downcase.delete("\s")
    outside_pc = SERVED_AREAS.detect {|k,v| v.include?(@postcode) }

    if outside_pc
      @allowed = true
      @result = "#{params[:postcode]} is served by #{outside_pc.first.to_s.capitalize}"
    else 
      make_request(@postcode)
    end

    if @allowed
      @result ||= "#{params[:postcode]} is served by #{@lsoa}"
    else
      @result = "#{params[:postcode]} is not currently served"
    end
  end

  private

  def make_request(postcode)
    uri = URI.parse("#{POSTCODE_API}/#{postcode}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.code == '200' ? handle_success(response) : handle_error(response)
  end

  def handle_success(response)
    @lsoa = JSON.parse(response.body)['result']['lsoa'].split(' ').first
    if SERVED_AREAS.keys.map{|key| key.to_s}.include?(@lsoa.downcase)
      @allowed = true
    end
  end

  def handle_error(_response)
    @result = 'We cannot process your request at this time, please try again.'
  end
end
