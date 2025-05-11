#import "../../InstagramHeaders.h"
#import "../../Manager.h"

/* Predeclara só os métodos que vamos hookar */
@interface IGProfileViewController (BHHideFollowing)
- (void)followingButtonTapped:(id)sender;
- (void)didTapFollowingButton:(id)sender;
- (void)showFollowingForUser:(id)user;
- (void)_superPresentViewController:(UIViewController *)vc
                           animated:(BOOL)animated
                         completion:(id)completion;
@end

%group HideFollowing
%hook IGProfileViewController

- (void)followingButtonTapped:(id)sender {
    if ([SCIManager getPref:@"hide_following_list"]) return;
    %orig;
}
- (void)didTapFollowingButton:(id)sender {
    if ([SCIManager getPref:@"hide_following_list"]) return;
    %orig;
}
- (void)showFollowingForUser:(id)user {
    if ([SCIManager getPref:@"hide_following_list"]) return;
    %orig;
}

- (void)_superPresentViewController:(UIViewController *)vc
                           animated:(BOOL)animated
                         completion:(id)completion
{
    if ([SCIManager getPref:@"hide_following_list"] &&
        ([vc isKindOfClass:NSClassFromString(@"IGUserListViewController")] ||
         [vc isKindOfClass:NSClassFromString(@"IGFollowListViewController")] ||
         [NSStringFromClass([vc class]) containsString:@"Follow"])) {
        NSLog(@"[SCInsta] Bloqueado %@", NSStringFromClass([vc class]));
        return;                     // não apresenta
    }
    %orig;
}
%end
%end

%ctor {
    if ([SCIManager getPref:@"hide_following_list"]) {
        %init(HideFollowing);
    }
}
