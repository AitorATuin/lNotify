#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <signal.h>
#include <sys/inotify.h>
#include <errno.h>

struct itimerval * _new_itimerval () 
{
	struct itimerval * timer;
	timer = (struct itimerval *) malloc(sizeof(struct itimerval));
	return timer;
}

void _kill_itimerval (struct itimerval * timer)
{
	free(timer);
}

void _set_itimerval_value_tvsec (struct itimerval *timer, long tv_sec)
{
		timer->it_value.tv_sec = tv_sec;
}

void _set_itimerval_value_tvusec (struct itimerval *timer, long tv_usec)
{
		timer->it_value.tv_usec = tv_usec;
}

void _set_itimerval_interval_tvsec (struct itimerval *timer, long tv_sec)
{
		timer->it_interval.tv_sec = tv_sec;
}

void _set_itimerval_interval_tvusec (struct itimerval *timer, long tv_usec)
{
		timer->it_interval.tv_usec = tv_usec;
};

int _event_size (void)
{
	return (sizeof (struct inotify_event));
};

int _read (int fd, char *buf) {
	#define EVENT_SIZE  (sizeof (struct inotify_event))

	/* reasonable guess as to size of 1024 events */
	#define BUF_LEN        (1024 * (EVENT_SIZE + 16))

//	char buf[BUF_LEN];
	int len, i = 0;
	printf("fd = %d, buf = %p\n", fd, buf);
	len = read (fd, buf, BUF_LEN);

	printf("len  = %d\n",len);
	printf("pointer = %p\n", buf);
	if (len < 0) {
		perror ("read");
} else if (!len)
        /* BUF_LEN too small? */
while (i < len) {
        struct inotify_event *event;

        event = (struct inotify_event *) &buf[i];

        printf ("wd=%d mask=%u cookie=%u len=%u\n",
                event->wd, event->mask,
                event->cookie, event->len);

        if (event->len)
                printf ("name=%s\n", event->name);

        i += EVENT_SIZE + event->len;
}
	return len;
}

void _test (char * n)
{
	printf("KKK\n");
	printf("%p\n", n);
	printf("KKK\n");
}
