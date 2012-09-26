# coding: utf-8

$:.unshift "./"

require "narray"
require "gsl"

def spin_image(point, normal, around)
  beta = []
  around.each do |x|
    beta << (normal * (x - point)).abs
  end

  alpha = []
  around.each_with_index do |x, i|
    alpha << (x - point).to_gv.norm - beta[i] ** 2
  end

  spin = []
  alpha.each_with_index do |a, i|
    spin << [a, beta[i]]
  end

  spin
end
