//
//  HeightenedButton.swift
//  Simple Sampler
//
//  Created by Bjarte Sjursen on 17/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import UIKit

class HeightenedButton: CustomizableView {

    var titleLayer = CATextLayer()
    let bottomLayer = CALayer()
    let topLayer = CALayer()
    var touchesEndedAction: (() -> Void)?
    
    @IBInspectable var buttonTitle: String = ""
    @IBInspectable var buttonTitleFontSize: CGFloat = 20.0
    @IBInspectable var buttonTitleFont: UIFont = .boldSystemFont(ofSize: 12.0)
    @IBInspectable var buttonFontColor: UIColor = .white
    @IBInspectable var topColor: UIColor = .white {
        didSet {
            topLayer.backgroundColor = topColor.cgColor
        }
    }
    @IBInspectable var bottomColor: UIColor = .white {
        didSet {
            bottomLayer.backgroundColor = bottomColor.cgColor
        }
    }
    var buttonTravel: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func commonInit() {
        layer.backgroundColor = UIColor.clear.cgColor
        let topLayerFrame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height * 0.82)
        let bottomLayerFrame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        let titleLayerFrame = CGRect(x: 0.0,
                                     y: bounds.height/3.0 - buttonTitleFontSize/2.0,
                                     width: bounds.width,
                                     height: bounds.height * 0.82)

        titleLayer.string = buttonTitle
        titleLayer.backgroundColor = UIColor.clear.cgColor
        titleLayer.frame = titleLayerFrame
        titleLayer.fontSize = buttonTitleFontSize
        titleLayer.font = buttonTitleFont
        titleLayer.alignmentMode = .center
        titleLayer.contentsScale = UIScreen.main.scale
        
        
        topLayer.frame = topLayerFrame
        bottomLayer.frame = bottomLayerFrame
        topLayer.backgroundColor = topColor.cgColor
        bottomLayer.backgroundColor = bottomColor.cgColor
        topLayer.cornerRadius = cornerRadius
        bottomLayer.cornerRadius = cornerRadius
        layer.insertSublayer(bottomLayer, at: 0)
        layer.insertSublayer(topLayer, at: 1)
        topLayer.insertSublayer(titleLayer, at: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        topLayer.frame = CGRect(x: topLayer.frame.origin.x,
                                y: topLayer.frame.origin.y + buttonTravel,
                                width: topLayer.frame.width,
                                height: topLayer.frame.height)
        bottomLayer.frame = CGRect(x: bottomLayer.frame.origin.x,
                                   y: bottomLayer.frame.origin.y + buttonTravel,
                                   width: bottomLayer.frame.width,
                                   height: bottomLayer.frame.height - buttonTravel)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedAction?()
        topLayer.frame = CGRect(x: topLayer.frame.origin.x,
                                y: topLayer.frame.origin.y - buttonTravel,
                                width: topLayer.frame.width,
                                height: topLayer.frame.height)
        bottomLayer.frame = CGRect(x: bottomLayer.frame.origin.x,
                                   y: bottomLayer.frame.origin.y - buttonTravel,
                                   width: bottomLayer.frame.width,
                                   height: bottomLayer.frame.height + buttonTravel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        buttonTravel = frame.height * 0.09
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

}
