# coding: utf-8

$:.unshift "./"

require "3d_geometry"

class PointNormal
  def initialize(vertex, face)
    @vertex = vertex
    @face = face

    calc_related_face
    calc_face_normal
    calc_point_normal
  end

  attr_accessor :around, :point_normal

  def calc_related_face
    @related_face = []
    @related_vertex = []
    @vertex.size.times do |v_id|
      relate = []
      vertex = []
      @face.each_with_index do |f, f_id|
        if f[0] == v_id || f[1] == v_id || f[2] == v_id
          relate << f_id
          vertex += [f[0], f[1], f[2]]
        end
      end
      vertex.uniq!
      vertex.delete(v_id)
      @related_vertex << vertex
      @related_face << relate
    end

    @around = []
    @related_vertex.each do |r|
      a = []
      r.each do |v|
        a << @vertex[v]
      end
      @around << a
    end
  end

  def calc_face_normal
    @face_normal = []
    @related_face.each do |rf|
      normal = []
      rf.each do |f_id|
        f = @face[f_id]
        v1 = @vertex[f[1]] - @vertex[f[0]]
        v2 = @vertex[f[2]] - @vertex[f[0]]
        norm = cross(v1, v2)
        normal << norm
      end
      @face_normal << normal
    end
  end

  def calc_point_normal
    @point_normal = []
    @face_normal.each do |fn|
      normal = NVector.float(3)
      fn.each do |n|
        normal += n
      end
      normal /= normal.to_gv.norm
      @point_normal << normal
    end
  end
end
