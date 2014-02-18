//
//  Types.h
//  Resistor Box
//
//  Created by Michael Griebling on 3May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Component;

@interface Types : NSManagedObject

@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSSet *hasChild;
@end

@interface Types (CoreDataGeneratedAccessors)

- (void)addHasChildObject:(Component *)value;
- (void)removeHasChildObject:(Component *)value;
- (void)addHasChild:(NSSet *)values;
- (void)removeHasChild:(NSSet *)values;

@end
