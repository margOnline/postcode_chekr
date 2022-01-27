# frozen_string_literal: true

require 'net/http'
require 'uri'
# require '/services/PostcodeRequest'

class PostcodeSearchesController < ApplicationController
  attr_accessor :postcode, :allowed
  
  SERVED_AREAS = {
    lambeth: [],
    southwark: ['sh241aa', 'sh241ab']
  }.freeze

  def create
    @postcode = parse_postcode(params[:postcode])
    valid_postcode? ? find_lsoa : response_text(:not_valid, params[:postcode])
  end

  private
  def parse_postcode(postcode)
    postcode.downcase.delete("\s")
  end

  def valid_postcode?
    UKPostcode.parse(@postcode).full_valid?
  end

  def find_lsoa
    if served_but_unknown?
      @allowed = true
      response_text(:served, params[:postcode], served_to_s)
    else 
      make_request(@postcode)
    end

    if @allowed
      @result ||= response_text(:served, params[:postcode], @lsoa)
    else
      response_text(:not_served, params[:postcode])
    end
  end

  def served_but_unknown?
    !!SERVED_AREAS.detect {|k,v| v.include?(@postcode) }
  end

  def served_to_s
    SERVED_AREAS.detect {|k,v| v.include?(@postcode) }.first.to_s.capitalize
  end

  def make_request(postcode)
    response = PostcodeRequest.new(postcode).send
    response.code == '200' ? handle_success(response) : handle_error(response)
  end

  def handle_success(response)
    @lsoa = JSON.parse(response.body)['result']['lsoa'].split(' ').first
    if SERVED_AREAS.keys.map{|key| key.to_s}.include?(@lsoa.downcase)
      @allowed = true
    end
  end

  def handle_error(_response)
    @result = response_text[:failed_request]
  end

  def response_text(message, postcode=nil, lsoa=nil)
    text = {
      served: "#{postcode} is served by #{lsoa}",
      not_served: "#{postcode} is not currently served",
      failed_request: "We cannot process your request at this time",
      not_valid: "#{postcode} is not a valid UK postcode"
    }
    @result = text[message]
  end
end
