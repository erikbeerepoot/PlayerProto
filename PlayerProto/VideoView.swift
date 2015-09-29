//
//  VideoView.swift
//  PlayerProto
//
//  Created by mediacore-erik on 2015-09-27.
//  Copyright © 2015 Workday. All rights reserved.
//

import Foundation
import UIKit

let kLandscapeWidthFactor = 0.33;
let kPortraitWidthFactor = 0.5;
let numberOfSwipesForTimeline = 2.0;
let kTouchRectBoundary = 150.0;
let kMargin : CGFloat = 50.0;

class VideoOverlayView : UIView {
    //state
    var shouldShowTimeline : Bool = false;
    var dragging = false;

    
    var velocityEstimator : VelocityEstimator? = nil;
    var startPosition : CGPoint = CGPointMake(0.0, 0.0);
    var endPosition : CGPoint = CGPointMake(0.0, 0.0);
    var position : Double = 0.0;
    
    //Visual properties
    var timelineColour : UIColor = UIColor.redColor();
    var overlayColour  : UIColor = UIColor.grayColor();
    var lineWidth : Double = 500;
    
    //touch target
    var touchRect : CGRect = CGRectMake(0.0, 0.0, 0.0, 0.0);
    
    @IBOutlet weak var velocityLabel : UILabel?;
    
    
    override init(frame : CGRect) {
        super.init(frame : frame);
        self.setupDrawingParameters();
        velocityEstimator = VelocityEstimator(size:20,touchView:self);
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder : aDecoder);
        self.setupDrawingParameters();
        velocityEstimator = VelocityEstimator(size:20,touchView:self);
    }

    func setupDrawingParameters() -> () {
        lineWidth = numberOfSwipesForTimeline*Double(self.frame.size.width);
        
        startPosition = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        endPosition = startPosition;
        
        //Compute the point where the line ends
        endPosition.x = startPosition.x + CGFloat(lineWidth);
        
        //Initialize touch parameters
        touchRect.origin.x = startPosition.x;
        touchRect.size.width = (endPosition.x - startPosition.x);
        touchRect.origin.y = startPosition.y - CGFloat(kTouchRectBoundary);
        touchRect.size.height = 2 * CGFloat(kTouchRectBoundary);
    }
    
    
    func displayTimeline() -> (){
        
    }
    
    override func drawRect(rect: CGRect) {
        //Create the path
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, startPosition.x, startPosition.y);
        CGPathAddLineToPoint(path, nil, endPosition.x, endPosition.y);
        
        //Draw the path
        let context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColor(context, CGColorGetComponents(self.timelineColour.CGColor));
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //check if close enough to timeline to drag
        if(CGRectContainsPoint(touchRect,touches.first!.locationInView(self))){
            velocityEstimator?.pushTouch(touches.first!);
            dragging = true;
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //if we're scrubbing, move line
        if(dragging){
            //constrain to FIFO behaviour
            velocityEstimator?.pushTouch(touches.first!);
            NSLog("velocity: %f",velocityEstimator!.velocity);
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        dragging = false;
    }
    
    
    
    
};

//Esimates the x-velocity of touches
class VelocityEstimator {
    //mutated state
    var touchLocations : Array<CGPoint>? = nil;
    var timestamps     : Array<NSTimeInterval>? = nil;
    var velocity = 0.0;
    
    //fixed on init
    var view : UIView? = nil;
    var size = 0;
    
    init(size : Int, touchView view : UIView){
        assert(size > 1);
        self.view = view;
        self.size = size;
        
        touchLocations = Array();
        timestamps = Array();
    }
    
    //Behaves like a FIFO on each array
    func pushTouch(touch : UITouch){
        //add objects to the end
        touchLocations?.append(touch.locationInView(view));
        timestamps?.append(touch.timestamp);
        
        //remove first objects
        if(touchLocations?.count > size){
            touchLocations?.removeFirst();
            timestamps?.removeFirst();
        }
        computeVelocity();
    }
    
    func computeVelocity(){
        guard touchLocations?.count == size else {
            return;
        }
        
        velocity = 0.0;
        for(var idx=1;idx<touchLocations!.count;++idx){
            let distance  = Double(touchLocations![idx-1].x - touchLocations![idx].x);
            velocity += distance / (timestamps![idx-1] - timestamps![idx]);
        }
    }
    
};
