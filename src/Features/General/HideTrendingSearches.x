#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Bloquear o texto "Seguindo" diretamente
%hook IGProfileViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[SCInsta] Verificando se há o texto Seguindo...");

    if ([SCIManager getPref:@"block_following_button"]) {
        [self blockFollowingTextInSubviews:self.view];
    }
}

// Função recursiva para buscar o texto "Seguindo" em qualquer subview
- (void)blockFollowingTextInSubviews:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            NSString *text = label.text;

            if ([text containsString:@"Seguindo"] || [text containsString:@"Following"]) {
                NSLog(@"[SCInsta] Texto 'Seguindo' detectado e bloqueado.");
                label.userInteractionEnabled = NO;
                label.textColor = [UIColor grayColor]; // Mudando a cor para indicar bloqueio (opcional)
                return;
            }
        }

        // Chamar recursivamente para subviews aninhadas
        if (subview.subviews.count > 0) {
            [self blockFollowingTextInSubviews:subview];
        }
    }
}
%end
