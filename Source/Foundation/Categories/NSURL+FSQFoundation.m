//
//  NSURL+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 5/17/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSURL+FSQFoundation.h"

#import "FSQAsserter.h"
#import "FSQLogging.h"

enum {
	kFSQ_NSURLComponentBase = 1
	, kFSQ_NSURLComponentFilename = 2
	, kFSQ_NSURLComponentScaleFactor = 3
	, kFSQ_NSURLComponentScale = 4
	, kFSQ_NSURLComponentExtension = 5
};


static NSString *kFSQ_NSURLWithOptionalScaleExpression = @"^(.+/(\\w+))(@([0-9.]+)x)?(\\.([^.]+))$";


@implementation NSURL (FSQFoundation)

- (NSString *) scaleModifier {
	NSString *scaleModifier = nil;
	NSString *filename = [[[self path] lastPathComponent] stringByDeletingPathExtension];
	
	NSError *error = nil;
    // TODO: FIX THIS shouldn't have to check if the filename is valid... this code has trust issues.
//    if (filename)
//    {
        NSRegularExpression *scaleModifierExpression = [NSRegularExpression regularExpressionWithPattern:@"@[0-9.]+x$" options:0 error:&error];
        NSRange modifierRange = [scaleModifierExpression rangeOfFirstMatchInString:filename options:0 range:NSMakeRange(0, filename.length)];
        if (modifierRange.location != NSNotFound) {
            scaleModifier = [filename substringWithRange:modifierRange];
        }
//    }
	return scaleModifier;
}
- (float) scale {
	float scale = 1;
	NSString *scaleModifier = [self scaleModifier];
	if (scaleModifier) {
		NSRegularExpression *scaleExpression = [NSRegularExpression regularExpressionWithPattern:@"@([0-9.]+)x" options:0 error:NULL];
		NSTextCheckingResult *match = [scaleExpression firstMatchInString:scaleModifier options:0 range:NSMakeRange(0, scaleModifier.length)];
		if (match) {
			NSRange scaleRange = [match rangeAtIndex:1];
			if (scaleRange.location != NSNotFound) {
				scale = [[scaleModifier substringWithRange:scaleRange] floatValue];
			}
		}
	}
	return scale;
}

- (NSURL *) URLBySettingScale:(float)scale {
	float currentScale = [self scale];
	NSString *URLString;
	if (scale !=  currentScale) {				
		NSString *extension = @"";
		NSString *scaleModifier = @"";
		NSString *base;
		
		NSString *string = [self absoluteString];
		NSRegularExpression *URLExpression = [NSRegularExpression regularExpressionWithPattern:kFSQ_NSURLWithOptionalScaleExpression options:0 error:NULL];
		NSRange keyRange = NSMakeRange(0, string.length);
		NSTextCheckingResult *match = [URLExpression firstMatchInString:string options:0 range:keyRange];
		if (match) {
			base = [string substringWithRange:[match rangeAtIndex:kFSQ_NSURLComponentBase]];
			NSRange scaleRange = [match rangeAtIndex:kFSQ_NSURLComponentScaleFactor];
			if (scaleRange.location != NSNotFound && scaleRange.length > 0) {
				scaleModifier = [string substringWithRange:scaleRange];
			}
			if (scale > 1.f) {
				scaleModifier = [NSString stringWithFormat:@"@%.0fx",scale];
			}

			NSRange extensionRange = [match rangeAtIndex:kFSQ_NSURLComponentExtension];
			if (extensionRange.location != NSNotFound ) {
				extension = [string substringWithRange:extensionRange];
			}
		} else {
			base = string;
		}
		
		NSString *stringWithModifier = base;
		stringWithModifier = [stringWithModifier stringByAppendingString:scaleModifier];
		stringWithModifier = [stringWithModifier stringByAppendingString:extension];

		URLString = stringWithModifier;
		
	} else {
		URLString = [self absoluteString];

	}
	NSURL *scaledURL = [NSURL URLWithString:URLString];
	FSQAssert(scaledURL != nil, @"Failed to created scaled URL!");
	return scaledURL;
}

- (NSURL *) URLByDeletingScale {
	NSString *extension = @"";
	NSString *base;
	
	NSString *string = [self absoluteString];
	NSRegularExpression *URLExpression = [NSRegularExpression regularExpressionWithPattern:kFSQ_NSURLWithOptionalScaleExpression options:0 error:NULL];
	NSRange keyRange = NSMakeRange(0, string.length);
	NSTextCheckingResult *match = [URLExpression firstMatchInString:string options:0 range:keyRange];
	NSRange scaleRange = [match rangeAtIndex:kFSQ_NSURLComponentScaleFactor];
	if (scaleRange.location != NSNotFound && scaleRange.length > 0) {
		base = [string substringWithRange:[match rangeAtIndex:kFSQ_NSURLComponentBase]];
		
		NSRange extensionRange = [match rangeAtIndex:kFSQ_NSURLComponentExtension];
		if (extensionRange.location != NSNotFound ) {
			extension = [string substringWithRange:extensionRange];
		}
	} else {
		base = string;
	}
	
	NSString *stringWithoutModifier = base;
	stringWithoutModifier = [stringWithoutModifier stringByAppendingString:extension];
	
	NSURL *descaledURL = [NSURL URLWithString:stringWithoutModifier];
	FSQAssert(descaledURL != nil, @"Failed to create descaled URL!");
	return descaledURL;
}



@end
