//
//  GYNetLog.m
//  Pods
//
//  Created by zhangqy on 16/3/30.
//
//

#import "GYNetLogger.h"
#import "GYNetRequest.h"


@implementation GYNetLogger
+ (void)printResponse:(NSDictionary *)responseObject request:(GYNetRequest *)request {
    if (responseObject == nil) {
           GYNetDataLog(@"\n===========<response-id:%@ tag:%@>===========\n", @(request.requestId), request.tag == -1 ? @"" : @(request.tag));
        return;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonStr) {
        jsonStr = [responseObject description];
    }
    NSString *responseFixedStr = [NSString stringWithCString:[[responseObject description] cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    if (!responseFixedStr) {
        responseFixedStr = jsonStr;
    }
    GYNetDataLog(@"\n===========<response-id:%@ tag:%@>===========\n%@", @(request.requestId), request.tag == -1 ? @"" : @(request.tag), jsonStr);
}

+ (void)printRequest:(GYNetRequest *)request {
    NSString *URLString = request.URLString;
    NSString *baseURL = request.baseURL;
    if (baseURL && URLString) {
        if ([baseURL hasSuffix:@"/"]) {
            baseURL = [baseURL substringToIndex:baseURL.length-1];
        }
        if ([URLString hasPrefix:@"/"]) {
            URLString = [URLString substringFromIndex:1];
        }
        URLString = [NSString stringWithFormat:@"%@/%@",baseURL,URLString];
    }

    NSDictionary *parameters = request.parameters;
    NSNumber *requestId = @(request.requestId);
    if (!([parameters isKindOfClass:[NSDictionary class]] && parameters.count > 0)) {
        GYNetDataLog(@"\n===========<request-id:%@ tag:%@>===========\n%@", requestId, request.tag == -1 ? @"" : @(request.tag), URLString);
    } else if (request.requestMethod == GYNetRequestMethodGET) {
        NSString *paraStr = [self urlParametersStringFromParameters:parameters];
        GYNetDataLog(@"\n===========<request-id:%@ tag:%@>===========\n%@?%@", requestId, request.tag == -1 ? @"" : @(request.tag), URLString, paraStr);
    } else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        GYNetDataLog(@"\n===========<request-id:%@ tag:%@>===========\n%@\nhttpBody:%@", requestId, request.tag == -1 ? @"" : @(request.tag), URLString, postStr);
    }
}

+ (NSString *)urlParametersStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@", value];
            //  value = [self urlEncode:value];
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    return [urlParametersString substringFromIndex:1];
}

+ (NSString *)urlEncode:(NSString *)str {
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    return result;
}

+ (void)printCancelRequest:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-取消1个请求", @(request.requestId));
}

+ (void)printAddRequest:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-增加1个请求，队列剩余请求数%@", @(request.requestId), @(_requestQueue.count));
}

+ (void)printRemoveRequest:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-移除1个请求，队列剩余请求数%@", @(request.requestId), @(_requestQueue.count));
}

+ (void)printRequestFinished:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-1个请求己完成", @(request.requestId));
}

+ (void)printRequestFailed:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-1个请求已失败", @(request.requestId));
}

+ (void)printAllRequestFinished {
    GYNetDebugLog(@"所有请求已完成");
}

+ (void)printRequesting {
    GYNetDebugLog(@"正在请求....")
}

+ (void)printRequestDealloc:(GYNetRequest *)request {
    GYNetDebugLog(@"\n<request-id:%@>-1个request已经被释放了", @(request.requestId));
}

+ (void)printResponseError:(NSError *)error request:(GYNetRequest *)request {
    GYNetDataLog(@"\n###########<response-id:%@>-%@", @(request.requestId), error.localizedDescription);
}

@end
