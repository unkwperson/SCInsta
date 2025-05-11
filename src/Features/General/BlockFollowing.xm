//  BlockFollowing.xm
//  • Bloqueia lista “Seguindo” (pref: hide_following_list)
//  • Loga toques + apresentações p/ descobrir seletor/VC correto

#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

/* ---------- Preferências ---------- */
static inline BOOL BHShouldBlock(void)  { return [SCIManager getPref:@"hide_following_list"]; }
static inline BOOL BHShouldLog(void)    { return YES; /* ou outra chave, se quiser toggle */ }

/* ========================================================== *
 *  1) Logger de Toque – vê qual método o botão realmente chama
 * ========================================================== */
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

/* ========================================================== *
 *  2) Intercepta qualquer apresentação de VC
 *     • Loga sempre
 *     • Cancela se pref ON  e  nome contém Follow/UserList
 * ========================================================== */
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
        return;                       // ⬅︎ BLOQUEIA
    }
    %orig(vc, animated, completion);
}
%end   // UIViewController

/* ========================================================== *
 *  3) Hook de segurança: se por acaso o VC escapar e aparecer,
 *     damos dismiss imediatamente e logamos.
 * ========================================================== */
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

/* ========================================================== *
 *  Inicialização (carrega sempre; preferência decide ação)
 * ========================================================== */
%ctor { %init; }
