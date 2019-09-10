//
//  ShowMemeViewController.swift
//  MeMe 2.0
//
//  Created by Anna Kulaieva on 9/10/19.
//  Copyright © 2019 Anna Kulaieva. All rights reserved.
//

import Foundation
import UIKit

class ShowMemeViewController: UIViewController {
    
    @IBOutlet weak var memeImageView: UIImageView!
    var memeImage: UIImage!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        if let setImage = memeImage {
            memeImageView.image = setImage
        }
    }
}
