#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Block the navigation to the "Following" list
%hook IGFollowListViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    if ([SCIManager getPref:@"block_following_button"]) {
        NSLog(@"[SCInsta] Blocking Following list from appearing");

        // Fechar automaticamente a lista de "Seguindo"
        [self.navigationController popViewControllerAnimated:YES];
    }
}
%end
