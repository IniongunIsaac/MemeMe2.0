//
//  MemeDetailViewController.swift
//  MemeMe2.0
//
//  Created by Isaac Iniongun on 20/01/2020.
//  Copyright © 2020 Ing Groups. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMemeDetails()
    }
    
    fileprivate func setMemeDetails() {
        topTextLabel.text = meme.topText
        bottomTextLabel.text = meme.bottomText
        memeImageView.image = meme.originalImage
    }
    
    @IBAction func editMemeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showCreateMemeVC", sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CreateMemeViewController
        vc.currentMeme = meme
    }

}
