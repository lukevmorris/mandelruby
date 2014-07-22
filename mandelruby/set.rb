module Mandelruby

  class Set

    def initialize(color = false)
      @output = ""
      # maximum iterations the recursive loop tries before bailing out and
      # considers a point in the set
      @dwell = 100
      @window = Window.new
      #how many iterations before output uses a different character for bail levels
      @character_resolution = 2
      # chooses a number between 15 and 240 for the starting color
      @bg_color = rand(15..240)
      @fg_color = rand(15..240)
      # only display color output if --color option passed
      @color = color
    end

    def draw
      each_pixel do |x,y|
        @output += "\n" if new_row?
        mandelbrot(Complex(x,y))
        @output += character_for_iteration
      end
      @output
    end

    private

    def new_row?
      @new_row
    end

    def each_pixel
      @window.rows.each do |y|
        @window.columns.each do |x|
          yield x,y
          @new_row = false
        end
        @new_row = true
      end
    end

    def color_for_iteration
      bg_color + fg_color
    end

    def bg_color
      ["\e[48;5;", (@bg_color + color_index), "m"].join
    end

    def fg_color
      ["\e[38;5;", (@fg_color + color_index), "m"].join
    end

    def reset_color
      "\e[0m"
    end

    def color_index
      char_list.index(char_list[@iteration/@character_resolution]) || 8
    end

    def character_for_iteration
      return " " if @iteration == @dwell
      
      if @color
        color_for_iteration + (char_list[@iteration/@character_resolution] || ".") + reset_color
      else
        char_list[@iteration/@character_resolution] || "."
      end
    end

    def mandelbrot(c)
      z = 0
      @iteration = 0
      @dwell.times { z = z**2 + c; @iteration += 1; break if (z.abs >= 2)}
    end

    def char_list
      @char_list ||= ["X","O","#","*","o","%","=","-","."]
    end

  end

  class Window
    attr_reader :top_left, :bottom_right, :resolution
    def initialize
      # display window from top-left corner to bottom-right corner of complex plane
      @top_left = Pixel.new(-2.5, 1.0)
      @bottom_right = Pixel.new(1.5, -1.0)

      #resolution of characters in output
      @resolution = Pixel.new(80.0, 40.0)
    end
    
    def rows
      top_left.y.step(bottom_right.y, y_increment).to_a
    end

    def columns
      top_left.x.step(bottom_right.x, x_increment).to_a
    end

    private

    def x_increment
      (bottom_right.x - top_left.x) / resolution.x
    end

    def y_increment
      (bottom_right.y - top_left.y) / resolution.y
    end

  end

  class Pixel
    attr_reader :x, :y
    def initialize(x, y)
      @x, @y = x, y
    end
  end

end
