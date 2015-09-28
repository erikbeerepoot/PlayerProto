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
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder : aDecoder);
        self.setupDrawingParameters();
        
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
    
    
    //keep a number of touches and use it to compute velocity
    var touchFIFO : NSMutableArray = NSMutableArray();
    let kFifoLength  = 20;
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //check if close enough to timeline to drag
        if(CGRectContainsPoint(touchRect,touches.first!.locationInView(self))){
            touchFIFO.addObject(touches.first!);
            dragging = true;
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //if we're scrubbing, move line
        if(dragging){
            //constrain to FIFO behaviour
            touchFIFO.addObject(touches.first!);
            if(touchFIFO.count > kFifoLength){
                touchFIFO.removeObjectAtIndex(0);
            }
            
            //compute average velocity
            var velocity : Double = 0.0;
            for(var touchIdx=1;touchIdx<touchFIFO.count;++touchIdx){
                velocity += Double(touchFIFO.objectAtIndex(touchIdx).locationInView(self).x - touchFIFO.objectAtIndex(touchIdx).locationInView(self).x) / (touchFIFO[touchIdx].timestamp - touchFIFO[touchIdx].timestamp);
            }
            velocity /= Double(touchFIFO.count);
            self.velocityLabel?.text = String(velocity);
            NSLog("Velocity: %f", velocity);
            
            
            
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchFIFO.removeAllObjects();
        dragging = false;
    }
    
    
    
    
};


        