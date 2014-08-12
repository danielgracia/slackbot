# encoding: utf-8

# commands
commands_for '/bot' do

  command '/hi' do |params|
    "Olá querido #{params[:user_name]}!"
  end

  command '/eval' do |params|
    begin 
      "Resultado: " + eval(params[:text]).to_s
    rescue Exception => e
      "Comando inválido!\n\"#{e}\""
    end
  end
  
end

# home
get '/' do
  '''
    <h1> SlackBot </h1>
    Go away.
  '''
end
