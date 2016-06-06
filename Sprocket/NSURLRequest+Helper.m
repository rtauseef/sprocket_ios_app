
#import "NSURLRequest+Helper.h"

@implementation NSURLRequest (Helper)

+ (NSString *)userAgent {
	NSString *userAgent;
	NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *locale = [[NSLocale currentLocale] localeIdentifier];
	userAgent = [NSString stringWithFormat:@"Photogram/%@ (%@; %@; %@; %@; Scale: %2.1f)",
				 versionNumber,
				 [[UIDevice currentDevice] model],
				 [[UIDevice currentDevice] systemName],
				 [[UIDevice currentDevice] systemVersion],
				 locale,
				 ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)];
	return userAgent;
}

@end
