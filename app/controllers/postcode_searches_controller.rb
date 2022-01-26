# frozen_string_literal: true
require 'net/http'
require 'uri'

class PostcodeSearchesController < ApplicationController
  ALLOWED_POSTCODES = ['SH24 1AA', 'SH24 1AB']
  SERVED_AREAS = ['Lambeth', 'Southwark']
  POSTCODE_API = 'http://postcodes.io/postcodes'

  def create
    @allowed = false
    # check if submitted postcode is served
    
    # 1. validate and scrub search param
    @pc_to_search = params[:postcode].delete("\s")
    postcodes = ALLOWED_POSTCODES.map do |pc|
      pc.downcase
      pc.delete("\s")
    end  
    
    # 2. is postcode in allowed postcodes?
    ### 2.a yes - return 'allowed'
    ### 2.b. no - make request to postcodes api
    postcodes.include?(@pc_to_search) ? @allowed = true : make_request(@pc_to_search)
    @result = @allowed ? "#{@pc_to_search} is served by #{@lsoa}" : "#{@pc_to_search} is not currently served"
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
    @lsoa = JSON.parse(response.body)['result']['lsoa'].split(" ").first
    @allowed = true if SERVED_AREAS.include?(@lsoa)  
  end

  def handle_error(response)
    @result = 'We cannot process your request at this time, please try again.'
  end
end
