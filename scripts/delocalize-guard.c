/*
 * delocalize-guard — 删除 Finder 的 ".localized" 标记，让系统自带的文件夹
 * （Desktop / Documents / Downloads ...）一直显示英文名。
 *
 * 为什么必须是一个编译出来的二进制，而不是 shell 脚本：
 * macOS 的 TCC 权限（完全磁盘访问 / Full Disk Access）是按“可执行文件”授权并
 * 记录的，shell 脚本拿不到授权。而 ~/Desktop、~/Documents、~/Downloads 这三个
 * 受 TCC 保护的目录，launchd 里的进程没有授权时连 unlink 都会被拒绝
 * （实测 rm: Operation not permitted），所以必须由这个二进制来删。
 * 授权方法见 localized_guard.sh / README。
 *
 * 用法: delocalize-guard [--quiet] <要删除的 .localized 路径>...
 * 结果追加写入 ~/Library/Logs/remove-localized.log（超过 1MB 自动轮转）。
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>

#define LOG_MAX_BYTES (1024 * 1024)

static int quiet = 0;

static void now_string(char *buf, size_t size) {
    time_t now = time(NULL);
    struct tm tm;
    localtime_r(&now, &tm);
    strftime(buf, size, "%Y-%m-%d %H:%M:%S", &tm);
}

static void time_string(const struct timespec *ts, char *buf, size_t size) {
    time_t t = ts->tv_sec;
    if (t <= 0) {
        snprintf(buf, size, "unknown");
        return;
    }
    struct tm tm;
    localtime_r(&t, &tm);
    strftime(buf, size, "%Y-%m-%d %H:%M:%S", &tm);
}

/* 日志只保留最近 1MB：超了就整体轮转成 .1 */
static void rotate_log(const char *log) {
    struct stat st;
    if (stat(log, &st) != 0 || st.st_size <= LOG_MAX_BYTES) {
        return;
    }
    char backup[4096];
    if (snprintf(backup, sizeof backup, "%s.1", log) >= (int)sizeof backup) {
        return;
    }
    rename(log, backup);
}

static void append_log(const char *line) {
    const char *home = getenv("HOME");
    if (home == NULL || *home == '\0') {
        return;
    }
    char log[4096];
    if (snprintf(log, sizeof log, "%s/Library/Logs/remove-localized.log", home)
        >= (int)sizeof log) {
        return;
    }
    rotate_log(log);
    FILE *fp = fopen(log, "a");
    if (fp == NULL) {
        return;
    }
    fputs(line, fp);
    fclose(fp);
}

int main(int argc, char **argv) {
    int removed = 0, failed = 0, missing = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--quiet") == 0) {
            quiet = 1;
            continue;
        }
        if (strcmp(argv[i], "--help") == 0) {
            fprintf(stderr, "usage: %s [--quiet] <path>.localized ...\n", argv[0]);
            return 0;
        }

        const char *path = argv[i];
        struct stat st;
        if (lstat(path, &st) != 0) {
            if (errno != ENOENT) {
                failed++;
                char stamp[32], line[4608];
                now_string(stamp, sizeof stamp);
                snprintf(line, sizeof line, "%s FAILED to stat %s: %s\n",
                         stamp, path, strerror(errno));
                append_log(line);
            } else {
                missing++;
            }
            continue;
        }

        char created[32], modified[32], stamp[32], line[4608];
        time_string(&st.st_birthtimespec, created, sizeof created);
        time_string(&st.st_mtimespec, modified, sizeof modified);
        now_string(stamp, sizeof stamp);

        if (unlink(path) == 0) {
            removed++;
            snprintf(line, sizeof line, "%s removed %s (created %s, modified %s)\n",
                     stamp, path, created, modified);
            append_log(line);
            if (!quiet) {
                printf("removed %s\n", path);
            }
        } else {
            failed++;
            snprintf(line, sizeof line,
                     "%s FAILED to remove %s: %s%s\n", stamp, path, strerror(errno),
                     errno == EPERM || errno == EACCES
                         ? " (缺少完全磁盘访问授权？见 README)" : "");
            append_log(line);
            fprintf(stderr, "%s: %s\n", path, strerror(errno));
        }
    }

    if (!quiet) {
        printf("removed=%d failed=%d absent=%d\n", removed, failed, missing);
    }
    /* 一律返回 0：LaunchAgent 不该因为个别目录没权限而算执行失败。 */
    return 0;
}
