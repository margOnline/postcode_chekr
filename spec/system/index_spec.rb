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

  it 'displays unserved for postcodes not served' do
    visit root_path
    expect(page).to have_text('Please enter a postcode')
    fill_in 'postcode', with: 'SW19 5AE'
    click_button 'Submit'
    expect(page).to have_text('SW19 5AE is not currently served')
  end

  it 'displays invalid for invalid UK postcodes' do
    visit root_path
    expect(page).to have_text('Please enter a postcode')
    fill_in 'postcode', with: 'SWAE'
    click_button 'Submit'
    expect(page).to have_text('SWAE is not a valid UK postcode')
  end
end
