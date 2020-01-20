//
//  SentMemesCollectionViewController.swift
//  MemeMe2.0
//
//  Created by Isaac Iniongun on 20/01/2020.
//  Copyright © 2020 Ing Groups. All rights reserved.
//

import UIKit

private let reuseIdentifier = "sentMemeCollectionViewCell"

class SentMemesCollectionViewController: UICollectionViewController {
    
    var memes: [Meme]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    fileprivate var selectedMeme: Meme? = nil
    
    fileprivate let showMemeDetailsSegue = "showMemeDetails1"
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        hideTabBar(false)
    }
    
    fileprivate func hideTabBar(_ shouldShow: Bool) {
        tabBarController?.tabBar.isHidden = shouldShow
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showMemeDetailsSegue {
            let vc = segue.destination as! MemeDetailViewController
            vc.meme = selectedMeme
        }
        
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
    
        cell.memeImageView.image = memes[indexPath.row].memedImage
    
        return cell
    }

    @IBAction func newMemeButtonTapped(_ sender: UIBarButtonItem) {
        hideTabBar(true)
        performSegue(withIdentifier: "showCreateMeme1", sender: nil)
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedMeme = memes[indexPath.row]
        hideTabBar(true)
        performSegue(withIdentifier: showMemeDetailsSegue, sender: nil)
    }

}
