//
//  ListVC.swift
//  PeekPop3DTouch
//
//  Created by Yudiz Solutions Pvt.Ltd. on 04/01/17.
//  Copyright © 2017 Yudiz Solutions Pvt.Ltd. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import MapKit

class ListVC: UIViewController,NSUserActivityDelegate {

    @IBOutlet weak var tblList: UITableView!
    
    var arrCompany = [Company]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrCompany.append(
            Company(name:"Apple",
                    address:"Cupertino, California, U.S.",
                    url:"https://en.wikipedia.org/wiki/Apple_Inc",
                    logo:#imageLiteral(resourceName: "apple"))
        )
        
        arrCompany.append(
            Company(name:"Google",
                    address:"Googleplex, Mountain View, California, U.S",
                    url:"https://en.wikipedia.org/wiki/Google",
                    logo:#imageLiteral(resourceName: "google"))
        )
        
        arrCompany.append(
            Company(name:"Microsoft",
                    address:"Albuquerque, New Mexico, United States",
                    url:"https://en.wikipedia.org/wiki/Microsoft",
                    logo:#imageLiteral(resourceName: "microsoft"))
        )
        
        arrCompany.append(
            Company(name:"Samsung",
                    address:"Seocho District, Seoul, South Korea",
                    url:"https://en.wikipedia.org/wiki/Samsung",
                    logo:#imageLiteral(resourceName: "samsung"))
        )
        
        arrCompany.append(
            Company(name:"Amazon",
                    address:"Seattle, Washington, U.S",
                    url:"https://en.wikipedia.org/wiki/Amazon.com",
                    logo:#imageLiteral(resourceName: "amazon"))
        )
        
        arrCompany.append(
            Company(name:"Facebook",
                    address:"Menlo Park, California, U.S.",
                    url:"https://en.wikipedia.org/wiki/Facebook",
                    logo:#imageLiteral(resourceName: "facebook"))
        )
        
        arrCompany.append(
            Company(name:"Flipkart",
                    address:"Bangalore, Karnataka, India",
                    url:"https://en.wikipedia.org/wiki/Flipkart",
                    logo:#imageLiteral(resourceName: "flipkart"))
        )
        
        arrCompany.append(
            Company(name:"Yahoo",
                    address:"Sunnyvale, California, U.S.",
                    url:"https://en.wikipedia.org/wiki/Yahoo!",
                    logo:#imageLiteral(resourceName: "yahoo"))
        )
        
        arrCompany.append(
            Company(name:"Yudiz",
                    address:"Prahlad Nagar, Ahmedabad, Gujarat,India",
                    url:"http://www.yudiz.com/",
                    logo:#imageLiteral(resourceName: "Icon"))
        )
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //createUserActivity()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? UITableViewCell {
            let indexPath = tblList.indexPath(for: cell)!
            if segue.identifier == "segueDetails" {
                if let detailsVC = segue.destination as? DetailVC {
                    detailsVC.url = arrCompany[indexPath.row].url
                    //createUserActivity(company: arrCompany[indexPath.row],index: indexPath.row)
                    self.getLocation(company:arrCompany[indexPath.row])
                }
            }
        }
        setupSearchableContent()
    }
    var continuedActivity: NSUserActivity?
    func createUserActivity(company:Company,index:Int) {
        userActivity = NSUserActivity(activityType: "Yudiz.ProactiveSuggetions.viewDetails")
        userActivity?.userInfo = ["name":company.name, "address":company.address,"link":company.url]
        userActivity?.title = "\(index)"
        userActivity?.needsSave = true
        let place = MKPlacemark(coordinate: CLLocationCoordinate2DMake(23.0225, 72.5714), addressDictionary:[
            "city":"Ahmedabad",
            "state":"Gujarat",
            "county":"India"
            ])
        userActivity?.mapItem = MKMapItem(placemark: place)
        userActivity?.contentAttributeSet = getSearchableItem(company: company)
        userActivity?.contentAttributeSet?.supportsNavigation = true
        userActivity?.contentAttributeSet?.supportsPhoneCall = true
        
        userActivity?.isEligibleForSearch = true
        userActivity?.isEligibleForHandoff = true
        userActivity?.isEligibleForPublicIndexing = true
        
        userActivity?.becomeCurrent()
    }
    func getSearchableItem(company:Company) -> CSSearchableItemAttributeSet {
        let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        searchableItemAttributeSet.title = company.name
        searchableItemAttributeSet.thumbnailData = UIImagePNGRepresentation(company.logo)
        searchableItemAttributeSet.contentDescription = company.address
        searchableItemAttributeSet.keywords = [company.name,company.address]

        return searchableItemAttributeSet
    }
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        continuedActivity = activity
        super.restoreUserActivityState(activity)
    }
    func setupSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        
        for record in arrCompany {
            
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchableItemAttributeSet.title = record.name
            searchableItemAttributeSet.thumbnailData = UIImagePNGRepresentation(record.logo)
            searchableItemAttributeSet.contentDescription = record.address
            searchableItemAttributeSet.keywords = [record.name,record.address]
            let searchableItem = CSSearchableItem(uniqueIdentifier: "com.yudiz.SpotIt.\(record.name)", domainIdentifier: "company", attributeSet: searchableItemAttributeSet)
            searchableItems.append(searchableItem)
            
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) -> Void in
            if error != nil {
                print(error?.localizedDescription ?? "nil")
            }
        }
        
    }
    func getLocation(company:Company) {
        let request = MKLocalSearchRequest()
        
        request.naturalLanguageQuery = company.name
        request.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(23.0225, 72.5714), 1600, 1600)
        
        MKLocalSearch(request: request).start { (response, error) in
            guard error == nil else { return }
            guard let response = response else { return }
            guard let exampleMapItem = response.mapItems.first else { return }
            
            let activity = NSUserActivity(activityType: "Yudiz.ProactiveSuggetions.viewDetails")
            activity.title = exampleMapItem.name
            activity.mapItem = exampleMapItem
            self.userActivity = activity
            
            activity.isEligibleForHandoff = true
            activity.isEligibleForSearch = true
            activity.isEligibleForPublicIndexing = true
            
            // Set delegate
            activity.delegate = self
            self.userActivity?.becomeCurrent()
            
        }
    }
    // MARK: NSUserActivityDelegate protocol implementation
    override func updateUserActivityState(_ activity: NSUserActivity) {
        /*
         Provide map item to be promoted throughout the system
         This will automatically populate the contentAttributeSet property
         with all available location information, including geo coordinates,
         text address components, phone numbers, etc.
         */
        
        /*
         Provide just enough information in the userInfo dictionary to be
         able to restore state
         */
        var userInfo = [String: AnyObject]()
        userInfo["placemark"] = NSKeyedArchiver.archivedData(withRootObject: (activity.mapItem.placemark)) as AnyObject?
        if let url = activity.mapItem.url {
            userInfo["url"] = url as AnyObject?
        }
        if let phoneNumber = activity.mapItem.phoneNumber {
            userInfo["phoneNumber"] = phoneNumber as AnyObject?
        }
        activity.userInfo = userInfo
        
        // Provide additional searchable attributes.
        activity.contentAttributeSet?.supportsNavigation = true
        activity.contentAttributeSet?.supportsPhoneCall = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension  ListVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCompany.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ListCell")
        return cell!
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let listCell = cell as? ListCell {
            listCell.btnForce.tag = indexPath.row
            listCell.lblName.text = arrCompany[indexPath.row].name
            listCell.lblAddress.text = arrCompany[indexPath.row].address
            listCell.imgLogo.image = arrCompany[indexPath.row].logo
        }
    }
}
