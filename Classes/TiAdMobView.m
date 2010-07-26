/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAdMobView.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "Webcolor.h"

#define AD_REFRESH_PERIOD 12.5 // display fresh ads every 12.5 seconds


@implementation TiAdMobView
@synthesize publisher, test, refresh, primaryTextColor, secondaryTextColor;


#pragma mark Cleanup 

-(void)dealloc
{
	self.publisher = nil;
	self.backgroundColor = nil;
	self.primaryTextColor = nil;
	self.secondaryTextColor = nil;
	
	RELEASE_TO_NIL(refreshTimer);
	RELEASE_TO_NIL(admob);
	[super dealloc];
}


#pragma Internal


#pragma Delegates
-(void)initializeState
{
	[super initializeState];
	self.backgroundColor = [UIColor clearColor];
	self.primaryTextColor = [UIColor blackColor];
	self.secondaryTextColor = [UIColor blackColor];
	self.test = NO;
	self.publisher = @"";
	self.refresh = AD_REFRESH_PERIOD;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	NSLog(@"size=%f,%f",bounds.size.width, bounds.size.height);
	if (admob==nil)
	{
        admob = [[AdMobView requestAdOfSize:bounds.size withDelegate:self] retain];
        [self addSubview:admob];
	}

	//admob.frame = bounds;
}

- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return self.publisher;
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return [[TiApp app] controller];
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
	return self.backgroundColor;
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
	return self.primaryTextColor;
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
	return self.secondaryTextColor;
}

- (BOOL)useTestAd {
	return test;
}

- (void)refreshAd:(NSTimer *)timer {
	[admob requestFreshAd];
}

- (void)didReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did receive ad");
	[refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(refresh > AD_REFRESH_PERIOD ? refresh : AD_REFRESH_PERIOD)
													target:self
												  selector:@selector(refreshAd:)
												  userInfo:nil
												   repeats:YES];
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did fail to receive ad");
	//[adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
	//[adMobAd release];
	//adMobAd = nil;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
}

#pragma Properties

-(void)setPublisher_:(id)publisher_
{
	self.publisher = [TiUtils stringValue:publisher_];
}

-(void)setTest_:(id)test_
{
	self.test = [TiUtils boolValue:test_];
}

-(void)setRefresh_:(id)refresh_
{
	self.refresh = [TiUtils floatValue:refresh_];
}

-(void)setPrimaryTextColor_:(id)color
{
	if ([color isKindOfClass:[UIColor class]])
	{
		self.primaryTextColor = color;
	}
	else
	{
		TiColor *ticolor = [TiUtils colorValue:color];
		self.primaryTextColor = [ticolor _color];
	}
}

-(void)setSecondaryTextColor_:(id)color
{
	if ([color isKindOfClass:[UIColor class]])
	{
		self.secondaryTextColor = color;
	}
	else
	{
		TiColor *ticolor = [TiUtils colorValue:color];
		self.secondaryTextColor = [ticolor _color];
	}
}

#pragma Public APIs

@end
