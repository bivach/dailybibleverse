//
//  ViewController.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 adepture. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import GoogleMobileAds
import SafariServices
import Social
import FBSDKShareKit

class ViewController: UIViewController, GADBannerViewDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var bannerAdMob: GADBannerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var doveView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var dailyBibleAnimation: UIImageView!
    
    var viewModel = MainViewModel()
    let sharedLocalStorage = LocalStorage.sharedInstance

    var translationText: String {
        return sharedLocalStorage.getBibleVersion() == 1 ? "King James version (KJV)" : "NIV® Scripture Copyright biblica, Inc.®"
    }
    
    var bibleImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bibleImages = createImageArray(total: 6, imagePrefix: "Book")
        retryButton.layer.cornerRadius = 10;
        retryButton.clipsToBounds = true;
        let _ = viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.stateHasChanged(state)
            })
        viewModel.loadDailyVerse()
        
        setGADBannerView()
    }
    
    func stateHasChanged(_ state: MainViewModel.State) {
        
        switch state {
        case .loading:
             animate(imageView: dailyBibleAnimation, images: bibleImages)
            progressView.alpha = 1
            progressView.isHidden = false
            
        case .success(let mergeDailyVerseResponse):
            
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            showSuccesView(scriptureData: scriptureData)
            
        case .error:
            
            showErrorView()
            
        }
    }
    
    //BUTTONS ACTIONS:
    
    @IBAction func openMenu(_ sender: UIButton) {
        showMenu(true)
    }
    
    @IBAction func closeMenu(_ sender: UIButton) {
        showMenu(false)
    }
    
    func showMenu(_ show: Bool) {
        if show { self.menuView.isHidden = false }
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView.alpha = show ? 1 : 0
        }) { (completion) in
            self.menuView.isHidden = show ? false : true
        }
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        sharePressed()
    }
    
    @IBAction func addOrDeleteToFavorites(_ sender: UIButton) {
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            if(viewModel.addOrDeleteScriptureFromRealm(scriptureData: scriptureData)) {
                //If the scripture was added to db then change color to red heart
                heartButton.setImage(UIImage(named: "HeartRed.png"), for: .normal)
            } else {
                //Else the scripture was removed from db then change color to alpha heart
                heartButton.setImage(UIImage(named: "Heart.png"), for: .normal)
            }
        }
    }
    
    @IBAction func facebookShareButton(_ sender: Any) {
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            let content: FBSDKShareLinkContent  = FBSDKShareLinkContent()
            content.contentURL = NSURL(string: scriptureData.share_link!) as URL!
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
        }
    }
    
    @IBAction func googlePlusShareButton(_ sender: Any) {
        showGooglePlusShare(shareURL: NSURL())
    }
    
    @IBAction func twitterShareButton(_ sender: UIButton) {
        
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let string = "\(scriptureData.share_link!)"
                let url = URL(string : string)
                let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
                post.setInitialText("\(scriptureData.tweet!)")
                post.add(url)
                self.present(post, animated: true, completion: nil)
            } else {
                
                let urlstring = "\(scriptureData.tweet!) \(scriptureData.share_link!)"
                
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
    }
    
    @IBAction func settingsTouch(_ sender: Any) {
        showMenu(false)
    }
    
    @IBAction func myFavoritesTouch(_ sender: Any) {
        showMenu(false)
    }
    
    func sharePressed() {
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            showMenu(false)
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            let activityVc = UIActivityViewController(activityItems: [scriptureData.share_link!], applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = self.view
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    
    func showGooglePlusShare(shareURL: NSURL) {
        
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            let urlstring = scriptureData.share_link
            
            let shareURL = NSURL(string: urlstring!)
            
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
    }
    
    @IBAction func translationButton(_ sender: UIButton) {
        if(sharedLocalStorage.getBibleVersion() == 1 ) {
            showAlertTranslation(service: "From the King James Version")
        } else {
            showAlertTranslation(service: "Scripture quotations taken from The Holy Bible, New International Version®, NIV®. Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by Permission of Biblica, Inc.®  All rights reserved worldwide.")
        }
        
    }
    
    @IBAction func retryAction(_ sender: Any) {
        dailyBibleAnimation.isHidden = false
        loadingLabel.isHidden = false
        animate(imageView: dailyBibleAnimation, images: bibleImages)
        retryButton.isHidden = true
        viewModel.state.value = .loading
        viewModel.loadDailyVerse()
    }
    
    func showAlert(service:String) {
        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertTranslation(service:String) {
        let alert = UIAlertController(title: service, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //LIFECYCLESMETHODS
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if case .success(let mergeDailyVerseResponse) = viewModel.state.value {
            let script = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()

            self.translationLabel.attributedText = underline(translationText)

            let allVersesString = NSMutableAttributedString(string: "")
            for verse in script.verses {
                let x = "\(verse.verse_no ?? 1)".count
                let verseString = changeColor(text: verse.verse_text!, forFirstCharacterCount: x)
                allVersesString.append(verseString)
                allVersesString.append(NSAttributedString(string: "\n"))
            }
            self.verseLabel.attributedText = allVersesString

            let realm = try! Realm()
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            
            let date2 = "scripture_date == '\(scriptureData.scripture_date!)'"
            
            if(realm.objects(ScriptureRealm.self).filter(date2).count > 0) {
                heartButton.setImage(UIImage(named: "HeartRed.png"), for: .normal)
            } else {
                heartButton.setImage(UIImage(named: "Heart.png"), for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //SET VIEWS
    
    func setGADBannerView() {
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        bannerAdMob.adUnitID = "ca-app-pub-0219081932956726/4282096506"
        
        bannerAdMob.rootViewController = self
        bannerAdMob.delegate = self
        
        bannerAdMob.load(request)
    }
    
    //SETTING UI TO ERROR STATE VIEW
    func showErrorView() {
        dailyBibleAnimation.isHidden = true
        loadingLabel.isHidden = true

        UIView.animate(withDuration: 0.4
            , animations: {
                self.retryButton.alpha = 1
        }, completion: { completion in
            self.retryButton.isHidden = false
        })
        showAlert(service: "Internet")
    }
    
    //SETTING UI FIELDS
    func showSuccesView(scriptureData: ScriptureData) {
        UIView.animate(withDuration: 0.3
            , animations: {
                self.retryButton.alpha = 0.0
        }, completion: { completion in
            self.retryButton.isHidden = true
        })
        
        self.translationLabel.attributedText = underline(translationText)
        
        let realm = try! Realm()
        
        let date2 = "scripture_date == '\(scriptureData.scripture_date!)'"
        
        if(realm.objects(ScriptureRealm.self).filter(date2).count > 0) {
            heartButton.setImage(UIImage(named: "HeartRed.png"), for: .normal)
        } else {
            heartButton.setImage(UIImage(named: "Heart.png"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.progressView.alpha = 0.0
        }, completion: { completion in
            self.progressView.isHidden = true
        })
        
        if let bookName = scriptureData.book_name, let span = scriptureData.span {
            bookLabel.text = "\(bookName) \(span)"
        } else {
            bookLabel.text = ""
        }
        
        let allVersesString = NSMutableAttributedString(string: "")
        for verse in scriptureData.verses {
            let x = "\(verse.verse_no ?? 1)".count
            let verseString = changeColor(text: verse.verse_text!, forFirstCharacterCount: x)
            allVersesString.append(verseString)
            allVersesString.append(NSAttributedString(string: "\n"))
        }
        self.verseLabel.attributedText = allVersesString
        
        UIView.animate(withDuration: 5.0, animations: {
            self.doveView.alpha = 0.3
        }, completion: { completion in
            self.doveView.isHidden = false
        })
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: scriptureData.scripture_date ?? "")
        
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "EEEE, MMMM dd, yyyy"
        let string = formatter2.string(from: date!)
        
        dateLabel.text = string
    }
    
    
    //LOADING ANIMATION
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        
        var imageArray: [UIImage] = []
        
        for imageCount in 1..<total {
            let imageName = "\(imagePrefix)\(imageCount).png"
            let image = UIImage(named: imageName)!
            
            imageArray.append(image)
        }
        return imageArray
    }
    
    //LOADING ANIMATION

    func animate(imageView: UIImageView, images: [UIImage]) {
        imageView.animationImages = images
        imageView.animationDuration = 1.0
        imageView.animationRepeatCount = 10
        imageView.startAnimating()
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

