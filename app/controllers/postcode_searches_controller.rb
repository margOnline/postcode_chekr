# frozen_string_literal: true

class PostcodeSearchesController < ApplicationController
  attr_accessor :postcode, :allowed

  def create
    @parsed_pc = parse_postcode(params[:postcode])
    @original_pc = params[:postcode]
    if valid_postcode?
      find_lsoa
    else
      @result = LsoaFinder.new(
        @original_pc, @parsed_pc
      ).formatted_response(:not_valid)
    end
  end

  private

  def parse_postcode(postcode)
    postcode.downcase.delete("\s")
  end

  def valid_postcode?
    UKPostcode.parse(@parsed_pc).full_valid?
  end

  def find_lsoa
    @result = LsoaFinder.new(@original_pc, @parsed_pc).find
  end
end
