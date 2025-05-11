//  BlockFollowing.xm  (mesmo conteúdo anterior, mas corrigido)

// 1) IMPORTS
#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

/* =====  FIX: Stub das classes só para o clang enxergar ===== */
@interface IGUserListViewController : UIViewController @end
@interface IGFollowListContainerController : UIViewController @end
/* =========================================================== */

/* ---------- Preferências ---------- */
static inline BOOL BHShouldBlock(void)  { return [SCIManager getPref:@"hide_following_list"]; }
static inline BOOL BHShouldLog(void)    { return YES; }

/* 1) Logger de toques --------------------------------------------------- */
%hook UIControl
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (BHShouldLog() &&
        event.type == UIEventTypeTouches &&
        event.allTouches.anyObject.phase == UITouchPhaseEnded)
    {
        NSLog(@"[SCInsta-DBG][Tap]  %@ ➜ -[%@ %@]",
              NSStringFromClass([self class]),
              NSStringFromClass([target class]),
              NSStringFromSelector(action));
    }
    %orig;
}
%end   // UIControl

/* 2) Intercepta apresentações ------------------------------------------- */
%hook UIViewController
- (void)presentViewController:(UIViewController *)vc
                     animated:(BOOL)animated
                   completion:(void(^)(void))completion
{
    NSString *cls = NSStringFromClass([vc class]);

    if (BHShouldLog()) {
        NSLog(@"[SCInsta-DBG][Present] %@ -> %@", NSStringFromClass([self class]), cls);
    }

    if (BHShouldBlock() &&
        ([cls containsString:@"Follow"] || [cls containsString:@"UserList"]))
    {
        NSLog(@"[SCInsta] CANCEL presenting %@", cls);
        return;
    }
    %orig(vc, animated, completion);
}
%end   // UIViewController

/* 3) Hooks de segurança (caso escape) ----------------------------------- */
%hook IGUserListViewController
- (void)viewDidAppear:(BOOL)animated {
    if (BHShouldBlock()) {
        NSLog(@"[SCInsta] Dismiss IGUserListViewController (safety)");
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    %orig;
}
%end

%hook IGFollowListContainerController
- (void)viewDidAppear:(BOOL)animated {
    if (BHShouldBlock()) {
        NSLog(@"[SCInsta] Dismiss IGFollowListContainerController (safety)");
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    %orig;
}
%end

/* 4) Inicialização ------------------------------------------------------ */
%ctor { %init; }
