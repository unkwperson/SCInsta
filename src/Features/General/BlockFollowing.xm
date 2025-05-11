//  BlockFollowing.xm
//  Bloqueia a lista “Seguindo” e loga eventos úteis
//
//  • Pref-key: hide_following_list (BOOL)
//  • Logs:    [SCInsta-DBG][Tap] / [SCInsta-DBG][Present]
//  • Build:   coloque em SCInsta.plist, compile em Debug.

#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

/* ========= Stubs só para o clang conhecer as classes ========= */
@interface IGUserListViewController            : UIViewController @end
@interface IGFollowListContainerController     : UIViewController @end
@interface IGProfileSimpleAvatarStatsCell      : UIView              // botão stats
- (void)_followingButtonTapped:(id)sender;
@end
/* ============================================================= */

/* ---------- Preferências ---------- */
static inline BOOL BHShouldBlock(void) {       // toggle do usuário
    return [SCIManager getPref:@"hide_following_list"];
}
static inline BOOL BHShouldLog(void)   {       // sempre logar (mude se quiser toggle)
    return YES;
}

/* ========================================================== *
 * 1) Logger de Tap – mostra seletor exato que cada botão chama
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
 * 2) Hook específico — bloqueia o botão “Seguindo” detectado
 * ========================================================== */
%hook IGProfileSimpleAvatarStatsCell
- (void)_followingButtonTapped:(id)sender {
    if (BHShouldBlock()) {
        NSLog(@"[SCInsta] Bloqueado _followingButtonTapped:");
        return;                            // não deixa abrir nada
    }
    %orig;
}
%end   // IGProfileSimpleAvatarStatsCell

/* ========================================================== *
 * 3) Intercepta apresentações de VCs
 *    • Loga sempre
 *    • Cancela se pref ON e nome contém Follow/UserList
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
        return;
    }
    %orig(vc, animated, completion);
}
%end   // UIViewController

/* ========================================================== *
 * 4) Rede de segurança: se escapar, fecha imediatamente
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
 * 5) Inicialização
 * ========================================================== */
%ctor { %init; }
