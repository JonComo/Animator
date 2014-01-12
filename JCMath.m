//
//  JCMath.m
//  MyNeuralNetwork
//
//  Created by Jon Como on 11/26/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import "JCMath.h"

@implementation JCMath

#pragma Math functions

+(float)angleFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    float angle;
    
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    
    angle = atan2f(dy, dx);
    
    return angle;
}

+(double)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 sorting:(BOOL)sorting
{
    double dx = (point2.x-point1.x);
    double dy = (point2.y-point1.y);
    return sorting ? dx*dx + dy*dy : sqrt(dx*dx + dy*dy);
}

+(CGPoint)pointFromPoint:(CGPoint)point pushedBy:(float)pushAmount inDirection:(float)radians
{
    point.x += pushAmount * cosf(radians);
    point.y += pushAmount * sinf(radians);
    
    return point;
}

+(float)mapValue:(float)value range:(CGPoint)range1 range:(CGPoint)range2
{
    return range2.y + (value - range1.x) * (range2.x - range2.y) / (range1.y - range1.x);
}

+(int)turnAngle:(float)angle towardsDesiredAngle:(float)desiredAngle
{
    float angle1 = angle;
	float angle2 = desiredAngle;
    
	int angle1Type = 1;
	int angle2Type = 1;
	int turn = 0;
    
	if (angle1<0) {
		angle1 += 360;
	}
	if (angle2<0) {
		angle2 += 360;
	}
	//calculate angle1 sector
	if (angle1>=0 && angle1<90) {
		angle1Type = 1;
	} else if (angle1>=90 && angle1<180) {
		angle1Type = 2;
		angle1 -= 90;
	} else if (angle1>=180 && angle1<270) {
		angle1Type = 3;
		angle1 -= 180;
	} else {
		angle1Type = 4;
		angle1 -= 270;
	}
    
	//calculate angle2 sector
	if (angle2>=0 && angle2<90) {
		angle2Type = 1;
	} else if (angle2>=90 && angle2<180) {
		angle2Type = 2;
		angle2 -= 90;
	} else if (angle2>=180 && angle2<270) {
		angle2Type = 3;
		angle2 -= 180;
	} else {
		angle2Type = 4;
		angle2 -= 270;
	}
    
	//check variations
	if (angle1Type == angle2Type) {
		if (angle1>angle2) {
			turn = 1;
		} else {
			turn = 0;
		}
	}
	if (angle1Type+1 == angle2Type) {
		turn = 0;
	}
	if (angle1Type-1 == angle2Type) {
		turn = 1;
	}
	if (angle1Type-3 == angle2Type) {
		turn = 0;
	}
	if (angle1Type+3 == angle2Type) {
		turn = 1;
	}
	if (angle1Type+2 == angle2Type || angle1Type-2 == angle2Type) {
		if (angle1>angle2) {
			turn = 0;
		} else {
			turn = 1;
		}
	}
    
	if(turn == 0){
		return 1;
	}else{
		return -1;
	}
}

@end