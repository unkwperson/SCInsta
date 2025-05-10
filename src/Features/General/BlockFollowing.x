#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Bloquear o clique no botão "Seguindo" (Following)
%hook IGProfileViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[SCInsta] Modifying Following button behavior");

    // Buscar o botão de "Seguindo" na interface
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            NSString *buttonText = button.titleLabel.text;
            
            // Verificar se é o botão de "Seguindo"
            if ([buttonText containsString:@"Seguindo"] || [buttonText containsString:@"Following"]) {
                NSLog(@"[SCInsta] Following button found. Blocking...");
                [button addTarget:self action:@selector(blockedFollowingTap) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

// Método que bloqueia o toque
- (void)blockedFollowingTap {
    if ([SCIManager getPref:@"block_following_button"]) {
        NSLog(@"[SCInsta] Following button click blocked");

        // Exibir uma notificação sutil para o usuário (opcional)
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Blocked"
                                                                       message:@"The following list is currently disabled."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        
        // Mostrar o alerta
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}
%end
