//
//  BlackPianoKeyView.swift
//  Simple Sampler
//
//  Created by Bjarte Sjursen on 17/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import UIKit

@IBDesignable
class BlackPianoKeyView: CustomizableView {
    
    let grayTopLayer = CALayer()
    var touchesBeganAction: (() -> Void)?
    var touchesEndedAction: (() -> Void)?
    
    override var frame: CGRect {
        willSet {
            let grayTopLayerFrame = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height - 14.0)
            grayTopLayer.frame = grayTopLayerFrame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func commonInit() {
        backgroundColor = UIColor.black
        cornerRadius = 8.0
        let grayTopLayerFrame = CGRect(x: 3.0, y: 0, width: bounds.width - 6.0, height: bounds.height - 14.0)
        grayTopLayer.frame = grayTopLayerFrame
        grayTopLayer.backgroundColor = UIColor(red: 0.1412, green: 0.1412, blue: 0.1412, alpha: 1.0).cgColor
        grayTopLayer.cornerRadius = 8.0
        layer.insertSublayer(grayTopLayer, at: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func endButtonPress() {
        touchesEndedAction?()
        grayTopLayer.backgroundColor = UIColor(red: 0.1412, green: 0.1412, blue: 0.1412, alpha: 1.0).cgColor
        grayTopLayer.frame = CGRect(x: grayTopLayer.frame.origin.x,
                                    y: 0.0,
                                    width: grayTopLayer.bounds.width,
                                    height: grayTopLayer.bounds.height - 8.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganAction?()
        grayTopLayer.backgroundColor = UIColor(red: 0.0941, green: 0.0941, blue: 0.0941, alpha: 1.0).cgColor
        grayTopLayer.frame = CGRect(x: grayTopLayer.frame.origin.x,
                                    y: 0.0,
                                    width: grayTopLayer.bounds.width,
                                    height: grayTopLayer.bounds.height + 8.0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endButtonPress()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        endButtonPress()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    deinit {
        touchesBeganAction = nil
        touchesEndedAction = nil
    }
    
}
