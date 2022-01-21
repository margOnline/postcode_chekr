require 'rails_helper'

RSpec.describe 'system test' do
  it 'displays a form to enter a postcode' do
    visit root_path
    expect(page).to have_text('Please enter a postcode')
  end
end