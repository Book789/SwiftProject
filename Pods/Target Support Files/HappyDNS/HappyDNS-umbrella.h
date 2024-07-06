#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QNDnsError.h"
#import "QNDnsManager.h"
#import "QNDomain.h"
#import "QNLruCache.h"
#import "QNNetworkInfo.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"
#import "QNDnsDefine.h"
#import "QNDnsMessage.h"
#import "QNDnsRequest.h"
#import "QNDnsResolver.h"
#import "QNDnsResponse.h"
#import "QNDnsUdpResolver.h"
#import "QNDohResolver.h"
#import "QNDnspodEnterprise.h"
#import "QNHijackingDetectWrapper.h"
#import "QNHosts.h"
#import "QNResolver.h"
#import "QNResolvUtil.h"
#import "QNTxtResolver.h"
#import "NSData+QNRW.h"
#import "QNAsyncUdpSocket.h"
#import "QNDes.h"
#import "QNGetAddrInfo.h"
#import "QNHex.h"
#import "QNIP.h"
#import "QNMD5.h"
#import "HappyDNS.h"

FOUNDATION_EXPORT double HappyDNSVersionNumber;
FOUNDATION_EXPORT const unsigned char HappyDNSVersionString[];

