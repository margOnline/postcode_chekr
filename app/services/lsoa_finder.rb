# frozen_string_literal: true

class LsoaFinder
  attr_accessor :postcode

  SERVED_AREAS = {
    lambeth: [],
    southwark: ['sh241aa', 'sh241ab']
  }.freeze

  def initialize(original_pc, parsed_pc)
    @original_pc = original_pc
    @parsed_pc = parsed_pc
  end

  def find
    if served_but_unknown?
      formatted_response(:served, served_to_s)
    else 
      make_request
    end
  end

  def formatted_response(message, lsoa=nil)
    text = {
      served: "#{@original_pc} is served by #{lsoa}",
      not_served: "#{@original_pc} is not currently served",
      failed_request: "We cannot process your request at this time",
      not_valid: "#{@original_pc} is not a valid UK postcode"
    }
    text[message]
  end

  private
  def served_but_unknown?
    !!SERVED_AREAS.detect {|k,v| v.include?(@parsed_pc) }
  end

  def served_to_s
    SERVED_AREAS.detect {|k,v| v.include?(@parsed_pc) }.first.to_s.capitalize
  end

  def make_request
    response = PostcodeRequest.new(@parsed_pc).send
    response.code == '200' ? handle_success(response) : handle_error(response)
  end

  def handle_success(response)
    lsoa = JSON.parse(response.body)['result']['lsoa'].split(' ').first

    if SERVED_AREAS.keys.map{|key| key.to_s}.include?(lsoa.downcase)
      formatted_response(:served, lsoa)
    else
      formatted_response(:not_served)
    end
  end

  def handle_error
    formatted_response(:failed_request)
  end
end
