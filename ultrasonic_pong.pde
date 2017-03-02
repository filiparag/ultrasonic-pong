import processing.serial.*;

int window_width = 1366,
    window_height = 768;
int stick_width = 20,
    stick_length = 100;

class Game {
  private int score_left;
  private int score_right;
  private Ball ball;
  private Stick right_stick;
  private Stick left_stick;
  private int score_target;
  public Game(int score) {
    this.left_stick = new Stick('L');
    this.right_stick = new Stick('R');
    this.ball = new Ball(this);
    this.score_left = 0;
    this.score_right = 0;
    this.score_target = score;
  }
  public void Draw() {
    fill(64);
    rect((window_width / 2) - 5, 0, 10, window_height);
    this.left_stick.Draw();
    this.right_stick.Draw();
    this.Score();
    this.ball.Draw();
  }
  private void Score() {
    fill(255);
    textAlign(CENTER, TOP);
    textSize(30);
    text(this.score_left + "  " + this.score_right, window_width / 2, 0);
    if (this.score_right >= this.score_target || this.score_left >= this.score_target) {
      this.score_right = 0;
      this.score_left = 0;
      noLoop();
    }
  }
  public void StickPosition(int l, int r) {
     this.left_stick.SetPosition(l);
     this.right_stick.SetPosition(r);
  }
};

class Stick {
  private int x;
  private int y;
  private int y_target;
  private int width = stick_width;
  private int height = stick_length;
  private char position;
  public Stick(char pos) {
    if (pos == 'R')
      this.x = window_width - this.width;
    else
      this.x = 0;
    this.y_target = (window_height - this.height) / 2;
    this.y = y_target;
    this.position = pos;
  }
  public void Draw() {
    this.y = this.y + (this.y_target - this.y) / 10;
    fill(255);
    rect(this.x, this.y, this.width, this.height);
  }
  public boolean Collision(int x_pos, int y_pos, int size) {
    if (this.position == 'R')
      return (x_pos > this.x - this.width / 2 &&
              x_pos + size / 2 < window_width &&
              y_pos >= this.y &&
              y_pos - size / 2 <= this.y + this.height);
    else
      return (x_pos - size / 2 < this.x + this.width &&
              x_pos - size / 2 > 0 &&
              y_pos - size / 2 >= this.y &&
              y_pos + size / 2 <= this.y + this.height);
  }
  public void SetPosition(int pos) {
    this.y_target = pos;
  }
};

class Ball {
  private int size = 20;
  private int x;
  private int y;
  private int velocity_x;
  private int velocity_y;
  private Game game;
  public Ball(Game g) {
    this.game = g;
    Reset();
  };
  public void Reset() {
    this.x = window_width / 2;
    this.y = window_height / 2;
    this.velocity_x = int(random(10)) - 5;
    this.velocity_y = int(random(10)) - 5;
    if (this.velocity_x < 2 && this.velocity_x > -2)
      this.velocity_x = 4;
    if (this.velocity_y < 2 && this.velocity_y > -2)
      this.velocity_y = 4;
  }
  public void Draw() {
    Movement();
    Collision();
    Score();
    fill(255);
    rect(this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
  }
  private void Score() {
    if (this.x - this.size / 2 > window_width || this.x + this.size / 2 < 0) {
      if (this.x - this.size / 2 > window_width) {
        this.game.score_left += 1;
      } else if (this.x + this.size / 2 < 0) {
        this.game.score_right += 1;
      }
      Reset();
    }
    
  } 
  private void Movement() {
    this.x += this.velocity_x;
    this.y += this.velocity_y;
  }
  private void Collision() {
    if (this.y + this.size / 2  >= window_height ||
        this.y - this.size / 2  <= 0) {
      this.velocity_y *= -1;
    }
    if (this.game.right_stick.Collision(this.x, this.y, this.size) ||
        this.game.left_stick.Collision(this.x, this.y, this.size)) {
      this.velocity_x *= -1;
      this.velocity_x *= 1.4;
      this.velocity_y *= 1.4;
    }
  }
};

String serial_name = "/dev/ttyUSB0";
Serial serial_port = new Serial(this, serial_name, 9600);

void setup() {
  size(1366, 768);
}

Game G = new Game(50);

void draw() {
  background(0);
  ProcessInput(G);
  G.Draw();
}

void ProcessInput(Game game) {
  int start_offset = 20,
      sensitivity_range = 30;
  String raw_data = null;
  if (serial_port.available() > 0) 
    raw_data = serial_port.readStringUntil('\n');
  if (raw_data != null) {
    String[] spliced_data = raw_data.split("\\s+");
    game.StickPosition(CorrectInput(int(spliced_data[0]), start_offset, sensitivity_range),
                       /*CorrectInput(int(spliced_data[1]), start_offset, sensitivity_range));*/
                       AI(game));
  }
}

int AI(Game game) {
  if (game.ball.velocity_x > 0) {
    int pos = game.ball.y - stick_length / 2 + int(random(50) - 25);
    if (pos > window_height - stick_length)
      pos = window_height - stick_length;
    else if (pos < 0)
      pos = 0;
    return pos;
  } else {
     return (window_height - stick_length) / 2;
  }
  
}

int CorrectInput(int raw_input, int start_offset, int sensitivity_range) {
    int processed_input = raw_input;
    processed_input -= start_offset;
    if (processed_input > sensitivity_range) {
      processed_input = 0;
    } else if (processed_input < 0) {
      processed_input = window_height - stick_length;
    } else {
      processed_input = window_height - (processed_input * window_height / sensitivity_range);
      if (processed_input > window_height - stick_length) {
        processed_input = window_height - stick_length;
      }
    }
    return processed_input;
}