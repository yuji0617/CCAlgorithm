# conding: utf-8

require "narray"

class OBJParser
  def initialize(file_name)
    @vertex = []
    @face   = []
    open(file_name).each do |line|
      s = line.split(/\s/)
      if s[0] == "v"
        @vertex << NVector[s[1].to_f, s[2].to_f, s[3].to_f]
      end
      if s[0] == "f"
        @face << [s[1].to_i - 1, s[2].to_i - 1, s[3].to_i - 1]
      end
    end
  end

  attr_accessor :vertex, :face

  def save(file_name)
    open(file_name, "w") do |f|
      @vertex.each do |v|
        f.puts "v #{v[0]} #{v[1]} #{v[2]}"
      end
      @face.each do |v|
        f.puts "f #{v[0] + 1} #{v[1] + 1} #{v[2] + 1}"
      end
    end
  end
end
