//
//  MyFavoritesViewController.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MyFavoritesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var noFavoritesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var favorites: RealmSwift.Results<ScriptureRealm>?
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let realm = try! Realm()
        
        self.favorites = realm.objects(dailybibleverse.ScriptureRealm.self)
        setState()
    }
    
    func setState() {
        if self.favorites?.count == 0 {
            UIView.animate(withDuration: 0.4
                , animations: {
                    self.noFavoritesLabel.alpha = 0.9
            }, completion: { completion in
                self.noFavoritesLabel.isHidden = false
                
            })
        } else {
            UIView.animate(withDuration: 0.0
                , animations: {
                    self.noFavoritesLabel.alpha = 0.0
            }, completion: { completion in
                self.noFavoritesLabel.isHidden = false
                
            })
        }

    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return favorites?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteVerseCell") as! FavoriteVerseCell
        if let verse = self.favorites?[indexPath.row] {
            cell.configureFor(scriptureData: verse)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailView":
                let favoriteVC = segue.destination as! FavoriteDetailViewController
                if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                    favoriteVC.realmFavorite = favoriteAtIndexPath(indexPath: indexPath as NSIndexPath)
                }
            default:
                break
            }
        }
    }
    
    
    func favoriteAtIndexPath(indexPath: NSIndexPath) -> ScriptureRealm {
        
        return (self.favorites?[indexPath.row])!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        setState()
    }
    
    
}
