#!/usr/bin/env ruby
require 'sinatra/base'
require 'rack/oauth2'
require 'pp'
require './const.rb'

class MyAccessToken
  attr_accessor :identifier, :access_token, :mac_key, :algorithm, :expires_in

  def initialize(identifier, access_token, secret)
    @identifier, @access_token = identifier, access_token
    @mac_key    = secret
    @algorithm  = 'hmac-sha-256'
    @expires_in = 15 * 60 # 15.minutes
  end

  def to_mac_token
    Rack::OAuth2::AccessToken::MAC.new(
      :access_token  => self.access_token,
      :mac_key       => self.mac_key,
      :mac_algorithm => self.algorithm,
      :expires_in    => self.expires_in
    )
  end
end

TOKENS = CLIENTS.map do |c|
  MyAccessToken.new(*c)
end

class MACVerifyServerSampleServer < Sinatra::Base

  configure do
    use Rack::OAuth2::Server::Resource::MAC, 'mac verify server' do |req, res|
      token = TOKENS.find{|x| x.access_token == req.access_token} || req.invalid_token!("Invalid access token")
      token.to_mac_token.verify!(req)
      token.identifier
    end

    set :server, :webrick
    set :port, 4001
  end

  def client_name
    request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
  end

  get '/' do
    content_type :text
    "Hello #{client_name}.\n#{env.pretty_inspect}"
  end

  run! if $0 == __FILE__
end
