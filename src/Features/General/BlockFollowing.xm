//  src/Features/General/BlockFollowing.xm
//  Bloqueia a apresentação da tela “Seguindo” / “Following”

#import "../../InstagramHeaders.h"
#import "../../Manager.h"

/* Wrapper de leitura da preferência ------------------- */
static inline BOOL BHShouldBlockFollowing(void) {
    return [SCIManager getPref:@"hide_following_list"];   // BOOL
}

/* ============ HOOK GLOBAL ============ */
%group HideFollowing

%hook UIViewController

- (void)presentViewController:(UIViewController *)vc
                     animated:(BOOL)animated
                   completion:(void(^)(void))completion
{
    if (BHShouldBlockFollowing()) {
        NSString *cls = NSStringFromClass([vc class]);

        // Bloqueia QUALQUER controller cujo nome contenha
        // “Follow” ou “UserList” (cobre praticamente todas
        // as builds recentes do Instagram)
        if ([cls containsString:@"Follow"] || [cls containsString:@"UserList"]) {
            NSLog(@"[SCInsta] CANCEL presenting %@", cls);
            return;        // ← simplesmente não apresenta
        }
    }
    %orig(vc, animated, completion);
}

%end   // UIViewController
%end   // HideFollowing group

/* ============ INICIALIZAÇÃO ============
 * Não precisa verificar a pref aqui; hook sempre carregado
 * e a lógica interna decide.
 */
%ctor {
    %init(HideFollowing);
}
