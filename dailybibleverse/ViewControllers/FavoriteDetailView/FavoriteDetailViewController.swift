//
//  FavoriteDetailViewController.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Social
import GoogleMobileAds
import FBSDKShareKit
import RealmSwift


class FavoriteDetailViewController : UIViewController, GADBannerViewDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var bannerAdMob: GADBannerView!
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var doveView: UIImageView!
    //    @IBOutlet weak var dateLabel: UILabel!
    //    @IBOutlet weak var verseLabel: UILabel!
    //    @IBOutlet weak var bookLabel: UILabel!
    //    @IBOutlet weak var progressView: UIView!
    //    @IBOutlet weak var menuView: UIView!
    //    @IBOutlet weak var doveView: UIImageView!
    //    @IBOutlet weak var heartButton: UIButton!

    
    @IBAction func onBack(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    public var realmFavorite : ScriptureRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookLabel.text = "\(realmFavorite!["book_name"]!) \(realmFavorite!["span"]!)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: realmFavorite!["scripture_date"] as! String)
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy/MM/dd"
        let string = formatter2.string(from: date!)
        
        dateLabel.text = string
        verseLabel.text  = realmFavorite!["verses"]! as? String
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set Up Banner
        bannerAdMob.adUnitID = "ca-app-pub-0219081932956726/4282096506"
        
        bannerAdMob.rootViewController = self
        bannerAdMob.delegate = self
        
        bannerAdMob.load(request)
    }
    
    @IBAction func heartButton(_ sender: Any) {
        if(addOrDeleteScriptureFromRealm(scriptureData: realmFavorite!)) {
            //If the scripture was added to db then change color to red heart
            heartButton.setImage(UIImage(named: "HeartRed.png"), for: .normal)
        } else {
            //Else the scripture was removed from db then change color to alpha heart
            heartButton.setImage(UIImage(named: "Heart.png"), for: .normal)
        }
    }
    
    @IBAction func facebookShareButton(_ sender: UIButton) {
        let content: FBSDKShareLinkContent  = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "\(realmFavorite!["share_link"]!)") as URL!
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    @IBAction func googleShareButton(_ sender: Any) {
        let urlstring = "\(realmFavorite!["share_link"]!)"
        
        let shareURL = NSURL(string: urlstring)
        
        let urlComponents = NSURLComponents(string: "https://plus.google.com/share")
        
        urlComponents!.queryItems = [NSURLQueryItem(name: "url", value: shareURL!.absoluteString) as URLQueryItem]
        
        let url = urlComponents!.url!
        
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        } else {
            debugPrint("Not available")
        }
    }
    
    @IBAction func twitterShareButton(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let string = "\(realmFavorite!["tweet"]!) \(realmFavorite!["share_link"]!)"
            let url = URL(string : string)
            let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            post.setInitialText("Verse of the day")
            post.add(url)
            self.present(post, animated: true, completion: nil)
        } else {
            
            let urlstring = "\(realmFavorite!["tweet"]!) \(realmFavorite!["share_link"]!)"
            
            let urlComponents = NSURLComponents(string: "https://twitter.com/intent/tweet")
            
            urlComponents!.queryItems = [NSURLQueryItem(name: "text", value: urlstring.replacingOccurrences(of: ";", with: "")) as URLQueryItem]
            
            let url = urlComponents!.url!
            
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: url)
                svc.delegate = self
                self.present(svc, animated: true, completion: nil)
            } else {
                debugPrint("Not available")
            }
        }
    }
    
    
    func addOrDeleteScriptureFromRealm(scriptureData : ScriptureRealm) -> Bool {
        
        let realm = try! Realm()
        let scripts =  realm.objects(ScriptureRealm.self).filter("scripture_date == '\(realmFavorite!["scripture_date"]!)'")
        
        if (scripts.count > 0) {
            try! realm.write {
                realm.delete(scripts.first!)
                dismiss(animated: true, completion: nil)
            }
            return false
        } else {
            addScriptureToRealm()
            return true
        }
        
    }
    
    func addScriptureToRealm() {
        
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(realmFavorite!,update: true)
            }
    }
    
    
}
