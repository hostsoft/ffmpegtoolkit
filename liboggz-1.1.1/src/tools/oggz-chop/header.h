#ifndef __HEADER_H__
#define __HEADER_H__

int header_accept_timeuri_ogg (void);
int header_content_type_ogg (void);
int header_content_length (int len);
int header_last_modified (time_t mtime);
int header_not_modified (void);
int header_end (void);

#endif /* __HEADER_H__ */
