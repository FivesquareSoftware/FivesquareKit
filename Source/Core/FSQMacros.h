//
//  FSQMacros.h
//  FivesquareKit
//
//  Created by John Clayton on 6/4/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#define FSQ_MAYBE_UNUSED __attribute__((unused))


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

