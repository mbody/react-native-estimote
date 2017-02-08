#import "RNEstimote.h"

#import <EstimoteSDK/EstimoteSDK.h>

#import "RCTBridge.h"
#import "RCTLog.h"
#import "RCTEventDispatcher.h"
#import "RCTConvert.h"

@interface RNEstimote() <ESTBeaconManagerDelegate>

//#if TARGET_IPHONE_SIMULATOR
//@property (nonatomic, strong) ESTSimulatedBeaconManager *beaconManager;
//#else
//@property (nonatomic, strong) ESTBeaconManager *beaconManager;
//#endif

@property (nonatomic) ESTBeaconManager *beaconManager;

@end

@implementation RNEstimote

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
//#if TARGET_IPHONE_SIMULATOR
//        self.beaconManager = [ESTSimulatedbeaconManager new];
//#else
//        self.beaconManager = [ESTBeaconManager new];
//#endif
//        self.beaconManager.delegate = self;
        self.beaconManager = [ESTBeaconManager new];
        self.beaconManager.delegate = self;
    }
    return self;
}

//#pragma mark Exposed React Functions - Simulation
//
//RCT_EXPORT_METHOD(addNearableToSimulation:(NSString *)identifier type:(NSInteger)type zone:(NSInteger)zone rssi:(NSInteger)rssi)
//{
//#if TARGET_IPHONE_SIMULATOR
//    RCTLogInfo(@"addNearableToSimulation %@ %@ %@ %ld", identifier, [self nameForNearableType:(ESTNearableType)type], [self nameForNearableZone:zone], (long)rssi);
//    [self.beaconManager addNearableToSimulation:identifier withType:(ESTNearableType)type zone:(ESTNearableZone)zone rssi: rssi];
//#endif
//}
//
//RCT_EXPORT_METHOD(simulateZoneForNearable:(NSString *)identifier zone:(NSInteger)zone)
//{
//#if TARGET_IPHONE_SIMULATOR
//    RCTLogInfo(@"simulateZoneForNearable %@ %@", identifier, [self nameForNearableZone:zone]);
//    [self.beaconManager simulateZone:(ESTNearableZone)zone forNearable:identifier];
//#endif
//}
//
//RCT_EXPORT_METHOD(simulateDidEnterRegionForNearable:(NSString *)identifier)
//{
//#if TARGET_IPHONE_SIMULATOR
//    RCTLogInfo(@"simulateDidEnterRegionForNearable %@", identifier);
//    for (ESTNearable *nearable in self.beaconManager.nearables){
//        if([nearable.identifier isEqualToString:identifier]){
//            [self.beaconManager simulateDidEnterRegionForNearable:nearable];
//        }
//    }
//#endif
//}
//
//RCT_EXPORT_METHOD(simulateDidExitRegionForNearable:(NSString *)identifier)
//{
//#if TARGET_IPHONE_SIMULATOR
//    RCTLogInfo(@"simulateDidExitRegionForNearable %@", identifier);
//    for (ESTNearable *nearable in self.beaconManager.nearables){
//        if([nearable.identifier isEqualToString:identifier]){
//            [self.beaconManager simulateDidExitRegionForNearable:nearable];
//        }
//    }
//#endif
//}


#pragma mark Utility methods
- (CLBeaconRegion *) createBeaconRegion: (NSString *) identifier uuid: (NSString *) uuid major: (NSInteger) major minor:(NSInteger) minor
{
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];

    unsigned short mj = (unsigned short) major;
    unsigned short mi = (unsigned short) minor;

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID major:mj minor:mi identifier:identifier];

    beaconRegion.notifyEntryStateOnDisplay = YES;

    return beaconRegion;
}

- (CLBeaconRegion *) createBeaconRegion: (NSString *) identifier uuid: (NSString *) uuid major: (NSInteger) major
{
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];

    unsigned short mj = (unsigned short) major;

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID major:mj identifier:identifier];

    beaconRegion.notifyEntryStateOnDisplay = YES;

    return beaconRegion;
}

- (CLBeaconRegion *) createBeaconRegion: (NSString *) identifier uuid: (NSString *) uuid
{
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:identifier];

    beaconRegion.notifyEntryStateOnDisplay = YES;

    return beaconRegion;
}

- (CLBeaconRegion *) convertDictToBeaconRegion: (NSDictionary *) dict
{
    if (dict[@"minor"] == nil) {
        if (dict[@"major"] == nil) {
            return [self createBeaconRegion:[RCTConvert NSString:dict[@"identifier"]] uuid:[RCTConvert NSString:dict[@"uuid"]]];
        } else {
            return [self createBeaconRegion:[RCTConvert NSString:dict[@"identifier"]] uuid:[RCTConvert NSString:dict[@"uuid"]] major:[RCTConvert NSInteger:dict[@"major"]]];
        }
    } else {
        return [self createBeaconRegion:[RCTConvert NSString:dict[@"identifier"]] uuid:[RCTConvert NSString:dict[@"uuid"]] major:[RCTConvert NSInteger:dict[@"major"]] minor:[RCTConvert NSInteger:dict[@"minor"]]];
    }
}

- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"unknown";
        case CLProximityFar:        return @"far";
        case CLProximityNear:       return @"near";
        case CLProximityImmediate:  return @"immediate";
        default:
            return @"";
    }
}

- (NSString *)stringForRegionState:(CLProximity)proximity {
    switch (proximity) {
        case CLRegionStateUnknown:    return @"unknown";
        case CLRegionStateInside:     return @"inside";
        case CLRegionStateOutside:    return @"outside";
        default:
            return @"";
    }
}



#pragma mark Exposed React - Monitoring related methods

RCT_EXPORT_METHOD(startMonitoringForRegion:(NSDictionary *) dict)
{
    [self.beaconManager startMonitoringForRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopMonitoringForRegion:(NSDictionary *) dict)
{
    [self.beaconManager stopMonitoringForRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopMonitoringForAllRegions)
{
    [self.beaconManager stopMonitoringForAllRegions];
}

RCT_EXPORT_METHOD(requestStateForRegion:(NSDictionary *) dict)
{
    [self.beaconManager requestStateForRegion:[self convertDictToBeaconRegion:dict]];
}



#pragma mark Exposed React - Ranging related methods

RCT_EXPORT_METHOD(startRangingBeaconsForRegion:(NSDictionary *) dict)
{
    [self.beaconManager startRangingBeaconsForRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopRangingBeaconsInRegion:(NSDictionary *) dict)
{
    [self.beaconManager stopRangingBeaconsInRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopRangingBeaconsInAllRegions)
{
    [self.beaconManager stopRangingBeaconsInAllRegions];
}



#pragma mark Dispatched React - Ranging delegates

-(void) beaconManager:(CLLocationManager *)manager didRangeBeacons:
            (NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray *beaconArray = [[NSMutableArray alloc] init];

    for (CLBeacon *beacon in beacons) {
        [beaconArray addObject:@{
                                 @"uuid": [beacon.proximityUUID UUIDString],
                                 @"major": beacon.major,
                                 @"minor": beacon.minor,

                                 @"rssi": [NSNumber numberWithLong:beacon.rssi],
                                 @"proximity": [self stringForProximity: beacon.proximity],
                                 @"accuracy": [NSNumber numberWithDouble: beacon.accuracy]
                                 }];
    }

    NSDictionary *event = @{
                            @"region": @{
                                    @"identifier": region.identifier,
                                    @"uuid": [region.proximityUUID UUIDString],
                                    },
                            @"beacons": beaconArray
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didRangeBeacons" body:event];
}

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *_Nullable)region
                                    withError:(NSError *)error
{
    RCTLogInfo(@"rangingBeaconsDidFailForRegion %@", error);
    NSDictionary *event = @{
                            @"region": region.identifier,
                            @"uuid": [region.proximityUUID UUIDString],
                            @"error": error.localizedDescription
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"rangingBeaconsDidFailForRegion" body:event];
}

#pragma mark Dispatched React - Monitoring delegates

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    NSDictionary *event = @{
                            @"region": region.identifier,
                            @"uuid": [region.proximityUUID UUIDString],
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didEnterRegion" body:event];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    NSDictionary *event = @{
                            @"region": region.identifier,
                            @"uuid": [region.proximityUUID UUIDString],
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didExitRegion" body:event];
}

- (void)beaconManager:(id)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region
{
    NSDictionary *event = @{
                            @"region": region.identifier,
                            @"uuid": [region.proximityUUID UUIDString],
                            @"state": [self stringForRegionState:state]
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didDetermineState" body:event];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *_Nullable)region
                                    withError:(NSError *)error
{
    RCTLogInfo(@"monitoringDidFailForRegion %@", error);
    NSDictionary *event = @{
                            @"region": region.identifier,
                            @"uuid": [region.proximityUUID UUIDString],
                            @"error": error.localizedDescription
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"monitoringDidFailForRegion" body:event];
}

- (void)beaconManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    RCTLogInfo(@"didFailWithError %@", error);
    NSDictionary *event = @{
                            @"error": error.localizedDescription
                            };

    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didFailWithError" body:event];
}

#pragma mark Helpers - Enum Name Translations

//-(NSString *)nameForNearableZone:(ESTNearableZone)zone{
//    switch (zone) {
//        case ESTNearableZoneUnknown:
//            return @"ESTNearableZoneUnknown";
//
//        case ESTNearableZoneImmediate:
//            return @"ESTNearableZoneImmediate";
//
//        case ESTNearableZoneNear:
//            return @"ESTNearableZoneNear";
//
//        case ESTNearableZoneFar:
//            return @"ESTNearableZoneFar";
//    }
//}
//
//
//-(NSDictionary *)dictionaryForNearable:(ESTNearable*)nearable{
//    return @{ @"identifier" : nearable.identifier, @"type" : [self nameForNearableType:nearable.type], @"zone" : [self nameForNearableZone:nearable.zone], @"rssi": [NSNumber numberWithLong:nearable.rssi] };
//}
//
//- (NSDictionary *)constantsToExport
//{
//    return @{
//             @"ESTNearableTypeUnknown": [NSNumber numberWithInt:ESTNearableTypeUnknown],
//             @"ESTNearableTypeDog": [NSNumber numberWithInt:ESTNearableTypeDog],
//             @"ESTNearableTypeCar": [NSNumber numberWithInt:ESTNearableTypeCar],
//             @"ESTNearableTypeFridge": [NSNumber numberWithInt:ESTNearableTypeFridge],
//             @"ESTNearableTypeBag": [NSNumber numberWithInt:ESTNearableTypeBag],
//             @"ESTNearableTypeBike": [NSNumber numberWithInt:ESTNearableTypeBike],
//             @"ESTNearableTypeChair": [NSNumber numberWithInt:ESTNearableTypeChair],
//             @"ESTNearableTypeBed": [NSNumber numberWithInt:ESTNearableTypeBed],
//             @"ESTNearableTypeDoor": [NSNumber numberWithInt:ESTNearableTypeDoor],
//             @"ESTNearableTypeShoe": [NSNumber numberWithInt:ESTNearableTypeShoe],
//             @"ESTNearableTypeGeneric": [NSNumber numberWithInt:ESTNearableTypeGeneric],
//             @"ESTNearableTypeAll": [NSNumber numberWithInt:ESTNearableTypeAll],
//
//             /**
//              *  Physical orientation of the device in 3D space.
//              */
//             // typedef NS_ENUM(NSInteger, ESTNearableOrientation)
//             @"ESTNearableOrientationUnknown": [NSNumber numberWithInt:ESTNearableOrientationUnknown],
//             @"ESTNearableOrientationHorizontal": [NSNumber numberWithInt:ESTNearableOrientationHorizontal],
//             @"ESTNearableOrientationHorizontalUpsideDown": [NSNumber numberWithInt:ESTNearableOrientationHorizontalUpsideDown],
//             @"ESTNearableOrientationVertical": [NSNumber numberWithInt:ESTNearableOrientationVertical],
//             @"ESTNearableOrientationVerticalUpsideDown": [NSNumber numberWithInt:ESTNearableOrientationVerticalUpsideDown],
//             @"ESTNearableOrientationLeftSide": [NSNumber numberWithInt:ESTNearableOrientationLeftSide],
//             @"ESTNearableOrientationRightSide": [NSNumber numberWithInt:ESTNearableOrientationRightSide],
//
//             /**
//              *  Proximity zone related to distance from the device.
//              */
//             // typedef NS_ENUM(NSInteger, ESTNearableZone)
//             @"ESTNearableZoneUnknown": [NSNumber numberWithInt:ESTNearableZoneUnknown],
//             @"ESTNearableZoneImmediate": [NSNumber numberWithInt:ESTNearableZoneImmediate],
//             @"ESTNearableZoneNear": [NSNumber numberWithInt:ESTNearableZoneNear],
//             @"ESTNearableZoneFar": [NSNumber numberWithInt:ESTNearableZoneFar],
//
//             /**
//              *  Type of firmware running on the device.
//              */
//             // typedef NS_ENUM(NSInteger, ESTNearableFirmwareState)
//             @"ESTNearableFirmwareStateBoot": [NSNumber numberWithInt:ESTNearableFirmwareStateBoot],
//             @"ESTNearableFirmwareStateApp": [NSNumber numberWithInt:ESTNearableFirmwareStateApp]
//             };
//}

@end
