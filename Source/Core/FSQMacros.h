//
//  FSQMacros.h
//  FivesquareKit
//
//  Created by John Clayton on 6/4/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#define FSQ_MAYBE_UNUSED __attribute__((unused))


#define FSQWeakSelf(var) __weak __typeof__((__typeof__(self))self) var = self

#define i18n(string,comment) NSLocalizedString(string,comment)


#ifndef NS_RETURNS_RETAINED
	#if __has_feature(attribute_ns_returns_retained)
		#define NS_RETURNS_RETAINED __attribute__((attribute_ns_returns_retained))
	#else
		#define NS_RETURNS_RETAINED
	#endif
#endif

#ifndef NS_RETURNS_NOT_RETAINED
	#if __has_feature(attribute_ns_returns_not_retained)
		#define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
	#else
		#define NS_RETURNS_NOT_RETAINED
	#endif
#endif

#ifndef NS_RETURNS_AUTORELEASED
	#if __has_feature(attribute_ns_returns_autoreleased)
		#define NS_RETURNS_AUTORELEASED __attribute__((attribute_ns_returns_autoreleased))
	#else
		#define NS_RETURNS_AUTORELEASED
	#endif
#endif

//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
//	#define ARC_SUPPORTS_DISPATCH_OBJECTS 0
//#else
//	#define ARC_SUPPORTS_DISPATCH_OBJECTS 1
//#endif