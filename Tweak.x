@interface SBFApplication : NSObject
@property (nonatomic, copy) NSString *applicationBundleIdentifier;
@end

@interface CCUIAppLauncherViewController : UIViewController
-(BOOL)isAlarm;
@end

@interface SBScheduledAlarmObserver
+(id)sharedInstance;
@end

@interface MTAlarm : NSObject
-(BOOL)isActiveAndEnabledForThisDevice;
-(NSDate *)nextFireDate;
@end

UILabel *alarmLabel;

%hook CCUIAppLauncherViewController
%new
-(BOOL)isAlarm{
	return [((SBFApplication *)[self valueForKey:@"_application"]).applicationBundleIdentifier isEqualToString:@"com.apple.mobiletimer"];
}
-(void)viewDidLoad{
	%orig;
	if([self isAlarm]){
		if(!alarmLabel){
			alarmLabel = [UILabel new];
			alarmLabel.font = [alarmLabel.font fontWithSize:10];
			alarmLabel.textColor = [UIColor whiteColor];
			alarmLabel.textAlignment = NSTextAlignmentCenter;
			alarmLabel.center = CGPointMake(self.view.frame.size.width/2, 12);
			alarmLabel.frame = CGRectMake(10,52,50,10);
		}
		dispatch_async(dispatch_get_main_queue(), ^{
    		[NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer){
    			MTAlarm *nextAlarm = [[[[%c(SBScheduledAlarmObserver) sharedInstance] valueForKey:@"_alarmManager"] valueForKey:@"_cache"] valueForKey:@"_nextAlarm"];
    			if(nextAlarm){
    				if([nextAlarm isActiveAndEnabledForThisDevice]){
    					NSDate *currentDate = [NSDate date];
    					NSDate *alarmDate = [nextAlarm nextFireDate];
						NSTimeInterval elapsedTime = [alarmDate timeIntervalSinceDate:currentDate];
    					div_t h = div(elapsedTime, 3600);
    					int hours = h.quot;
    					div_t m = div(h.rem, 60);
    					int minutes = m.quot;
    					int seconds = m.rem;
						alarmLabel.text = [[NSString stringWithFormat:@"%d:%d:%d", hours, minutes, seconds] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    				}
    				else{
    					alarmLabel.text = nil;
    				}
    			}
    			else{
    				alarmLabel.text = nil;
    			}
			}];
		});
		[self.view addSubview:alarmLabel];
	}
}
%end