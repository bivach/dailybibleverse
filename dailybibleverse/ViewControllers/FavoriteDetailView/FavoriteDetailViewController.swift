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
    @IBOutlet weak var translationLabel: UILabel!
    
    let localStorage = LocalStorage.sharedInstance
    //    @IBOutlet weak var dateLabel: UILabel!
    //    @IBOutlet weak var verseLabel: UILabel!
    //    @IBOutlet weak var bookLabel: UILabel!
    //    @IBOutlet weak var progressView: UIView!
    //    @IBOutlet weak var menuView: UIView!
    //    @IBOutlet weak var doveView: UIImageView!
    //    @IBOutlet weak var heartButton: UIButton!
    
    
    @IBAction func onBack(_ sender: Any) {
//         dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        translationLabel.text = localStorage.getBibleVersion() == 1 ? "King James version (KJV)" : "NIV® Scripture Cpyright biblica, Inc.®"
        verseLabel.text = localStorage.getBibleVersion() == 1 ? "\(realmFavorite!["verseKJV"]!)" : "\(realmFavorite!["verseNIV"]!)"
    }
    
    @IBAction func heartButton(_ sender: Any) {
        addOrDeleteScriptureFromRealm(scriptureData: realmFavorite!)
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
    
    
    func addOrDeleteScriptureFromRealm(scriptureData : ScriptureRealm) {
        let realm = try! Realm()
        let scripts =  realm.objects(ScriptureRealm.self).filter("scripture_date == '\(realmFavorite!["scripture_date"]!)'")
        let alert = UIAlertController(title: "Are you sure that you want to delete it?", message: "", preferredStyle: .actionSheet)
        let actionOne = UIAlertAction(title: "Yes", style: .default, handler: { action in
            if (scripts.count > 0) {
                try! realm.write {
                    realm.delete(scripts.first!)
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                
            }
            
        });
        let action = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(actionOne)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
//    func showAlertOfdeletingFavorite(service:String) {
//
//        let realm = try! Realm()
//        let scripts =  realm.objects(ScriptureRealm.self).filter("scripture_date == '\(realmFavorite!["scripture_date"]!)'")
//        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
//        alert.addAction(UIAlertAction(title: "Are", style: .default, handler: { action in
//            if (scripts.count > 0) {
//                try! realm.write {
//                    realm.delete(scripts.first!)
//                }
//                self.navigationController?.popViewController(animated: true)
//                return false
//            } else {
//                addScriptureToRealm()
//                return true
//            }
//
//        }));
//
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
    
    func addScriptureToRealm() {
        
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(realmFavorite!,update: true)
            }
    }
    @IBAction func showTranslationAlert(_ sender: UIButton) {
        if(localStorage.getBibleVersion() == 1 ) {
            showAlertTranslation(service: "From the King James Version")
        } else {
            showAlertTranslation(service: "Scripture quotations taken from The Holy Bible, New International Version®, NIV®. Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by Permission of Biblica, Inc.®  All rights reserved worldwide.")
        }
    }
    
    func showAlertTranslation(service:String) {
        let alert = UIAlertController(title: service, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setFirstCharctersColor(label : String, count : Int){
        let range = NSRange(location:0,length:count)
        let attributedString = NSMutableAttributedString(string: label)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: range)
        verseLabel.attributedText = attributedString
    }
    
    
}
