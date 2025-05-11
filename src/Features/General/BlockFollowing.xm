#import "../../InstagramHeaders.h"
#import "../../Manager.h"

/* Declaramos só para o clang não reclamar */
@interface IGProfileViewController (BHHideFollowing)
- (void)followingButtonTapped:(id)sender;
- (void)didTapFollowingButton:(id)sender;
- (void)showFollowingForUser:(id)user;
- (void)_superPresentViewController:(UIViewController *)vc
                           animated:(BOOL)animated
                         completion:(id)completion;
@end

/* ===== Hook real ===== */
%group HideFollowing

%hook IGProfileViewController

/* Bloqueia os toques mais comuns ---------------------- */
- (void)followingButtonTapped:(id)sender { if (![SCIManager getPref:@"hide_following_list"]) { %orig; } }
- (void)didTapFollowingButton:(id)sender { if (![SCIManager getPref:@"hide_following_list"]) { %orig; } }
- (void)showFollowingForUser:(id)user    { if (![SCIManager getPref:@"hide_following_list"]) { %orig; } }

/* **GUARDA DE SEGURANÇA**  
 * Se o app tentar apresentar QUALQUER controller cuja classe
 * contenha “Follow” ou “UserList”, abortamos a apresentação.
 */
- (void)_superPresentViewController:(UIViewController *)vc
                           animated:(BOOL)animated
                         completion:(id)completion
{
    if ([SCIManager getPref:@"hide_following_list"] &&
        ( [vc isKindOfClass:NSClassFromString(@"IGUserListViewController")] ||
          [vc isKindOfClass:NSClassFromString(@"IGFollowListViewController")] ||
          [NSStringFromClass([vc class]) containsString:@"Follow"] ) )
    {
        NSLog(@"[SCInsta] Bloqueado %@ 📵", NSStringFromClass([vc class]));
        [Vibration light];          // feedback opcional
        return;                     // CANCELA a apresentação
    }
    %orig;
}

%end   // IGProfileViewController
%end   // HideFollowing

%ctor {
    if ([SCIManager getPref:@"hide_following_list"]) {
        %init(HideFollowing);
    }
}
