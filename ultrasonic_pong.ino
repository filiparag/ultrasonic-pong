#define AVERAGE 10

struct UltraSonic {
  char trigger_pin,
       echo_pin;
  unsigned int duration,
               distance;
};

UltraSonic left_sensor = {8, 7};
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

void loop() {

  unsigned int left_average = 0,
               right_average = 0;

  for (char i = 0; i < AVERAGE; ++i) {
    measure(left_sensor);
    left_average += left_sensor.distance;
  //measure(right_sensor);
    right_average = 0;
  }
  
  left_average /= AVERAGE;
  right_average /= AVERAGE;

  Serial.println(String(left_average) + ' ' + String(right_average));

  delay(20);
    
}
