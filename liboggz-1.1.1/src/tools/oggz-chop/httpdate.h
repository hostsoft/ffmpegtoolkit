#ifndef __HTTPDATE_H__
#define __HTTPDATE_H__

#include <time.h>

void httpdate_init (void);
int httpdate_snprint (char * buf, int n, time_t mtime);
time_t httpdate_parse (char * s, int n);

#endif /* __HTTPDATE_H__ */
