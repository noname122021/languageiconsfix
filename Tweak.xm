#import <UIKit/UIKit.h>
#import <spawn.h>
#import <objc/runtime.h>

extern char **environ;

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (void)loadApplicationsAndIcons:(BOOL)arg1;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (void)relayout;
@end

static void RunUICacheAsync(void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Give SpringBoard 1 second to finish writing new locale preferences
        [NSThread sleepForTimeInterval:1.0];

        // Execute uicache as mobile user to repair LaunchServices bundle maps
        pid_t pid;
        const char *argv[] = {"/bin/sh", "-c", "su - mobile -c /usr/bin/uicache", NULL};
        if (posix_spawn(&pid, "/bin/sh", NULL, NULL, (char *const *)argv, environ) == 0) {
            int status = 0;
            waitpid(pid, &status, 0);
        }

        // Notify SpringBoard to reload and relayout icons without dropping to host OS
        dispatch_async(dispatch_get_main_queue(), ^{
            Class sbAppCtrlClass = objc_getClass("SBApplicationController");
            if (sbAppCtrlClass && [sbAppCtrlClass respondsToSelector:@selector(sharedInstance)]) {
                id appCtrl = [sbAppCtrlClass sharedInstance];
                if ([appCtrl respondsToSelector:@selector(loadApplicationsAndIcons:)]) {
                    [(SBApplicationController *)appCtrl loadApplicationsAndIcons:YES];
                }
            }

            Class sbIconCtrlClass = objc_getClass("SBIconController");
            if (sbIconCtrlClass && [sbIconCtrlClass respondsToSelector:@selector(sharedInstance)]) {
                id iconCtrl = [sbIconCtrlClass sharedInstance];
                if ([iconCtrl respondsToSelector:@selector(relayout)]) {
                    [(SBIconController *)iconCtrl relayout];
                }
            }
        });
    });
}

%hook SpringBoard

- (void)languageChanged {
    %orig;
    RunUICacheAsync();
}

%end
