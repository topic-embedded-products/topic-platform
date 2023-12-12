/* Copyright (C) 2023 Topic Embedded Systems */

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/poll.h>
#include <unistd.h>
#include <string.h>

#ifndef DEBUGLEVEL
#   define DEBUGLEVEL 0
#endif

#define dbg(format, ...) if (DEBUGLEVEL > 0) { printf(format, __VA_ARGS__); }

static const unsigned int key_poweroff = KEY_POWER;

static int has_key_events(int device_fd)
{
    unsigned long evbit = 0;
    ioctl(device_fd, EVIOCGBIT(0, sizeof(evbit)), &evbit);
    return evbit & (1 << EV_KEY);
}

static int has_specific_key(int device_fd, unsigned int key)
{
    size_t nchar = KEY_MAX / 8 + 1;
    unsigned char bits[nchar];
    ioctl(device_fd, EVIOCGBIT(EV_KEY, sizeof(bits)), &bits);
    return bits[key / 8] & (1 << (key % 8));
}

static int find_power_keys(struct pollfd *destination, int size, const char *directory_path)
{
    DIR* directory = opendir(directory_path);
    struct dirent *entry;
    int result = 0;
    char filename[80];

    if (!directory) {
        printf("Failed to open %s.\n", directory_path);
        return -1;
    }
    while (size && (entry = readdir(directory))) {
        /* Look for character devices */
        if (entry->d_type == DT_CHR) {
            snprintf(filename, sizeof(filename), "%s/%s", directory_path, entry->d_name);
            dbg("Check %s: ", entry->d_name);
            int fd = open(filename, O_RDONLY | O_CLOEXEC);
            if (fd < 0) {
                printf("Failed to open %s for reading: %s\n", filename,
                       strerror(errno));
                continue;
            }
            if (has_key_events(fd) && has_specific_key(fd, key_poweroff)) {
                dbg("OK: %s\n", entry->d_name);
                destination->fd = fd;
                destination->events = POLLIN;
                destination->revents = 0;
                destination++;
                size--;
                result++;
            } else {
                dbg("No KEY_POWER: %s\n", entry->d_name);
                close(fd);
            }
        }
    }
    closedir(directory);
    return result;
}

int main(int argc, char** argv) {
    const char* input_directory = "/dev/input";
    const int poll_fd_size = 4;
    struct pollfd poll_fds[poll_fd_size];
    int i;
    int num_fds;

    num_fds = find_power_keys(poll_fds, poll_fd_size, input_directory);
    if (num_fds <= 0)
        return num_fds < 0 ? 1 : 0;

    for(;;) {
        poll(poll_fds, num_fds, -1);
        for (i = 0; i < num_fds; i++) {
            if (poll_fds[i].revents & POLLIN) {
                struct input_event event;
                if (read(poll_fds[i].fd, &event, sizeof(event)) != sizeof(event)) {
                    printf("Failed to read an event.\n");
                    return 1;
                }
                if (event.type == EV_KEY && event.code == key_poweroff && event.value) {
                    /* Shut down the system and terminate this program */
                    execl("/sbin/shutdown", "/sbin/shutdown", "-h", "-P", "now", NULL);
                    execl("/sbin/halt", "/sbin/halt", NULL);
                    return 2;
                }
            }
        }
    }
    return 0;
}
