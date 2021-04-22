//
//  SQWeChat.m
//  SQWeChat
//
//  Created by yuehuig on 2021/4/13.
//

#import "SQWeChat.h"

@interface SQWeChat ()<WXApiLogDelegate>

@end

@implementation SQWeChat

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static SQWeChat *instance;
    dispatch_once(&onceToken, ^{
        instance = [[SQWeChat alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

+ (BOOL)registerApp:(NSString *)appid universalLink:(NSString *)universalLink {
    return [WXApi registerApp:appid universalLink:universalLink];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[SQWeChat sharedManager]];
}

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity {
    return [WXApi handleOpenUniversalLink:userActivity delegate:[SQWeChat sharedManager]];
}

+ (BOOL)isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}

+ (BOOL)isWXAppSupportApi {
    return [WXApi isWXAppSupportApi];
}

+ (NSString *)getWXAppInstallUrl {
    return [WXApi getWXAppInstallUrl];
}

+ (NSString *)getApiVersion {
    return [WXApi getApiVersion];
}

+ (BOOL)openWXApp {
    return [WXApi openWXApp];
}

/*! @brief 发送请求到微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
 * SendAuthReq、SendMessageToWXReq、PayReq等。
 * @param req 具体的发送请求。
 * @param completion 调用结果回调block
 */
+ (void)sendReq:(BaseReq *)req completion:(void (^ __nullable)(BOOL success))completion {
    [WXApi sendReq:req completion:completion];
}

/*! @brief 收到微信onReq的请求，发送对应的应答给微信，并切换到微信界面
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序收到微信onReq的请求，异步处理该请求，完成后必须调用该函数。可能发送的相应有
 * GetMessageFromWXResp、ShowMessageFromWXResp等。
 * @param resp 具体的应答内容
 * @param completion 调用结果回调block
 */
+ (void)sendResp:(BaseResp*)resp completion:(void (^ __nullable)(BOOL success))completion {
    [WXApi sendResp:resp completion:completion];
}

/*! @brief 发送Auth请求到微信，支持用户没安装微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持SendAuthReq类型。
 * @param req 具体的发送请求。
 * @param viewController 当前界面对象。
 * @param completion 调用结果回调block
 */
+ (void)sendAuthReq:(SendAuthReq *)req viewController:(UIViewController*)viewController completion:(void (^ __nullable)(BOOL success))completion {
    [WXApi sendAuthReq:req viewController:viewController delegate:[SQWeChat sharedManager] completion:completion];
}

/*! @brief 测试函数，用于排查当前App通过Universal Link方式分享到微信的流程
    注意1:  调用自检函数之前必须要先调用registerApp:universalLink接口, 并确认调用成功
    注意2:  自检过程中会有Log产生，可以先调用startLogByLevel函数，根据Log排查问题
    注意3:  会多次回调block
    注意4:  仅用于新接入SDK时调试使用，请勿在正式环境的调用
 *
 *  当completion回调的step为WXULCheckStepFinal时，表示检测通过，Universal Link接入成功
 *  @param completion 回调Block
 */
+ (void)checkUniversalLinkReady:(nonnull WXCheckULCompletion)completion {
    [WXApi checkUniversalLinkReady:completion];
}

+ (void)startLogByLevel:(WXLogLevel)level {
    [WXApi startLogByLevel:level logDelegate:[SQWeChat sharedManager]];
}

/*! @brief 停止打印log，会清理block或者delegate为空，释放block
 */
+ (void)stopLog {
    [WXApi stopLog];
}

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate wechatDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate wechatDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate wechatDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate wechatDidRecvAuthResponse:authResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate wechatDidRecvAddCardResponse:addCardResp];
        }
    } else if ([resp isKindOfClass:[WXChooseCardResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvChooseCardResponse:)]) {
            WXChooseCardResp *chooseCardResp = (WXChooseCardResp *)resp;
            [_delegate wechatDidRecvChooseCardResponse:chooseCardResp];
        }
    } else if ([resp isKindOfClass:[WXChooseInvoiceResp class]]){
        if (_delegate
            && [_delegate respondsToSelector:@selector(wechatDidRecvChooseInvoiceResponse:)]) {
            WXChooseInvoiceResp *chooseInvoiceResp = (WXChooseInvoiceResp *)resp;
            [_delegate wechatDidRecvChooseInvoiceResponse:chooseInvoiceResp];
        }
    } else if ([resp isKindOfClass:[WXSubscribeMsgResp class]]){
        if ([_delegate respondsToSelector:@selector(wechatDidRecvSubscribeMsgResponse:)])
        {
            [_delegate wechatDidRecvSubscribeMsgResponse:(WXSubscribeMsgResp *)resp];
        }
    } else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]){
        if ([_delegate respondsToSelector:@selector(wechatDidRecvLaunchMiniProgram:)]) {
            [_delegate wechatDidRecvLaunchMiniProgram:(WXLaunchMiniProgramResp *)resp];
        }
    } else if([resp isKindOfClass:[WXInvoiceAuthInsertResp class]]){
        if ([_delegate respondsToSelector:@selector(wechatDidRecvInvoiceAuthInsertResponse:)]) {
            [_delegate wechatDidRecvInvoiceAuthInsertResponse:(WXInvoiceAuthInsertResp *) resp];
        }
    } else if([resp isKindOfClass:[WXNontaxPayResp class]]){
        if ([_delegate respondsToSelector:@selector(wechatDidRecvNonTaxpayResponse:)]) {
            [_delegate wechatDidRecvNonTaxpayResponse:(WXNontaxPayResp *)resp];
        }
    } else if ([resp isKindOfClass:[WXPayInsuranceResp class]]){
        if ([_delegate respondsToSelector:@selector(wechatDidRecvPayInsuranceResponse:)]) {
            [_delegate wechatDidRecvPayInsuranceResponse:(WXPayInsuranceResp *)resp];
        }
    }
}

#pragma mark - WXApiLogDelegate
- (void)onLog:(NSString *)log logLevel:(WXLogLevel)level {
    if ([_delegate respondsToSelector:@selector(wechatDidRecvLog:)]) {
        [_delegate wechatDidRecvLog:log];
    }
}
@end
