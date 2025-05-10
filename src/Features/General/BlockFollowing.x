#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Bloquear o botão "Seguindo" com base no texto
%hook IGProfileViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[SCInsta] Checking for Following button");

    if ([SCIManager getPref:@"block_following_button"]) {
        // Percorrer todas as subviews do perfil
        for (UIView *subview in self.view.subviews) {
            // Verificar se é um botão
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                NSString *buttonText = button.titleLabel.text;

                // Verificar se o texto é "Seguindo" ou "Following"
                if ([buttonText containsString:@"Seguindo"] || [buttonText containsString:@"Following"]) {
                    NSLog(@"[SCInsta] Found Following button. Blocking interaction...");
                    // Remover qualquer ação do botão
                    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [button setUserInteractionEnabled:NO];
                }
            }
        }
    }
}
%end
