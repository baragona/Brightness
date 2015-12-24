//
//  GammaTable.m
//  Brightness
//
//  Created by Kevin on 3/2/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import "GammaTable.h"

typedef struct {
    uint32_t sampleCount;
    CGGammaValue *redTable;
    CGGammaValue *greenTable;
    CGGammaValue *blueTable;
} gammaTable;

gammaTable * allocGammaTable(uint32_t capacity){
    gammaTable * table = malloc(sizeof(gammaTable));
    table->redTable  = malloc(capacity*sizeof(CGGammaValue));
    table->greenTable= malloc(capacity*sizeof(CGGammaValue));
    table->blueTable = malloc(capacity*sizeof(CGGammaValue));
    return table;
}

void freeGammaTable(gammaTable * table){
    free(table->redTable);
    free(table->greenTable);
    free(table->blueTable);
    free(table);
}

gammaTable * getGammaTableForDisplay(CGDirectDisplayID display){
    uint32_t capacity = CGDisplayGammaTableCapacity(display);
    gammaTable * table = allocGammaTable(capacity);
    CGError err = CGGetDisplayTransferByTable (display, capacity, table->redTable, table->greenTable, table->blueTable, &table->sampleCount );
    if(err){
        freeGammaTable(table);
        return NULL;
    }else{
        return table;
    }
}



gammaTable * copyGammaTable(gammaTable * table){
    gammaTable * copy = allocGammaTable(table->sampleCount);
    copy->sampleCount = table->sampleCount;
    for(int i=0; i<table->sampleCount; i++){
        copy->redTable[i]   = table->redTable[i];
        copy->greenTable[i] = table->greenTable[i];
        copy->blueTable[i]  = table->blueTable[i];
    }
    return copy;
}

CGError setGammaTableForDisplay(CGDirectDisplayID display,gammaTable * table){
    CGError err = CGSetDisplayTransferByTable (display, table->sampleCount, table->redTable, table->greenTable, table->blueTable );
    return err;
}


@implementation GammaTable

- init{
    self = [super init];
    self.length = 0;
    self.redTable = [NSMutableArray array];
    self.greenTable = [NSMutableArray array];
    self.blueTable = [NSMutableArray array];
    return self;
}

- (GammaTable*)clone{
    GammaTable *new = [GammaTable alloc];
    new.length = self.length;
    new.redTable   = [self.redTable   mutableCopy];
    new.greenTable = [self.greenTable mutableCopy];
    new.blueTable  = [self.blueTable  mutableCopy];
    return new;
}

- (GammaTable*)copyWithBrightness:(float) brightness{
    GammaTable * new = [self clone];
    for(int i=0;i<self.length;i++){
        new.redTable[i]   = @(brightness*[new.redTable[i] floatValue]);
        new.greenTable[i] = @(brightness*[new.greenTable[i] floatValue]);
        new.blueTable[i]  = @(brightness*[new.blueTable[i] floatValue]);
    }
    return new;
}

+ (GammaTable*) tableForDisplay:(CGDirectDisplayID) display {
    GammaTable * obj = [[GammaTable alloc] init];
    gammaTable * table = getGammaTableForDisplay(display);
    
    if(table){
        obj.length = table->sampleCount;
        
        for(int i=0; i<table->sampleCount; i++){
            obj.redTable[i]   = @( table->redTable[i] );
            obj.greenTable[i] = @( table->greenTable[i] );
            obj.blueTable[i]  = @( table->blueTable[i] );
        }
        
        freeGammaTable(table);
        return obj;
    }else{
        return nil;
    }
    
}

- (CGError) applyToDisplay:(CGDirectDisplayID) display {
    gammaTable * table = allocGammaTable(self.length);
    table->sampleCount = self.length;
    for(int i=0; i<self.length; i++){
        table->redTable[i]   = [self.redTable[i] floatValue];
        table->greenTable[i] = [self.greenTable[i] floatValue];
        table->blueTable[i]  = [self.blueTable[i] floatValue];
    }
    CGError err = setGammaTableForDisplay(display, table);
    freeGammaTable(table);
    return err;
}

@end
