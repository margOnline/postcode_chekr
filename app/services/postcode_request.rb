# frozen_string_literal: true

require 'net/http'
require 'uri'

class PostcodeRequest
  attr_accessor :postcode

  POSTCODE_API = ENV.fetch('POSTCODE_API')

  def initialize(postcode)
    @postcode = postcode
  end

  def send
    uri = URI.parse("#{POSTCODE_API}/#{postcode}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end
end
