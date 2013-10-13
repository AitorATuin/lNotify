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
