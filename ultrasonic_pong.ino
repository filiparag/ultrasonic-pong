#define FRAMERATE 30

unsigned short delta_time = 1000 / FRAMERATE;

struct UltraSonic {
  char trigger_pin,
       echo_pin;
  unsigned int duration,
               distance;
};

UltraSonic left_sensor = {9, 8};
UltraSonic right_sensor = {10, 11};

void setup() {
  Serial.begin (9600);
  pinMode(left_sensor.trigger_pin, OUTPUT);
  pinMode(left_sensor.echo_pin, INPUT);
  pinMode(right_sensor.trigger_pin, OUTPUT);
  pinMode(right_sensor.echo_pin, INPUT);
}

void measure(UltraSonic& sensor) {
  digitalWrite(sensor.trigger_pin, LOW);
  delayMicroseconds(2);
  digitalWrite(sensor.trigger_pin, HIGH);
  delayMicroseconds(5);
  digitalWrite(sensor.trigger_pin, LOW);
  sensor.duration = pulseIn(sensor.echo_pin, HIGH);
  sensor.distance = (sensor.duration / 2) / 29.1;
}

unsigned long last_time = 0;
short repetitions = 0;

unsigned int left_average = 0,
             right_average = 0;

void loop() {

//  Serial.println(millis());

  if (millis() - last_time > delta_time) {
    last_time = millis();
    left_average /= repetitions;
    right_average /= repetitions;
    Serial.println(String(left_average) + ' ' + String(right_average));
    left_average = 0;
    right_average = 0;
    repetitions = 0;
  } else {
    ++repetitions;
    measure(left_sensor);
    left_average += left_sensor.distance;
//    measure(right_sensor);
//    right_average += right_sensor.distance;
  }
    
}
