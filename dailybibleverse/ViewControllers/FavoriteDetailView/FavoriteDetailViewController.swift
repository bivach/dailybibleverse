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
import TwitterKit

class FavoriteDetailViewController : UIViewController, GADBannerViewDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var bannerAdMob: GADBannerView!
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var doveView: UIImageView!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    
    let localStorage = LocalStorage.sharedInstance
    
    @IBAction func onBack(_ sender: Any) {
//         dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    public var realmFavorite : ScriptureRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 5.0, animations: {
            self.doveView.alpha = 0.25
        }, completion: { completion in
            self.doveView.isHidden = false
        })
        
        bookLabel.text = "\(realmFavorite!["book_name"]!) \(realmFavorite!["span"]!)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: realmFavorite!["scripture_date"]! as! String)
        
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "EEEE, MMMM dd, yyyy"
        let string = formatter2.string(from: date!)
        
        dateLabel.text = string        
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
        
        let realmList = localStorage.getBibleVersion() == 1 ? realmFavorite!["versesListKJV"]! as! List<VerseRealm> : realmFavorite!["versesListNIV"]! as! List<VerseRealm>
        
        self.translationLabel.attributedText = underline(translationLabel.text!)
        
        let allVersesString = NSMutableAttributedString(string: "")
        let size = realmList.count
        var count = 1
        for verse in realmList {
            let x =  "\(verse["verse_no"]!)".count
            let string = "\(verse["verse_no"]! ) \(verse["verse_text"]!)"
            let verseString = changeColor(text: string, forFirstCharacterCount: x)
            allVersesString.append(verseString)
            if(size != count) {
                allVersesString.append(NSAttributedString(string: "\n"))
                allVersesString.append(NSAttributedString(string: "\n"))
            }
            count = count + 1
        }
        self.verseLabel.attributedText = allVersesString
    }

    func showMenu(_ show: Bool) {
        if show { self.menuView.isHidden = false }
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView.alpha = show ? 1 : 0
        }) { (completion) in
            self.menuView.isHidden = show ? false : true
        }
    }

    @IBAction func openMenu(_ sender: UIButton) {
        showMenu(true)
    }

    @IBAction func closeMenu(_ sender: UIButton) {
        showMenu(false)
    }

    @IBAction func shareButton(_ sender: UIButton) {
        sharePressed()
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
        
        let realmList = localStorage.getBibleVersion() == 1 ? realmFavorite!["versesListKJV"]! as! List<VerseRealm> : realmFavorite!["versesListNIV"]! as! List<VerseRealm>
        
        let allVersesString = NSMutableAttributedString(string: "")
        for verse in realmList {
            let string = "\(verse["verse_no"]! ) \(verse["verse_text"]!)"
            allVersesString.append(NSAttributedString(string: string))
            allVersesString.append(NSAttributedString(string: "\n"))
            allVersesString.append(NSAttributedString(string: "\n"))
        }
        
        urlComponents!.queryItems = [NSURLQueryItem(name: "text", value: "\(realmFavorite!["book_name"]!) \(realmFavorite!["span"]!) \n\(allVersesString.string)") as URLQueryItem,NSURLQueryItem(name: "url", value: shareURL!.absoluteString) as URLQueryItem]
        
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
        let tweet = localStorage.getBibleVersion() == 1 ? realmFavorite!["tweetKJV"]! :realmFavorite!["tweetNIV"]!
        let string = "\(realmFavorite!["share_link"]!)"
        let url = URL(string : string)
        
        // Swift
        let composer = TWTRComposer()
        
        composer.setText(tweet as? String)
        composer.setURL(url)
        
        // Called from a UIViewController
        composer.show(from: self.navigationController!) { (result) in
            if (result == .done) {
                print("Successfully composed Tweet")
            } else {
                print("Cancelled composing")
            }
        }
    }

    func sharePressed() {
        showMenu(false)
        
        let realmList = localStorage.getBibleVersion() == 1 ? realmFavorite!["versesListKJV"]! as! List<VerseRealm> : realmFavorite!["versesListNIV"]! as! List<VerseRealm>
        
        let allVersesString = NSMutableAttributedString(string: "")
        for verse in realmList {
            let string = "\(verse["verse_no"]! ) \(verse["verse_text"]!)"
            allVersesString.append(NSAttributedString(string: string))
            allVersesString.append(NSAttributedString(string: "\n"))
            allVersesString.append(NSAttributedString(string: "\n"))
        }
        
        let stringToShare = "\(realmFavorite!["book_name"]!) \(realmFavorite!["span"]!)\n\(allVersesString.string)\n\(realmFavorite!["share_link"]!)"
        
        let text = [stringToShare]
        
        let activityVc = UIActivityViewController(activityItems: text, applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = self.view
        self.present(activityVc, animated: true, completion: nil)
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
    
    @IBAction func settingPressed(_ sender: UIButton) {
        showMenu(false)
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
    
    //CHANGE VERSE NUMBER COLOR
    
    func changeColor(text: String, forFirstCharacterCount count: Int) -> NSAttributedString {
        let range = NSRange(location:0, length:count)
        let lightBlue = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1)
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: lightBlue, range: range)
        return attributedString
    }
    
    func underline(_ string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
        return attributedString
    }
    
    
}
