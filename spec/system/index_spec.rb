# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'system test' do
  it 'displays the serving area for served postcodes known to API' do
    visit root_path
    expect(page).to have_text('Please enter a postcode')
    fill_in 'postcode', with: 'se1 7qd'
    click_button 'Submit'
    expect(page).to have_text('Southwark')
  end

  it 'displays the serving area for served postcodes unknown to API' do
    visit root_path
    expect(page).to have_text('Please enter a postcode')
    fill_in 'postcode', with: 'sh24 1ab'
    click_button 'Submit'
    expect(page).to have_text('Southwark')
  end
end
