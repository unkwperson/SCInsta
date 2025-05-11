//  BlockFollowing.xm
//  Pref-key: hide_following_list
//
//  Logs: [SCInsta-DBG][Tap]  /  [SCInsta-DBG][Present]

#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

/* ========= Stubs / categorias ========= *
 * - IGUserListViewController e IGFollowListContainerController
 *   não estão nos headers → criamos stubs que herdam de UIViewController.
 * - IGProfileSimpleAvatarStatsCell já existe nos headers;
 *   criamos só uma CATEGORIA para expor o seletor que hookaremos.
 * ====================================== */

@interface IGUserListViewController        : UIViewController @end
@interface IGFollowListContainerController : UIViewController @end

@interface IGProfileSimpleAvatarStatsCell (BHFollow)
- (void)_followingButtonTapped:(id)sender;
@end

/* ---------- Preferências ---------- */
static inline BOOL BHShouldBlock(void) { return [SCIManager getPref:@"hide_following_list"]; }
static inline BOOL BHShouldLog(void)   { return YES; }

/* 1) Logger de Tap ------------------------------------------------------ */
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
%end

/* 2) Hook do botão “Seguindo” ------------------------------------------ */
%hook IGProfileSimpleAvatarStatsCell
- (void)_followingButtonTapped:(id)sender {
    if (BHShouldBlock()) {
        NSLog(@"[SCInsta] Bloqueado _followingButtonTapped:");
        return;                           // não chama %orig
    }
    %orig;
}
%end

/* 3) Intercepta apresentações ------------------------------------------ */
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
%end

/* 4) Rede de segurança -------------------------------------------------- */
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

/* 5) Inicialização ------------------------------------------------------ */
%ctor { %init; }
