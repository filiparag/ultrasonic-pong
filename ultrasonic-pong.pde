import processing.serial.*;

int window_width = 500;
int window_height = 500;

class Game {
  private int score_left;
  private int score_right;
  private Ball ball;
  private Stick right_stick;
  private Stick left_stick;
  public Game() {
    this.left_stick = new Stick('L');
    this.right_stick = new Stick('R');
    this.ball = new Ball(this);
    this.score_left = 0;
    this.score_right = 0;
  }
  public void Draw() {
    fill(64);
    rect((window_width / 2) - 5, 0, 10, window_height);
    this.left_stick.Draw();
    this.right_stick.Draw();
    this.ball.Draw();
    fill(255);
    textAlign(CENTER, TOP);
    textSize(30);
    text(this.score_left + "  " + this.score_right, window_width / 2, 0);
  }
  public void StickPosition(int l, int r) {
     this.left_stick.SetPosition(l);
     this.right_stick.SetPosition(r);
  }
};

class Stick {
  private int x;
  private int y;
  private int width = 20;
  private int height = 100;
  private char position;
  public Stick(char pos) {
    if (pos == 'R')
      this.x = window_width - this.width;
    else
      this.x = 0;
    this.y = (window_height - this.height) / 2;
    this.position = pos;
  }
  public void Draw() {
    fill(255);
    rect(this.x, this.y, this.width, this.height);
  }
  public boolean Collision(int x_pos, int y_pos, int size) {
    if (this.position == 'R')
      return (x_pos >= this.x - this.width / 2 &&
              x_pos + size / 2 < window_width &&
              y_pos >= this.y &&
              y_pos - size / 2 <= this.y + this.height);
    else
      return (x_pos - size / 2 <= this.x + this.width &&
              x_pos - size / 2 > 0 &&
              y_pos - size / 2 >= this.y &&
              y_pos + size / 2 <= this.y + this.height);
  }
  public void SetPosition(int pos) {
    this.y = pos;
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
    if (this.x - this.size / 2 > window_width) {
      Reset();
      this.game.score_left += 1;
      delay(200);
    } else if (this.x + this.size / 2 < 0) {
      Reset();
      this.game.score_right += 1;
      delay(200);
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
      this.velocity_x *= 1.2;
      this.velocity_y *= 1.2;
    }
  }
};

String serial_name = "/dev/ttyUSB0";
Serial serial_port = new Serial(this, serial_name, 9600);

void setup() {
  size(500, 500);
}

Game G = new Game();

void draw() {

  background(0);
  G.Draw();
  
  String serial_data = null;
  if ( serial_port.available() > 0) 
    serial_data = serial_port.readStringUntil('\n');
  
  String[] data;
  
  if (serial_data != null) {
    data = serial_data.split("\\s+");
    int left_pos = int(data[0]);
    left_pos -= 3; // Calibration
    
    fill(0, 255, 255);
    textAlign(CENTER, TOP);
    textSize(20);
    text(left_pos, 50, 50);
    
    
    if (left_pos < 30)
      left_pos = window_height - (left_pos * window_height / 30);
    else
      left_pos = 0;
    
    text(left_pos, 50, 100);
    
    int right_pos = 0; //int(data[1]) * window_height / 60;
    G.StickPosition(left_pos, right_pos);
  }
  
  
}