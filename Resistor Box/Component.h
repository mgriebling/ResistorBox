//
//  Component.h
//  Resistor Box
//
//  Created by Michael Griebling on 3May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Types;

@interface Component : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDecimalNumber * tolerance;
@property (nonatomic, retain) Types *isTypeOf;

@end
