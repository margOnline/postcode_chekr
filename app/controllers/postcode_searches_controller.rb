# frozen_string_literal: true

require 'net/http'
require 'uri'

class PostcodeSearchesController < ApplicationController
  attr_accessor :postcode, :allowed
  
  SERVED_AREAS = {
    lambeth: [],
    southwark: ['sh241aa', 'sh241ab']
  }.freeze
  POSTCODE_API = 'http://postcodes.io/postcodes'

  def create
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
    response = Request.new(postcode).send
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
