# frozen_string_literal: true

begin
  require "amazing_print"
  AmazingPrint.pry!
rescue LoadError
  puts "Install amazing_print first!"
end
