# coding: utf-8

$:.unshift "./"

require "opengl"
require "3d_geometry"

include Gl, Glu, Glut
class OBJViewer
  LIGHT_POSITION0 = [1.0, 1.0, 1.0, 0.0]
  LIGHT_POSITION1 = [-1.0, -1.0, -1.0, 0.0]
  LIGHT_COLOR     = [1.0, 1.0, 1.0]

  def reshape(w, h)
    glViewport(0,0,w,h)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(-1.0, 1.0, -1.0, 1.0, 0.0, 2.0)
  end

  def draw_axis
    if @axis_show
      glDisable(GL_LIGHTING)

      # X軸
      glColor(1.0, 0.0, 0.0)
      glBegin(GL_LINES)
      glVertex3d(-1.0, 0.0, 0.0)
      glVertex3d(1.0, 0.0, 0.0)
      glEnd

      glBegin(GL_LINES)
      glVertex3d(0.9, 0.1, 0.0)
      glVertex3d(0.9, -0.1, 0.0)
      glEnd

      # Y軸
      glColor(0.0, 1.0, 0.0)
      glBegin(GL_LINES)
      glVertex3d(0.0, -1.0, 0.0)
      glVertex3d(0.0, 1.0, 0.0)
      glEnd

      glBegin(GL_LINES)
      glVertex3d(0.0, 0.9, 0.1)
      glVertex3d(0.0, 0.9, -0.1)
      glEnd

      # Z軸
      glColor(0.0, 0.0, 1.0)
      glBegin(GL_LINES)
      glVertex3d(0.0, 0.0, -1.0)
      glVertex3d(0.0, 0.0, 1.0)
      glEnd

      glBegin(GL_LINES)
      glVertex3d(-0.1, 0.0, 0.9)
      glVertex3d(0.1, 0.0, 0.9)
      glEnd

      glEnable(GL_LIGHTING)
    end
  end

  def display
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    gluLookAt(0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)

    glLightfv(GL_LIGHT0, GL_POSITION, LIGHT_POSITION0)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, LIGHT_COLOR)
    glLightfv(GL_LIGHT1, GL_POSITION, LIGHT_POSITION1)
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LIGHT_COLOR)

    glClearColor(0.0, 0.0, 0.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glTranslate(@transX, @transY, @transZ)

    glRotate(@rotX, 1, 0, 0)
    glRotate(@rotY, 0, 1, 0)

    glScale(@scale, @scale, @scale)

    draw_axis
    draw_obj

    glutSwapBuffers()
  end

  def normal_vec(vertex)
    v1    = vertex[1] - vertex[0]
    v2    = vertex[2] - vertex[0]
    cross = NVector[v1[1] * v2[2] - v1[2] * v2[1],
                    v1[2] * v2[0] - v1[0] * v2[2],
                    v1[0] * v2[1] - v1[1] * v2[0]]

    if cross.to_gv.norm == 0
      false
    else
      cross / cross.to_gv.norm
    end
  end

  def mouse(button, state, x, y)
    if button == GLUT_LEFT_BUTTON && state == GLUT_DOWN then
      @start_x  = x
      @start_y  = y
      @drag_flg = true
    elsif state == GLUT_UP then
      @drag_flg = false
    end
  end

  def text(string, font, x, y, z, r, g, b)
    glDisable(GL_TEXTURE_2D)
    glColor3f(r, g, b)
    glRasterPos3f(x, y, z)
    string.each_byte do |s|
      glutBitmapCharacter(font, s)
    end
  end

  def motion(x, y)
    if @drag_flg then
      dx    = x - @start_x
      dy    = y - @start_y

      @rotY += dx
      @rotY = @rotY % 360

      @rotX += dy
      @rotX = @rotX % 360
    end
    @start_x = x
    @start_y = y
    glutPostRedisplay()
  end

  def key(key, x, y)
    case key
    when ?a
      if @axis_show
        @axis_show = false
      else
        @axis_show = true
      end
    when ?b
      @scale += 0.1
    when ?c
      if @coord_show
        @coord_show = false
      else
        @coord_show = true
      end
    when ?s
      @scale -= 0.1
    when ?p
      if @polygon_show
        @polygon_show = false
      else
        @polygon_show = true
      end
    when ?j
      if @joint_show
        @joint_show = false
      else
        @joint_show = true
      end
    when ?\e
      exit 0
    end
    glutPostRedisplay
  end

  def special(key, x, y)
    case key
    when GLUT_KEY_LEFT
      @transX += 0.1
    when GLUT_KEY_DOWN
      @transY -= 0.1
    when GLUT_KEY_UP
      @transY += 0.1
    when GLUT_KEY_RIGHT
      @transX -= 0.1
    end
    glutPostRedisplay
  end

  def draw_obj
    # OBJファイルを描画
    if @polygon_show

      # 各面ごとに
      @face.each do |f|
        vertex = []
        f.each do |v_id|
          vertex << @vertex[v_id] / @view_scale
        end
        glNormal(normal_vec(vertex))

        glBegin(GL_POLYGON)
        glVertex3d(*vertex[0])
        glVertex3d(*vertex[1])
        glVertex3d(*vertex[2])
        glEnd
      end

    end
  end

  def initialize(vertex, face, view_scale)
    @vertex       = vertex
    @face         = face
    @view_scale   = view_scale
    @start_x      = 0
    @start_y      = 0
    @rotY         = 0
    @rotX         = 0
    @scale        = 1.0
    @transX       = 0.0
    @transY       = 0.0
    @transZ       = 0.0

    @axis_show    = false
    @polygon_show = true
    @joint_show   = true
    @drag_flg     = false
    @coord_show   = true

    glutInitWindowPosition(100, 100)
    glutInitWindowSize(300,300)
    glutInit
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
    glutCreateWindow("Ruby de OpenGL")

    glEnable(GL_DEPTH_TEST)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_LIGHT1)

    glFrontFace(GL_CW)
    glEnable(GL_AUTO_NORMAL)
    glEnable(GL_NORMALIZE)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LESS)

    glShadeModel(GL_SMOOTH)

    glutReshapeFunc(method(:reshape).to_proc)
    glutDisplayFunc(method(:display).to_proc)
    glutMouseFunc(method(:mouse).to_proc)
    glutMotionFunc(method(:motion).to_proc)
    glutKeyboardFunc(method(:key).to_proc)
    glutSpecialFunc(method(:special).to_proc)
  end

  def start
    glutMainLoop
  end
end
