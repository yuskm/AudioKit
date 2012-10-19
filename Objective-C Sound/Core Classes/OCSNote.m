//
//  OCSNote.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNote.h"
#import "OCSManager.h"

@interface OCSNote () {
    int _myID;
    NSMutableArray *propOrder;
    BOOL isPlayingP;
}
@end


@implementation OCSNote

@synthesize instrument;
@synthesize properties;
@synthesize duration;

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)init
{
    self = [super init];
    if (self) {
        if (currentID > 99000) {
            [OCSNote resetID];
        }
        _myID = currentID++;
        
        isPlayingP = NO;
        duration = [OCSNoteProperty duration];
        [self addProperty:duration];

        properties = [[NSMutableDictionary alloc] init];
        propOrder = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)anInstrument
             forDuration:(float)noteDuration {
    self = [self init];
    if (self) {
        instrument = anInstrument;
        duration.value = noteDuration;
    }
    return self;
}

- (void)setInstrument:(OCSInstrument *)instr {
    instrument = instr;
    [instrument addNoteProperty:duration];
}

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    return [self initWithInstrument:anInstrument forDuration:-1];
}

- (void)updateProperties {
    if (isPlayingP) {
        [[OCSManager sharedOCSManager] updateNote:self];
    }
}

- (void)play {
    [[OCSManager sharedOCSManager] updateNote:self];
    isPlayingP = YES;
}

- (void)stop {
    [[OCSManager sharedOCSManager] stopNote:self];
    isPlayingP = NO;
}

- (NSString *)stringForCSD;
{
    float eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
    NSMutableString *scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 %f", eventNumber, duration.value];
    for (NSString* key in propOrder) {
        OCSNoteProperty *prop = [properties objectForKey:key];
        [scoreLine appendFormat:@" %f", [prop value]];
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)stopStringForCSD;
{
    float eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
    NSString *scoreLine = [NSString stringWithFormat:@"i -%0.5f 0 0.1", eventNumber];
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (void) addProperty:(OCSNoteProperty *)newProperty
            withName:(NSString *)name
{
    // AOP the name functionality may not be working
    [self.properties setValue:newProperty forKey:name];
    [propOrder addObject:name];
    [newProperty setPValue:propOrder.count +3];
    [newProperty setNote:self];
}

- (void) addProperty:(OCSNoteProperty *)newProperty
{
    [self addProperty:newProperty withName:[newProperty description]];
}


@end
