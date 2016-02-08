//
//  TabBarController.swift
//  CenterFloatingActionButtonTabBar
//
//  Created by Terry Bu on 2/8/16.
//  Copyright © 2016 Terry Bu. All rights reserved.
//

import UIKit


//Notification Identifiers
let kOpenRightSideMenuTableView = "kOpenRightSideMenuTableView"
let kCloseRightSideMenuTableView = "kCloseRightSideMenuTableView"

class TabBarController: UITabBarController {
    
    var button: UIButton = UIButton()
    var tabSelectionIndicatorImage: UIImage?
    var settingsMenuTableView: SettingsMenuTableView!
    var settingsMenuTableViewDataSource: SettingsMenuTableViewDataSource!
    var settingsNavigationController: SettingsNavigationController!
    var rightSideContainerView: UIView!
    var blackOverlayLeftView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inactiveGrayCenterButtonImage = UIImage(named: "Btn_Menu_BROWSE_INACTIVE_03")
        let activeRedCenterButtonImage = UIImage(named: "Btn_Menu_BROWSE_ACTIVE_03")
        addCenterButtonWithImage(inactiveGrayCenterButtonImage!, highlightImage: activeRedCenterButtonImage)
        makeActiveTabWhiteBackgroundRectangle()
        let tabBarDropShadow = UIImage(named: "Img_Menu_DROPSHADOW_01")
        let dropShadowImageView = UIImageView(image: tabBarDropShadow)
        dropShadowImageView.frame.origin = CGPoint(x: view.frame.width/2-dropShadowImageView.frame.width/2, y: tabBar.frame.origin.y-14)
        view.addSubview(dropShadowImageView)
        tabBar.selectionIndicatorImage = tabSelectionIndicatorImage
        
        setUpSettingsSlideOutMenu()
    }
    
    
    //MARK: RightSideSlideOutSettingsMenu Code
    
    private func setUpSettingsSlideOutMenu() {
        self.blackOverlayLeftView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-self.tabBar.frame.size.height))
        blackOverlayLeftView.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "blackOverlayWasTapped")
        blackOverlayLeftView.userInteractionEnabled = true
        blackOverlayLeftView.addGestureRecognizer(tapGesture)
        
        rightSideContainerView = UIView(frame: CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.height - tabBar.frame.size.height))
        settingsMenuTableView = SettingsMenuTableView(frame: CGRect(x: 0, y: 0, width: rightSideContainerView.frame.width, height: rightSideContainerView.frame.height))
        settingsMenuTableViewDataSource = SettingsMenuTableViewDataSource()
        settingsMenuTableViewDataSource.delegate = self
        settingsMenuTableView.delegate = settingsMenuTableViewDataSource
        settingsMenuTableView.dataSource = settingsMenuTableViewDataSource
        settingsMenuTableView.tableFooterView = UIView(frame: CGRectZero)
        settingsMenuTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
//        settingsMenuTableView.separatorColor = UIColor(rgba: "#aaaaaa")
        rightSideContainerView.addSubview(settingsMenuTableView)
        
        self.settingsNavigationController = self.viewControllers![4] as! SettingsNavigationController
        self.delegate = settingsNavigationController
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSettingsRightSideMenu", name: kOpenRightSideMenuTableView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeSettingsRightSideMenu", name: kCloseRightSideMenuTableView, object: nil)
        removeTabbarItemText()
    }
    
    func removeTabbarItemText() {
        if let items = tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            }
        }
    }
    
    @objc
    private func blackOverlayWasTapped() {
        closeSettingsRightSideMenu()
    }
    
    @objc
    private func showSettingsRightSideMenu() {
        self.selectedIndex = 4;
        removeTabbarItemText()
        
        //this updates the headerview namelabel, in case it got updated
        if let headerView = self.settingsMenuTableViewDataSource.headerView {
            let fullName = "fullname"
            headerView.nameLabel.text = fullName
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.rightSideContainerView.frame = CGRectOffset(self.rightSideContainerView.frame, -self.view.frame.width+50, 0)
            self.blackOverlayLeftView.backgroundColor = UIColor.blackColor()
            self.blackOverlayLeftView.alpha = 0.5
            self.view.addSubview(self.blackOverlayLeftView)
            self.view.addSubview(self.rightSideContainerView)
            }, completion: { (completed) -> Void in
                //done
                self.settingsMenuTableView.showing = true
        })
    }
    
    @objc
    private func closeSettingsRightSideMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.rightSideContainerView.frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBar.frame.size.height)
            self.blackOverlayLeftView.alpha = 0.0
            }, completion: { (completed) -> Void in
                //done
                self.settingsMenuTableView.showing = false
                self.blackOverlayLeftView.removeFromSuperview()
        })
    }
    
    
    //MARK: Tab Bar Center Floating Action Button Code
    private func makeActiveTabWhiteBackgroundRectangle() {
        //this sets up the feature where an active tab bar has a background color different from all the other inactive ones.
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        tabSelectionIndicatorImage = UIImage.imageWithColor(UIColor.whiteColor(), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2
    }
    
    private func addCenterButtonWithImage(buttonImage: UIImage, highlightImage:UIImage?)
    {
        let frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height)
        button = UIButton(frame: frame)
        button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        
        var heightDifference:CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
        if heightDifference < 0 {
            button.center = self.tabBar.center;
        } else {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        
        button.addTarget(self, action: "floatingCenterTabButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(button)
    }
    
    func floatingCenterTabButtonPressed(sender:UIButton) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kCloseRightSideMenuTableView, object: nil))
        var selectedIndex = Int(self.viewControllers!.count/2)
        self.selectedIndex = selectedIndex
        self.selectedViewController = (self.viewControllers as [AnyObject]?)?[selectedIndex] as? UIViewController
        dispatch_async(dispatch_get_main_queue(), {
            if sender.highlighted == false{
                sender.highlighted = true
            }else{
                sender.highlighted = false
            }
        });
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //this code allows so that when you have clicked on center floatin button, and then pressed some other tab item, then center floating button turns off highlighting
        button.highlighted = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit called in tastii tab bar vc")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension TabBarController: SettingsMenuTableViewSubSelectionDelegate {
    
    func didPressEditProfile() {
//        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kCloseRightSideMenuTableView, object: nil))
//        let editMyInfoVc = EditProfileViewController()
//        editMyInfoVc.tastiiTabBarViewController = self
//        settingsNavigationController.viewControllers = [editMyInfoVc]
        
        print("did press EDIT PROFILE")
    }
    
    func didPressMyTastePreferences() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kCloseRightSideMenuTableView, object: nil))
        
        print("did press my taste preferences")
    }
    
    func didPressFAQsSupport() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kCloseRightSideMenuTableView, object: nil))
//        let faqVC = FAQViewController()
//        faqVC.tastiiTabBarViewController = self
//        settingsNavigationController.viewControllers = [faqVC]
        print("did press faq support")
    }
    
    func didPressLogOut() {
        print("did press log Out")
    }
    
    func goBackToLoginScreen() {
        print("going back to login screen")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

