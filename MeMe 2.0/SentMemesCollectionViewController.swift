//
//  SentMemesCollectionViewController.swift
//  MeMe 2.0
//
//  Created by Anna Kulaieva on 8/24/19.
//  Copyright © 2019 Anna Kulaieva. All rights reserved.
//

import Foundation
import UIKit

class SentMemesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "SentMemesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SentMemesCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        collectionView.reloadData()
    }
    
    // Returns number of collection cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    // Sets an image for collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentMemesCollectionViewCell", for: indexPath) as! SentMemesCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        cell.sentMemeImageView?.image = meme.memedImage
        return cell
    }
    
    // Calculates and returnes cells' size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 4
        let borderSpacing: CGFloat = 15
        let totalSpacing = (2 * borderSpacing) + (numberOfItemsPerRow - 1)
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing) / numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // Instantiates and presents show created meme VC
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let showMemeVC: ShowMemeViewController
        showMemeVC = storyboard.instantiateViewController(withIdentifier: "showMemeVC") as! ShowMemeViewController
        let meme = self.memes[(indexPath as NSIndexPath).row]
        showMemeVC.memeImage = meme.memedImage
        navigationController?.pushViewController(showMemeVC, animated: true)
    }
}
