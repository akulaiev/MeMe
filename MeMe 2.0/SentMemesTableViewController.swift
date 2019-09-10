//
//  SentMemesTableViewController.swift
//  MeMe 2.0
//
//  Created by Anna Kulaieva on 8/24/19.
//  Copyright © 2019 Anna Kulaieva. All rights reserved.
//

import Foundation
import UIKit

class SentMemesTableViewController: UITableViewController {

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
    
    // Returns number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    // Populates every table row with meme info
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesTableViewCell")!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = meme.topText + " " + meme.bottomText
        return cell
    }
    
    // Instantiates and presents show created meme VC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let showMemeVC: ShowMemeViewController
        showMemeVC = storyboard.instantiateViewController(withIdentifier: "showMemeVC") as! ShowMemeViewController
        let meme = self.memes[(indexPath as NSIndexPath).row]
        showMemeVC.memeImage = meme.memedImage
        navigationController?.pushViewController(showMemeVC, animated: true)
    }
}
