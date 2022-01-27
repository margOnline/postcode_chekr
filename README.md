# README

PostcodeChekr
=============

A simple web application to determine which service area a given postcode is within.

Technical
---------
* Rails 7 app
* Testing with rspec

Standard setup
--------------

1.  In Terminal, go to your projects directory and clone the project:

      git clone git@github.com:margOnline/postcode_chekr.git

2.  Install gem dependencies:

      bundle install

3.  Run tests to make sure they pass with your environment:

      rspec spec

4.  Run the app! Boot your web server of choice or use the rails default

    `rails server`

* Next Steps
  
  * Improve tests
  * Better solution for storing served areas and allowed postcodes 
    e.g. consider use of a d/b
  * Better solution for how the response is formatted and delivered
