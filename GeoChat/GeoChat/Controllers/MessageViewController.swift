//
//  MessageViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    
    @IBOutlet weak var handleText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var buttonClose: UIButton!
    
    var msg: MessageContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonClose.roundCorners()
        
        handleText.text = "@\(msg!.handle!)"
        captionText.text = msg.getCaption()
        
        msg.getImage(image: imageView)

    }
    
    
    @IBAction func buttonCloseClicked(_ sender: UIButton) {
        // 
        
        
        self.dismiss(animated: true)
    }
}
