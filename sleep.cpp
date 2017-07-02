#include <iostream>
#include <time.h>

//#include "sleep.s"

using namespace std;


struct timetime {
  int tv_sec;
  int tv_nsec;
};

int main(void)
{
  timetime time;
  
  time.tv_sec = 5;
  time.tv_nsec = 0;
  
  clock_nanosleep(CLOCK_REALTIME, 0, &time, NULL);
  
  cout << "hello world" << endl;
  return 0;
}
