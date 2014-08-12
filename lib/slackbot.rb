# encoding: utf-8

require 'set'
require 'sinatra'

module SlackBot

  # fields for the slash command API
  PARAMETERS = Set.new [
    'token',
    'team_id',
    'channel_id',
    'channel_name',
    'user_id',
    'user_name',
    'command',
    'text'
  ]

  class Command
    attr_reader :name

    def initialize(name, token, proc)
      @name, @token, @proc = name, token, proc
      @name.freeze
      @token.freeze
      @proc.freeze
    end

    def call(params)
      if @token.nil? || @token == params[:token]
        @proc.call(params)
      else
        throw :invalid, "Token não-autorizado, sai daqui enxerido!"
      end
    end
  end

  class CommandGroup
    attr_reader :path, :commands
    def initialize(path)
      @path = path
      @commands = {}
    end

    def command(name, options = {}, &proc)
      @commands[name] = Command.new(name, options[:token], proc)
    end

    def finish
      @path.freeze
      @commands.freeze
    end

    def call(params)
      if @commands.has_key?(params[:command])
        @commands[params[:command]].call(params)
      else
        throw :invalid, "Comando não-existente, cuidado inocente!"
      end
    end
  end

  module Main
    module_function

    # Create a command group for a given path
    def commands_for(path, &block)
      cmd_group = CommandGroup.new(path)

      cmd_group.instance_eval(&block)
      cmd_group.finish

      get path do
        puts "Request parameters: #{params.inspect}"
        unless validate(params)
          "Parâmetros invalidos, sai daqui ráquio!"
        else
          catch(:invalid) do
            cmd_group.call(params)
          end
        end
      end

      Application.groups[path] = cmd_group
    end

    private

    # We use this to crash and burn when fed unwanted/missing parameters
    def validate(params)
      params.keys.all? do |param|
        PARAMETERS.member? param
      end
    end

  end

  module Application
    @@groups = {}
    @@start = false

    def self.groups
      @@groups
    end

    def self.reload
      load "commands.rb"

      # log routes
      puts "Logging registered routes..."
      Sinatra::Application.routes.each do |key, value|
        puts "#{key}"
        value.each do |route|
          puts "Route pattern: #{route[0]}"
        end
      end

      puts '-' * 10

      # log commands
      puts "Logging registered commands..."
      @@groups.each do |key, value|
        puts "Group: '#{key}', commands:"
        value.commands.each_key do |comm|
          puts "#{comm}"
        end
      end
    end

    def self.start
      self.reload unless @@start
      @@start = true
    end
  end

end

include SlackBot::Main
