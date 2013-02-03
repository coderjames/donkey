#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

LEFT_LANE_CENTER = 445
RIGHT_LANE_CENTER = 555

PLAYER_START_Y = 750
PLAYER_END_Y = 0

DONKEY_START_X = LEFT_LANE_CENTER
DONKEY_START_Y = 0
DONKEY_END_Y = 750

class Game < Chingu::Window
  def initialize
    super(1024,768)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits game on Escape

    # create the road background image. (Do this first so that it is rendered first)
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0, :rotation_center => :top_left)
    @parallax << { :image => "road.png", :repeat_x => false, :repeat_y => true}

    @player = Player.create(:x => LEFT_LANE_CENTER, :y => PLAYER_START_Y, :image => Image["racecar.png"])
    @player.input = { :space => :switch_sides }

    @player_score = 0
    @player_score_text = Chingu::Text.create("Player Score #{@player_score}", :x => 115, :y => 50, :factor_x => 3.0, :color => ::Gosu::Color::BLACK)

    @donkey = Donkey.create(:x => DONKEY_START_X, :y => DONKEY_START_Y, :image => Image["donkey.png"], :factor => 2.0)
    @donkey_score = 0
    @donkey_score_text = Chingu::Text.create("Donkey Score #{@donkey_score}", :x => 655, :y => 50, :factor_x => 3.0, :color => ::Gosu::Color::BLACK)
  end


  def update
    super
    self.caption = "FPS: #{self.fps} milliseconds_since_last_tick: #{self.milliseconds_since_last_tick}"

    @parallax.camera_y -= 1; # scrolls the road

    if @player.y <= PLAYER_END_Y then
      @player_score += 1
      @player.reset
      @donkey.pick_lane
      @player_score_text.text = "Player Score #{@player_score}"

      @player.speed = [@player.speed + 1, 5].min
    end

    @donkey.reset if @donkey.y >= DONKEY_END_Y

    Player.each_collision(Donkey) do |plr, dnk|
      @donkey_score += 1
      @donkey_score_text.text = "Donkey Score #{@donkey_score}"

      @donkey.reset
      @player.reset
    end
  end
end

class Player < Chingu::GameObject
  trait :bounding_box
  traits :collision_detection

  attr_accessor :speed;
  attr_reader :y;

  def reset
    @x = LEFT_LANE_CENTER
    @y = PLAYER_START_Y
  end

  def initialize(parent_window)
    super(parent_window)
    @speed = 1;
    cache_bounding_box
  end

  def switch_sides
    if @x == LEFT_LANE_CENTER then
      @x = RIGHT_LANE_CENTER
    else
      @x = LEFT_LANE_CENTER
    end
  end

  def move_up
    @y -= @speed
  end

  def update
    move_up
  end
end

class Donkey < Chingu::GameObject
  trait :bounding_box
  traits :collision_detection

  attr_reader :speed;
  attr_reader :y;

  def initialize(parent_window)
    super(parent_window)
    pick_lane
    @speed = 1;
    cache_bounding_box
  end

  def update
    @y += @speed
  end

  def reset
    pick_lane
    @y = DONKEY_START_Y
  end

  def pick_lane
    if rand(0..1) == 0 then
      @x = LEFT_LANE_CENTER + 3
    else
      @x = RIGHT_LANE_CENTER - 3
    end
  end
end

Game.new.show