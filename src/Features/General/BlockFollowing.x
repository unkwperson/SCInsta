#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Block the "Following" button in Profile if preference is enabled
%hook IGProfileTabViewController
- (void)userDidSelectFollowing {
    // Verificar se a preferência está ativada
    if ([SCIManager getPref:@"block_following_button"]) {
        NSLog(@"[SCInsta] Blocking Following button click");
        
        // Exibir uma notificação sutil para o usuário (opcional)
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Blocked"
                                                                       message:@"The following list is currently disabled."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        
        // Mostrar o alerta
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
        
        return; // Não faz nada ao clicar
    }

    %orig; // Caso contrário, executa normalmente
}
%end
