//
//  FSQZlib.m
//  FivesquareKit
//
//  Created by John Clayton on 8/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQZlib.h"

#import <zlib.h>
#import <stdio.h>

#define CHUNK 16384

@implementation FSQZlib

//+ (BOOL) unpackFile:(NSString *)sourcePath toFile:(NSString *)destPath {
//	BOOL success = YES;
//	gzFile file = gzopen([sourcePath UTF8String], "rb");
//	FILE *dest = fopen([destPath UTF8String], "w");
//	
//	unsigned char buffer[CHUNK];
//	size_t uncompressedLength;
//	while((uncompressedLength = gzread(file, buffer, CHUNK)) > 0) {
//		success = fwrite(buffer, 1, uncompressedLength, dest) == uncompressedLength;
//		if(!success)
//			break;
//	}
//	fclose(dest);
//	gzclose(file);
//	
//	return success;
//}
@end
