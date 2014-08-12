# encoding: utf-8

# gems
require 'sinatra'

# files
require './lib/slackbot.rb'

class Hash
  def coerce(int)
    [int, 0]
  end
end

SlackBot::Application.start


