//
//  GradientExtension.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/27/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    
    func setGradient(colorOne:UIColor,colorTwo:UIColor,colorThree:UIColor){
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        // Need the CG color because CAGradientLayer is apart of core graphics
        gradientLayer.colors = [colorOne.cgColor,colorTwo.cgColor,colorThree.cgColor]
        gradientLayer.locations = [0.0,0.5,1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        
        
    }
    
    
}
