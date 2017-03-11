import parameters as params
from random import randrange, random
add_library('serial')

serial_port = '/dev/ttyUSB0'
serial_reader = Serial(this, serial_port, 9600)

class Game:
    
    def __init__(self):
        self.score = {'left': 0,
                      'right': 0}
        self.paddle = {'left': 0,
                       'right': 0}
        self.paddle_target = {'left': params.window_height / 2 - params.paddle_height / 2,
                              'right': params.window_height / 2 - params.paddle_height / 2}
        self.ball = {}
        self.reset_ball()
        
    def frame(self):
        self.position_paddles()
        self.position_ball()
        if not self.check_score():
            self.draw()
   
    def position_paddles(self):
        # positioning
        self.paddle['left'] += (self.paddle_target['left'] - self.paddle['left']) / params.movement_dampening
        self.paddle_target['right'] = mouseY
        self.paddle['right'] += (self.paddle_target['right'] - self.paddle['right']) / params.movement_dampening
      
    def position_ball(self):
        # move ball
        self.ball['left'] += self.ball['velocity'][0]
        self.ball['top'] += self.ball['velocity'][1]
        # collide ball with paddles
        if self.ball['left'] <= params.paddle_width and\
            self.ball['top'] + params.ball_size >= self.paddle['left'] and self.ball['top'] <= self.paddle['left'] + params.paddle_height:
                self.ball['velocity'][0] *= -1.2
                if self.ball['left'] <= params.paddle_width:
                    self.ball['left'] = params.paddle_width + 1
        elif self.ball['left'] + params.ball_size >= params.window_width - params.paddle_width and\
           self.ball['top'] + params.ball_size >= self.paddle['right'] and self.ball['top'] <= self.paddle['right'] + params.paddle_height:
            self.ball['velocity'][0] *= -1.2
            if self.ball['left'] + params.ball_size >= params.window_width - params.paddle_width:
                    self.ball['left'] = params.window_width - params.paddle_width - params.ball_size - 1
        # collide ball with edges
        if self.ball['top'] + params.ball_size >= params.window_height or\
             self.ball['top'] <= 0:
            self.ball['velocity'][1] *= -1
        
    def check_score(self):
        if self.ball['left'] + params.ball_size > params.window_width - params.paddle_width:
            self.score['left'] += 1
            delay(200)
            self.reset_ball()
        elif self.ball['left'] < params.paddle_width:
            self.score['right'] += 1
            delay(200)
            self.reset_ball()
        if self.score['left'] == params.score_target:
            noLoop()
            background(0, 255, 0)
            return True
        elif self.score['right'] == params.score_target:
            noLoop()
            background(0, 255, 0)
            return True
        return False
        
    def reset_ball(self):
        self.ball['left'] = params.window_width / 2 - params.ball_size / 2
        self.ball['top'] = params.window_height / 2 - params.paddle_height / 2
        self.ball['velocity'] = [randrange(*params.ball_velocity_range) * -1 if random() < 0.5 else 1, 
                                 randrange(*params.ball_velocity_range) * -1 if random() < 0.5 else 1]
        
    def draw(self):
        fill(params.foreground_color)
        # ball
        rect(self.ball['left'], self.ball['top'], params.ball_size, params.ball_size)
        # paddles
        rect(0, self.paddle['left'], params.paddle_width, params.paddle_height)
        rect(params.window_width - params.paddle_width, self.paddle['right'], params.paddle_width, params.paddle_height)
        # score
        textAlign(CENTER, TOP);
        textSize(18);
        text('%i : %i' % (self.score['left'], self.score['right']), params.window_width / 2, 15)

def input():
    if serial_reader.available() > 0:
        try:
            raw_data = serial_reader.readStringUntil(10);
            if raw_data is not None:
                left_position, right_position = raw_data.split()
                left_position = correct_input(int(left_position))
                right_position = correct_input(int(right_position))
                g.paddle_target['left'] = left_position
                g.paddle_target['right'] = right_position
        except:
            pass

def correct_input(value):
    if value < params.position_start_offset:
        value = params.window_height - params.paddle_height + params.paddle_width
    elif value > params.position_start_offset + params.position_sensitivity_range:
        value = 0
    else:
        value = value - params.position_start_offset
        value = (params.window_height - params.paddle_height) - \
                (params.window_height - params.paddle_height) * value / params.position_sensitivity_range
    return value

def setup():
    global logo, g
    logo = loadImage('pfe.png')
    g = Game()
    frameRate(params.framerate)
    size(params.window_width, params.window_height)
    noCursor()
    fullScreen()
    while not serial_reader.available() > 0:
        pass
    
def draw():
    background(params.background_color)
    image(logo, params.window_width / 2 - 150, params.window_height / 2 - 150, 300, 300);
    input()
    g.frame()