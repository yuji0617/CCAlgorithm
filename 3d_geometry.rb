# coding: utf-8

require "narray"
require "gsl"

include Math

def rotate(x, y, z)
  rx = NMatrix[[1.0, 0.0, 0.0],
               [0.0, cos(x), -sin(x)],
               [0.0, sin(x), cos(x)]]
  ry = NMatrix[[cos(y), 0.0, sin(y)],
               [0.0, 1.0, 0.0],
               [-sin(y), 0.0, cos(y)]]
  rz = NMatrix[[cos(z), -sin(z), 0.0],
               [sin(z), cos(z), 0.0],
               [0.0, 0.0, 1.0]]

  rz * ry * rx
end

def quaternion(vec, theta)
  a11 = vec[0] * vec[0] * (1.0 - cos(theta)) + cos(theta)
  a12 = vec[0] * vec[1] * (1.0 - cos(theta)) - vec[2] * sin(theta)
  a13 = vec[0] * vec[2] * (1.0 - cos(theta)) + vec[1] * sin(theta)
  a21 = vec[0] * vec[1] * (1.0 - cos(theta)) + vec[2] * sin(theta)
  a22 = vec[1] * vec[1] * (1.0 - cos(theta)) + cos(theta)
  a23 = vec[1] * vec[2] * (1.0 - cos(theta)) - vec[0] * sin(theta)
  a31 = vec[0] * vec[2] * (1.0 - cos(theta)) - vec[1] * sin(theta)
  a32 = vec[1] * vec[2] * (1.0 - cos(theta)) + vec[0] * sin(theta)
  a33 = vec[2] * vec[2] * (1.0 - cos(theta)) + cos(theta)

  NMatrix[[a11, a12, a13], [a21, a22, a23], [a31, a32, a33]]
end

def homogeneous(rot, trans)
  homo             = NMatrix.float(4, 4)
  homo[0..2, 0..2] = rot
  homo[3, 0..2]    = trans
  homo[3, 3]       = 1.0
  homo
end

def cross(v1, v2)
  a1  = v1[1] * v2[2] - v1[2] * v2[1]
  a2  = v1[2] * v2[0] - v1[0] * v2[2]
  a3  = v1[0] * v2[1] - v1[1] * v2[0]
  vec = NVector[a1, a2, a3]
  vec /= vec.to_gv.norm
end

def calc_angle(v1, v2)
  inner = v1 * v2
  inner = inner / v1.to_gv.norm / v2.to_gv.norm
  inner = 2.0 - inner if inner > 1.0
  inner = -2.0 - inner if inner < -1.0

  acos(inner)
end
