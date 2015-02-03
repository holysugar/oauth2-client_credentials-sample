#!/usr/bin/env ruby
require 'rack/oauth2'
require 'pp'
require './const.rb'

# see https://gist.github.com/nov/933885

def main(option = nil)
  c = CLIENTS.find{|c| c[0] == 'foo' } || raise('missing foo')

  token = Rack::OAuth2::AccessToken::Bearer.new(
    :access_token => (option == :badtoken) ? "badtoken" : c[1],
  )
  begin
    res = token.get "http://localhost:4000/"
    pp res.headers
    puts res.body
  rescue => e
    p e.response.headers[:www_authenticate]
  end
end

puts '-------------------'
main
puts '-------------------'
main(:badtoken)
