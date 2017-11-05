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
    
    @IBOutlet weak var bannerAdMob: GADBannerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var doveView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var progressAnim: UIActivityIndicatorView!
    
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.layer.cornerRadius = 10; // this value vary as per your desire
        retryButton.clipsToBounds = true;
        let _ = viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.stateHasChanged(state)
            })
        viewModel.loadDailyVerse()
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set Up Banner
        bannerAdMob.adUnitID = "ca-app-pub-0219081932956726/4282096506"
        
        bannerAdMob.rootViewController = self
        bannerAdMob.delegate = self
        
        bannerAdMob.load(request)
        
    }
    
    
    var results: Array<Any> = [] {
        didSet {
            reloadActions()
        }
    }
    
    func reloadActions() {
        // Override it to reloadData on tableView
    }
    
    // MARK: - Public Interface
    
    func setInitialViewHidden(_ hidden: Bool) {
        // Override it to show or hide Empty State
    }
    
    func setEmptyStateHidden(_ hidden: Bool) {
        // Override it to show or hide Empty State
    }
    
    func setLoadingStateHidden(_ hidden: Bool) {
        // Override it to show or hide Loading State
    }
    
    func setErrorStateHidden(_ hidden: Bool) {
        // Override it to show or hide Login State
    }
    
    func stateHasChanged(_ state: MainViewModel.State) {
        
        switch state {
        case .loading:
            progressView.alpha = 1
            progressView.isHidden = false
            
        case .success(let scriptureData):
            
            UIView.animate(withDuration: 0.3
                , animations: {
                    self.retryButton.alpha = 0.0
            }, completion: { completion in
                self.retryButton.isHidden = true
            })
            
            let realm = try! Realm()
            
            let date2 = "scripture_date == '\(scriptureData.scripture_date!)'"
            
            if(realm.objects(ScriptureRealm.self).filter(date2).count > 0) {
                heartButton.setImage(UIImage(named: "HeartRed.png"), for: .normal)
            } else {
                heartButton.setImage(UIImage(named: "Heart.png"), for: .normal)
            }
            
            UIView.animate(withDuration: 0.4
                , animations: {
                    self.progressView.alpha = 0.0
            }, completion: { completion in
                self.progressView.isHidden = true
                
            })
            verseLabel.text = scriptureData.verses.first?.verse_text
            if let bookName = scriptureData.book_name, let span = scriptureData.span {
                bookLabel.text = "\(bookName) \(span)"
            } else {
                bookLabel.text = ""
            }
            
            UIView.animate(withDuration: 5.0
                , animations: {
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
            
        case .error:
            progressAnim.isHidden = true
            UIView.animate(withDuration: 0.4
                , animations: {
                    self.retryButton.alpha = 1
            }, completion: { completion in
                self.retryButton.isHidden = false
            })
            showAlert(service: "Internet")
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showMenu(true)
    }
    
    @IBAction func closeMenu(_ sender: UIButton) {
        showMenu(false)
    }
    
    func showMenu(_ show: Bool) {
        self.menuView.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.menuView.alpha = show ? 0.45 : 0
        }) { (completion) in
            self.menuView.isHidden = show ? false : true
        }
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        sharePressed()
    }
    
    @IBAction func addOrDeleteToFavorites(_ sender: UIButton) {
        if case .success(let scriptureData) = viewModel.state.value {
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
        if case .success(let scriptureData) = viewModel.state.value {
            let content: FBSDKShareLinkContent  = FBSDKShareLinkContent()
            content.contentURL = NSURL(string: scriptureData.share_link!) as URL!
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
        }
        
    }
    @IBAction func googlePlusShareButton(_ sender: Any) {
        showGooglePlusShare(shareURL: NSURL())
    }
    
    @IBAction func twitterShareButton(_ sender: UIButton) {
        
        if case .success(let scriptureData) = viewModel.state.value {
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let string = "\(scriptureData.tweet!) \(scriptureData.share_link!)"
                let url = URL(string : string)
                let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
                post.setInitialText("Verse of the day")
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
        if case .success(let scriptureData) =
            viewModel.state.value {
            showMenu(false)
            let activityVc = UIActivityViewController(activityItems: [scriptureData.share_link ?? ""], applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = self.view
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    
    func showGooglePlusShare(shareURL: NSURL) {
        
        if case .success(let scriptureData) = viewModel.state.value {
            
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
    
    @IBAction func retryAction(_ sender: Any) {
        progressAnim.isHidden = false
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
    
}

