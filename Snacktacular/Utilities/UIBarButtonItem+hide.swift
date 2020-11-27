//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/10/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func hide(){
        self.isEnabled = false
        self.tintColor = .clear
    }
}
