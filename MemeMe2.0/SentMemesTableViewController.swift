//
//  SentMemesTableViewController.swift
//  MemeMe2.0
//
//  Created by Isaac Iniongun on 20/01/2020.
//  Copyright © 2020 Ing Groups. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var memes: [Meme]!
    fileprivate var selectedMeme: Meme? = nil
    
    fileprivate let showMemeDetailsSegue = "showMemeDetails"

    override func viewDidLoad() {
        super.viewDidLoad()
        initMemes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initMemes()
        tableView.reloadData()
        hideTabBar(false)
    }
    
    fileprivate func initMemes() {
        memes = appDelegate.memes
    }

    @IBAction func newMemeButtonTapped(_ sender: UIBarButtonItem) {
        hideTabBar(true)
        performSegue(withIdentifier: "showCreateMeme", sender: nil)
    }
    
    fileprivate func hideTabBar(_ shouldShow: Bool) {
        tabBarController?.tabBar.isHidden = shouldShow
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentMemeTableViewCell", for: indexPath)

        let meme = memes[indexPath.row]
        cell.textLabel?.text =  "\(meme.topText) \(meme.bottomText)"
        cell.imageView?.image = meme.memedImage

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.appDelegate.memes.remove(at: indexPath.row)
            self.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedMeme = memes[indexPath.row]
        hideTabBar(true)
        performSegue(withIdentifier: showMemeDetailsSegue, sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showMemeDetailsSegue {
            let vc = segue.destination as! MemeDetailViewController
            vc.meme = selectedMeme
        }
        
    }

}
