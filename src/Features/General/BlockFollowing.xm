#import "../../InstagramHeaders.h"
#import "../../Manager.h"

/*  <<< ADIANTE APENAS AS ASSINATURAS QUE PRECISA >>>  */
@interface IGProfileViewController (BHHideFollowing)
- (void)followingButtonTapped:(id)sender;       // 325+
- (void)didTapFollowingButton:(id)sender;       // 305-320
- (void)showFollowingForUser:(id)user;          // ≤300
@end
/*  ↑ nada implementado aqui, é só p/ o clang parar de reclamar  */

/* ------------ HOOK VERDADEIRO ---------------------- */
%group HideFollowing

%hook IGProfileViewController

- (void)followingButtonTapped:(id)sender {
    if ([SCIManager getPref:@"hide_following_list"]) {
        NSLog(@"[SCInsta] followingButtonTapped bloqueado");
        return;                     // não chama %orig
    }
    %orig;
}

- (void)didTapFollowingButton:(id)sender {
    if ([SCIManager getPref:@"hide_following_list"]) {
        NSLog(@"[SCInsta] didTapFollowingButton bloqueado");
        return;
    }
    %orig;
}

- (void)showFollowingForUser:(id)user {
    if ([SCIManager getPref:@"hide_following_list"]) {
        NSLog(@"[SCInsta] showFollowingForUser: bloqueado");
        return;
    }
    %orig;
}

%end          // IGProfileViewController
%end          // HideFollowing

%ctor {
    if ([SCIManager getPref:@"hide_following_list"]) {
        %init(HideFollowing);
    }
}
