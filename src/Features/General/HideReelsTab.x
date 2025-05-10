#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Hide profile button (usando a chave existente hide_reels_tab)
%hook IGTabBar
- (void)didMoveToWindow {
    %orig;

    // Verificar se a preferência "hide_reels_tab" está ativada
    if ([SCIManager getPref:@"hide_reels_tab"]) {
        NSMutableArray *tabButtons = [self valueForKey:@"_tabButtons"];
        NSLog(@"[SCInsta] Hiding profile button instead of reels tab");

        if ([tabButtons count] > 0) {
            // Detectar o botão de perfil de forma dinâmica
            for (UIView *button in tabButtons) {
                NSString *accessibilityLabel = [button accessibilityLabel];
                
                // Verificar se é o botão de perfil (geralmente identificado por "Profile" ou "Perfil")
                if ([accessibilityLabel containsString:@"Profile"] || [accessibilityLabel containsString:@"Perfil"]) {
                    NSLog(@"[SCInsta] Profile button found. Hiding...");
                    [button setHidden:YES];
                    break;
                }
            }
        }

        // Verificar e ocultar a subview correspondente diretamente
        for (UIView *subview in self.subviews) {
            NSString *accessibilityLabel = [subview accessibilityLabel];
            if ([accessibilityLabel containsString:@"Profile"] || [accessibilityLabel containsString:@"Perfil"]) {
                NSLog(@"[SCInsta] Hiding profile subview...");
                [subview setHidden:YES];
                break;
            }
        }
    }
}
%end
