//
//  BCKEAN8Code.m
//  BarCodeKit
//
//  Created by Oliver Drobnik on 8/9/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "BCKEAN8Code.h"
#import "BCKEANCodeCharacter.h"
#import "NSError+BCKCode.h"

@implementation BCKEAN8Code

#pragma mark - Helper Methods

- (NSUInteger)_digitAtIndex:(NSUInteger)index
{
	NSString *digitStr = [self.content substringWithRange:NSMakeRange(index, 1)];
	return [digitStr integerValue];
}

- (NSUInteger)_codeVariantIndexForDigitAtIndex:(NSUInteger)index withVariantPattern:(char *)variantPattern
{
	NSAssert(index>=0 && index<8, @"Index must be from 0 to 7");
	
	char variantForDigit = variantPattern[index];
	NSUInteger variantIndex = BCKEANCodeCharacterEncoding_L;
	
	if (variantForDigit == 'G')
	{
		variantIndex = BCKEANCodeCharacterEncoding_G;
	}
	else if (variantForDigit == 'R')
	{
		variantIndex = BCKEANCodeCharacterEncoding_R;
	}
	
	return variantIndex;
}

#pragma mark - Subclassing Methods

+ (BOOL)canEncodeContent:(NSString *)content error:(NSError *__autoreleasing *)error
{
	NSUInteger length = [content length];
	
	if (length != 8)
	{
		if (error)
		{
			NSString *message = [NSString stringWithFormat:@"%@ requires content to be 8 digits", NSStringFromClass([self class])];
			*error = [NSError BCKCodeErrorWithMessage:message];
		}
		
		return NO;
	}
	
	for (NSUInteger index=0; index<[content length]; index++)
	{
		NSString *character = [content substringWithRange:NSMakeRange(index, 1)];
		char c = [character UTF8String][0];
		
		if (!(c>='0' && c<='9'))
		{
			if (error)
			{
				NSString *message = [NSString stringWithFormat:@"%@ cannot encode '%@' at index %d", NSStringFromClass([self class]), character, (int)index];
				*error = [NSError BCKCodeErrorWithMessage:message];
			}
			
			return NO;
		}
	}
	
	return YES;
}

+ (NSString *)barcodeStandard
{
	return @"International standard ISO/IEC 15420";
}

+ (NSString *)barcodeDescription
{
	return @"EAN-8";
}

- (NSUInteger)horizontalQuietZoneWidth
{
	return 7;
}

// generate the code characters from the content
- (NSArray *)codeCharacters
{
	// If the array was created earlier just return it
	if (_codeCharacters)
	{
		return _codeCharacters;
	}
   
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	// variant pattern is fixed
	static char *variant_pattern = "LLLLRRRR";
	
	// start marker
	[tmpArray addObject:[BCKEANCodeCharacter endMarkerCodeCharacter]];
	
	for (NSUInteger index = 0; index < 8; index ++)
	{
		NSUInteger digit = [self _digitAtIndex:index];
		BCKEANCodeCharacterEncoding encoding = [self _codeVariantIndexForDigitAtIndex:index withVariantPattern:variant_pattern];
		
		[tmpArray addObject:[BCKEANCodeCharacter codeCharacterForDigit:digit encoding:encoding]];
		
		if (index == 3)
		{
			// middle marker
			[tmpArray addObject:[BCKEANCodeCharacter middleMarkerCodeCharacter]];
		}
	}
	
	// end marker
	[tmpArray addObject:[BCKEANCodeCharacter endMarkerCodeCharacter]];
	
	_codeCharacters = [tmpArray copy];
	return _codeCharacters;
}

- (NSString *)defaultCaptionFontName
{
	return @"OCRB";
}

- (CGFloat)aspectRatio
{
	return 26.73 / 21.31;
}

- (BOOL)markerBarsCanOverlapBottomCaption
{
	return YES;
}

- (BOOL)allowsFillingOfEmptyQuietZones
{
	return YES;
}

@end
