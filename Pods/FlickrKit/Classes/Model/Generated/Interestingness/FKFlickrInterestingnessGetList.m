//
//  FKFlickrInterestingnessGetList.m
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrInterestingnessGetList.h" 

@implementation FKFlickrInterestingnessGetList



- (BOOL) needsLogin {
    return NO;
}

- (BOOL) needsSigning {
    return NO;
}

- (FKPermission) requiredPerms {
    return -1;
}

- (NSString *) name {
    return @"flickr.interestingness.getList";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.date) {
		[args setValue:self.date forKey:@"date"];
	}
	if(self.extras) {
		[args setValue:self.extras forKey:@"extras"];
	}
	if(self.per_page) {
		[args setValue:self.per_page forKey:@"per_page"];
	}
	if(self.page) {
		[args setValue:self.page forKey:@"page"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrInterestingnessGetListError_NotAValidDateString:
			return @"Not a valid date string.";
		case FKFlickrInterestingnessGetListError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrInterestingnessGetListError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrInterestingnessGetListError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrInterestingnessGetListError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrInterestingnessGetListError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrInterestingnessGetListError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrInterestingnessGetListError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrInterestingnessGetListError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
