#import <UIKit/UIKit.h>
#import <notify.h>
#import <spawn.h>

extern char **environ;

static void FixIconsAndRelaunch(void) {
    // 1. Run uicache synchronously (running as mobile in SpringBoard)
    pid_t pid;
    const char *argv[] = {"/usr/bin/uicache", NULL};
    if (posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char *const *)argv, environ) == 0) {
        int status = 0;
        waitpid(pid, &status, 0);
    }

    // 2. Restart SpringBoard gracefully (CoolBooter safe)
    exit(0);
}

%ctor {
    int token;
    notify_register_dispatch("com.apple.language.changed", &token, dispatch_get_main_queue(), ^(int t) {
        FixIconsAndRelaunch();
    });
}
