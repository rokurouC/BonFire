//
//  MainMapViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/24.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import CoreLocation
import PermissionScope
import AMPopTip

class MainMapViewController: BonFireBaseViewController, UIGestureRecognizerDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var bonFireButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!
    
    @IBOutlet weak var campsiteListButton: UIButton!
    //MARK: - Property
    ///detect campsite light size
    private var campsiteRadius:CGFloat = 15
    private let mapviewSetRegionDegrees:CLLocationDegrees = 20
    
    private weak var timer:Timer?
    private var zoomLevel:UInt {
        get {
            return mapView.zoomLevel()
        }
    }
    private var campsiteAnnotations = [CampsiteAnnotation]()
    private var locationManager:CLLocationManager?
    private var userLocation:CLLocation {
        get {
            return locationManager!.location!
        }
    }
    
    private var campsites = [Campsite]()
    fileprivate var campsiteForPass:Campsite?
    
    fileprivate var catchedCampsiteName:String?
    fileprivate var catchedCampsiteImage:UIImage?
    
    //PermissionScope
    private let pscopeOfLocation = PermissionScope()
    
    //Subview
    fileprivate var campsiteView:CampsiteInfoView?
    fileprivate var userInfoEditView:UserInfoEditView?
    fileprivate var bonFireCreatView:FireBonFireView?
    fileprivate var viewForHandleImagePick:UIView?
    
    //Firebase Reference and Handle
    private var usersRef:DatabaseReference?
    private var campsitesRef:DatabaseReference?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _campsitesHandle:DatabaseHandle!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCoverImageView()
        configureLocationManager()
        configureDatabase()
        observeAllCampsitesAndPinOnMap()
        configurePermissionScope()
        
        if Auth.auth().currentUser != nil {
            configureAuth()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserIsFirstUse()
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
        campsitesRef?.removeObserver(withHandle: _campsitesHandle)
    }
    
    //When first time use, guild the user how to use.
    private func checkUserIsFirstUse() {
        guard let isFirstUse = UserDefaults.standard.object(forKey: Constants.isUserFirstUseAppKey) as? Bool, isFirstUse == false  else {
            UserDefaults.standard.set(false, forKey: Constants.isUserFirstUseAppKey)
            setUIEnableWhenFirstUse(false)
            guildUserFirstUse()
            return
        }
    }
    
    private func guildUserFirstUse() {
        let poptipFirst = PopTip()
        let poptipSecond = PopTip()
        let poptipThird = PopTip()
        poptipFirst.bubbleColor = .brown
        poptipSecond.bubbleColor = .brown
        poptipThird.bubbleColor = .brown
        poptipFirst.actionAnimation = .pulse(1.1)
        poptipSecond.actionAnimation = .bounce(2)
        poptipThird.actionAnimation = .bounce(2)
        poptipFirst.shouldDismissOnTapOutside = false
        poptipSecond.shouldDismissOnTapOutside = false
        poptipThird.shouldDismissOnTapOutside = false
        poptipSecond.shouldDismissOnTap = true
        poptipFirst.shouldDismissOnTap = true
        poptipThird.shouldDismissOnTap = true
        poptipFirst.dismissHandler = {(_) in
            poptipSecond.show(text: "Then check the campsites you've joined in here.\n< Tap me to next >", direction: .up, maxWidth: 150, in: self.view, from: self.campsiteListButton.frame)
        }
        poptipThird.dismissHandler = {(_) in
            self.setUIEnableWhenFirstUse(true)
        }
        poptipSecond.dismissHandler = {(_) in
            poptipThird.show(text: "Or you can camp your own campsite and let people join you!\n< Tap me to start! >", direction: .up, maxWidth: 150, in: self.view, from: self.bonFireButton.frame)
        }
        poptipFirst.show(text: "Welcome to BonFire! You can found campsites around the world on the map and tap to join them.\n< Tap me to next >", direction: .none, maxWidth: 150, in: view, from: view.frame)
    }
    
    private func setUIEnableWhenFirstUse(_ enable:Bool) {
        mapView.isUserInteractionEnabled = enable
        logoutButton.isUserInteractionEnabled = enable
        bonFireButton.isUserInteractionEnabled = enable
        campsiteListButton.isUserInteractionEnabled = enable
        
    }
    
    
    //MARK: - Configuration
    private func configureDatabase() {
        usersRef = FirebaseClient.sharedInstance.firDatabaseRef.child(Constants.FIRDatabaseConstants.users)
        campsitesRef = FirebaseClient.sharedInstance.firDatabaseRef.child(Constants.FIRDatabaseConstants.campsites)
    }
    
    private func configureAuth() {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        view.addSubview(aiv)
        view.isUserInteractionEnabled = false
        aiv.startAnimating()
        _authHandle = FirebaseClient.sharedInstance.addAuthStatusDidChangeListener(completion: {[unowned self]  (user, isJustCreat, isSignedIn, authController) in
            self.view.isUserInteractionEnabled = true
            aiv.stopAnimating()
            aiv.removeFromSuperview()
            guard isJustCreat == false else {
                self.userInfoEditView = UIView.instanceFromNib(nibName: "UserInfoEditView") as? UserInfoEditView
                self.userInfoEditView?.delegate = self
                self.userInfoEditView?.infoStatus = .Creating
                self.userInfoEditView?.alpha = 0
                DispatchQueue.main.async {
                    self.view.addSubview(self.userInfoEditView!)
                    UIView.animate(withDuration: 0.5) {
                        self.userInfoEditView!.alpha = 1
                    }
                }
                return
            }
            if isSignedIn {
                self.currentUser = user
            }else {
                DispatchQueue.main.async {
                    self.currentUser = nil
                    self.present(authController!, animated: true, completion: nil)
                }
            }
        })
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.startUpdatingLocation()
        locationManager?.pausesLocationUpdatesAutomatically = true
    }
    
    private func configurePermissionScope() {
        pscopeOfLocation.headerLabel.text = "Need Location"
        pscopeOfLocation.bodyLabel.text = "🏝"
        pscopeOfLocation.addPermission(LocationWhileInUsePermission(), message: "For all features, please enable BonFire to know where you are!")
    }
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
    }
    
    private func configureCoverImageView() {
        coverImageView.isUserInteractionEnabled = false
        coverImageView.backgroundColor = UIColor.clear
        coverImageView.alpha = 0.7
    }
    
    //MARK: - PScope
    fileprivate func checkLocationAuthorizedWithPScopeWhenCreateBonFire() {
        pscopeOfLocation.show({ (finished, results) in
            if finished, results.first?.status == .authorized{
                self.removeBonFireView()
                self.createBonFire()
            }
        }, cancelled: nil)
    }
    
    fileprivate func checkLocationAuthorizedWithPScopeWhenSelectCampsite() {
        pscopeOfLocation.show({ (finished, results) in
            if finished, results.first?.status == .authorized{
                self.removeBonFireView()
                self.showCampsiteInfoWithId(id: self.campsiteForPass!.id) {
                    self.mapView.isUserInteractionEnabled = true
                }
            }}) { (_) in
                self.mapView.isUserInteractionEnabled = true
        }
    }
    ///observe all campsite locations from server
    private func observeAllCampsitesAndPinOnMap() {
        _campsitesHandle = FirebaseClient.sharedInstance.observeAllCampsitesAdd(completion: { (campsite) in
            guard campsite != nil else { return }
            self.campsites.append(campsite!)
            self.pinCampsitesOnMap(campsites: [campsite!])
        })
    }
    
    private func pinCampsitesOnMap(campsites:[Campsite]) {
        for campsite in campsites {
            let coordinate = CLLocationCoordinate2D(latitude: campsite.latitude, longitude: campsite.longitude)
            let pin = CampsiteAnnotation(coordinate: coordinate, campsite: campsite, title: campsite.name, subtitle: nil)
            campsiteAnnotations.append(pin)
            DispatchQueue.main.async {
                self.mapView.addAnnotation(pin)
                self.lightTheFier()
            }
        }
    }
    
    fileprivate func mapViewSetUserRegion() {
        
        let latDelta:CLLocationDegrees = mapviewSetRegionDegrees
        let lonDelta:CLLocationDegrees = mapviewSetRegionDegrees
        
        let userLocation = locationManager?.location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: userLocation!, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    fileprivate func showCampsiteInfoWithId(id:String, completion:@escaping () ->Void) {
        FirebaseClient.sharedInstance.checkIsUserMemberOfCampsiteWithUser(user: currentUser!, campsiteId: id) { (isMember) in
            FirebaseClient.sharedInstance.getCampsiteInfoWithCampsiteId(campsiteId: id, completion: { (campsite) in
                guard campsite != nil else { return }
                self.campsiteView = UIView.instanceFromNib(nibName: "CampsiteInfoView") as? CampsiteInfoView
                self.campsiteView?.delegate = self
                self.campsiteView?.campsiteNameLabel.text = campsite!.name
                self.campsiteView?.ownerNameLabel.text = campsite?.ownerDisplayName
                self.campsiteView?.enterButton.setTitle(isMember ? "Enter" : "Join", for: .normal)
                self.campsiteView?.ownerImageView.loadImageUsingCacheWithUrlString(urlString: campsite!.ownerAvatarUrl, placeholdSize: nil)
                self.campsiteView?.campsiteImageView.loadImageUsingCacheWithUrlString(urlString: campsite!.profileUrl, placeholdSize: nil)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.removeCampsiteInfoView))
                tapGesture.numberOfTapsRequired = 1
                self.campsiteView?.backgroundView.addGestureRecognizer(tapGesture)
                self.campsiteView?.alpha = 0
                DispatchQueue.main.async {
                    self.view.addSubview(self.campsiteView!)
                    UIView.animate(withDuration: 0.3) {
                        self.campsiteView!.alpha = 1
                    }
                    completion()
                }
            })
        }
    }
    
    func removeCampsiteInfoView() {
        campsiteView?.removeFromSuperview()
        campsiteView = nil
    }
    
    //MARK: - IBAction
    
    @IBAction private func logOut(_ sender: Any) {
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        guard Auth.auth().currentUser != nil else {
            let notLoginAlert = UIAlertController(title: "You haven't logged in yet!", message: nil, preferredStyle: .alert)
            let login = UIAlertAction(title: "LOG IN", style: .default, handler: { (_) in
                self.configureAuth()
            })
            notLoginAlert.addAction(login)
            notLoginAlert.addAction(cancel)
            self.present(notLoginAlert, animated: true, completion: nil)
            return
        }
        let logOutAlert = UIAlertController(title: "Log Out?", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "YES", style: .default) { (_) in
            do {
                try Auth.auth().signOut()
            }catch {
                print("unable to sign out")
            }
        }
        logOutAlert.addAction(ok)
        logOutAlert.addAction(cancel)
        present(logOutAlert, animated: true, completion: nil)
    }
    @IBAction private func fireBonFire(_ sender: Any) {
        
        guard currentUser != nil else {
            promptToLogin()
            return
        }
        
        bonFireCreatView = UIView.instanceFromNib(nibName: "FireBonFireView") as? FireBonFireView
        bonFireCreatView?.campSiteNameTextField.text = catchedCampsiteName ?? nil
        if let image = catchedCampsiteImage?.copy() {
            bonFireCreatView?.profileImageView.image = (image as! UIImage)
        }
        bonFireCreatView?.okButton.isEnabled = catchedCampsiteName == nil ? false : true
        bonFireCreatView?.delegate = self
        bonFireCreatView?.alpha = 0
        self.view.addSubview(bonFireCreatView!)
        if let view = bonFireCreatView {
            let originalY = view.insideView.frame.origin.y
            view.insideView.frame.origin.y = view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.insideView.frame.origin.y = originalY
                view.alpha = 1
            }
        }
    }
    @IBAction func goToCampsiteList(_ sender: Any) {
        guard currentUser != nil else {
            promptToLogin()
            return
        }
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "CampsiteListsTableViewController") as! CampsiteListsTableViewController
        vc1.currentUser = self.currentUser
        let nc = UINavigationController(rootViewController: vc1)
        DispatchQueue.main.async {
            self.present(nc, animated: true, completion: nil)
        }
    }
    
    fileprivate func promptToLogin() {
        let loginAlert = UIAlertController(title: "Need Login", message: "To have fun in BonFire, you need to log in!🙋‍♂️🙋", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "Login!", style: .default) { (_) in
            self.configureAuth()
        }
        let noAction = UIAlertAction(title: "No, thanks.", style: .default, handler: nil)
        loginAlert.addAction(loginAction)
        loginAlert.addAction(noAction)
        present(loginAlert, animated: true, completion: nil)
    }
    
    private func createBonFire() {
        
        FirebaseClient.sharedInstance.createCampsiteWithUser(user: currentUser!, campsiteName: catchedCampsiteName!, userLocation: userLocation, profileImage:catchedCampsiteImage!) { (campsite) in
            self.campsiteForPass = campsite
            DispatchQueue.main.async {
                self.catchedCampsiteName = nil
                self.catchedCampsiteImage = nil
                self.presentCampsiteListVC()
            }
        }
    }
    
    fileprivate func lightTheFier() {
        var points = [CGPoint]()
        let userPoint = mapView.convert(mapView.userLocation.coordinate, toPointTo: coverImageView)
        if isExtexndedBoundsContainsPoint(point: userPoint) {
            points.append(userPoint)
        }
        for pin in campsiteAnnotations {
            let point = mapView.convert(pin.coordinate, toPointTo: coverImageView)
            if isExtexndedBoundsContainsPoint(point: point) {
                points.append(point)
            }
        }
        DispatchQueue.main.async {
            self.coverImageView.image = self.getMaskedImage(points: points, zoomLevel: Int(self.mapView.zoomLevel()))
        }
    }
    
    private func isExtexndedBoundsContainsPoint(point:CGPoint) -> Bool {
        let rect = CGRect(x: view.bounds.minX - (CGFloat(zoomLevel) * campsiteRadius), y: view.bounds.minY - (CGFloat(zoomLevel) * campsiteRadius), width: view.bounds.width + (2 * (CGFloat(zoomLevel) * campsiteRadius)), height: view.bounds.height + (2 * (CGFloat(zoomLevel) * campsiteRadius)))
        return rect.contains(point)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    //MARK: - Mask Image Maker
    private func getOringinalImageFromPath() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(coverImageView.bounds.size, false, 0.0)
        let path = UIBezierPath(rect: coverImageView.bounds)
        UIColor.black.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func getMaskImageFromPath(points:[CGPoint], scale:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(coverImageView.bounds.size, false, 0.0)
        UIColor.blue.setFill()
        for point in points {
            let rect = CGRect(x: point.x - (scale*campsiteRadius), y: point.y - (scale*campsiteRadius), width: 2*scale*campsiteRadius, height: 2*scale*campsiteRadius)
            let path = UIBezierPath(ovalIn: rect)
            path.fill()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func getMaskedImage(points:[CGPoint], zoomLevel:Int) -> UIImage{
        let orUiImage = getOringinalImageFromPath()
        guard points.count > 0 else {
            return orUiImage
        }
        let orCgImage = orUiImage.cgImage!
        let maskImage = getMaskImageFromPath(points: points, scale: CGFloat(zoomLevel)).cgImage
        let mask = CGImage(maskWidth: maskImage!.width, height: maskImage!.height, bitsPerComponent: maskImage!.bitsPerComponent, bitsPerPixel: maskImage!.bitsPerPixel, bytesPerRow: maskImage!.bytesPerRow, provider: maskImage!.dataProvider!, decode: nil, shouldInterpolate: false)
        let maskRef = orCgImage.masking(mask!)
        let image = UIImage(cgImage: maskRef!)
        return image
    }
    
    fileprivate func fireTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { [weak self] _ in
            self?.lightTheFier()
        })
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension MainMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.image = UIImage(named: "fireView")
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        mapView.isUserInteractionEnabled = false
        if view.annotation is MKUserLocation {
            mapView.isUserInteractionEnabled = true
            return
        }
        guard currentUser != nil else {
            promptToLogin()
            mapView.isUserInteractionEnabled = true
            return
        }
        campsiteForPass = (view.annotation as! CampsiteAnnotation).campsite
        checkLocationAuthorizedWithPScopeWhenSelectCampsite()
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        fireTimer()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        invalidateTimer()
        lightTheFier()
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.canShowCallout = false
        }
    }
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapViewSetUserRegion()
        }
    }
}

extension MainMapViewController {
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if let infoView = self.viewForHandleImagePick, infoView == self.userInfoEditView {
                self.userInfoEditView?.avatarImageView.image = editImage
            }else if let infoView = self.viewForHandleImagePick, infoView == self.bonFireCreatView{
                self.bonFireCreatView?.profileImageView.image = editImage
            }
            
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let infoView = self.viewForHandleImagePick, infoView == self.userInfoEditView {
                self.userInfoEditView?.avatarImageView.image = originalImage
            }else if let infoView = self.viewForHandleImagePick, infoView == self.bonFireCreatView{
                self.bonFireCreatView?.profileImageView.image = originalImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MainMapViewController:FireBonFireViewDelegate {
    //MARK:FireBonFireViewDelegate
    func didCancelFireABonFire() {
        removeBonFireView()
    }
    
    func removeBonFireView() {
        if let view = self.bonFireCreatView {
            UIView.animate(withDuration: 0.5, animations: {
                view.insideView.frame.origin.y = view.frame.height
            }) { (_) in
                self.bonFireCreatView?.removeFromSuperview()
                self.bonFireCreatView = nil
            }
        }
    }
    
    func didFinishedFireABonFire(campsiteName: String, profileImage: UIImage) {
        catchedCampsiteName = campsiteName
        catchedCampsiteImage = profileImage
        checkLocationAuthorizedWithPScopeWhenCreateBonFire()
    }
    
    func didTapProfileImageView() {
        if let infoView = self.bonFireCreatView {
            self.viewForHandleImagePick = infoView
            handlePhotoSelector()
        }
        
    }
}

extension MainMapViewController:CampsiteInfoViewDelegate {
    //MARK:CampsiteInfoViewDelegate
    func didEnterCampsite() {
        switch self.campsiteView!.enterButton.currentTitle! {
        case "Enter":
            FirebaseClient.sharedInstance.updateUserCampsiteLastMessageAndBadge(user: currentUser!, campsite: campsiteForPass!, isViewed: true, completion: { (isUpdateSuccedd) in
                if isUpdateSuccedd {
                    self.presentCampsiteListVC()
                }
            })
        case "Join" :
            FirebaseClient.sharedInstance.setUserForMemberOfCampsiteWithId(user: currentUser!, campsite: campsiteForPass!) {
                self.presentCampsiteListVC()
            }
        default:
            break
        }
    }
    func didCancel() {
        self.removeCampsiteInfoView()
    }
    
    fileprivate func presentCampsiteListVC() {
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "CampsiteListsTableViewController") as! CampsiteListsTableViewController
        vc1.currentUser = self.currentUser
        vc1.nowPresentedCampsite = campsiteForPass
        let nc = UINavigationController(rootViewController: vc1)
        DispatchQueue.main.async {
            self.campsiteView?.removeFromSuperview()
            self.present(nc, animated: true, completion: nil)
        }
    }
}

extension MainMapViewController:UserInfoEditViewDelegate {
    func userInfoEditViewNameEmptyAlert() {
        let alert = UIAlertController(title: "Error", message: "Name can't be empty!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    func userInfoEditViewDidCancel() {
        self.userInfoEditView?.removeFromSuperview()
        self.userInfoEditView = nil
    }
    func userInfoEditViewAvatarImageViewDidTap() {
        if let infoView = self.userInfoEditView {
            self.viewForHandleImagePick = infoView
            handlePhotoSelector()
        }
    }
    func userInfoEditViewInfoDidSave(info: InfoStruct) {
        FirebaseClient.sharedInstance.uploadAvatarImage(image: info.avatar, quality: 0.1) { (downloadUrl) in
            if let userId = FirebaseClient.sharedInstance.currentUser?.uid, let email = FirebaseClient.sharedInstance.currentUser?.email {
                FirebaseClient.sharedInstance.updateUserOnDatabaseWithUserId(userId: userId, email: email, displayName: info.displayName, about: info.about, avatarUrl: downloadUrl, completion: { (user) in
                    guard user != nil else { return }
                    self.currentUser = user
                })
            }
        }
    }
    func userInfoEditViewInfoDidCreating(info: InfoStruct) {
        let activity = UtilityFunction.shared.activityIndicatorViewWithCnterFrame(style: .gray, targetView: self.userInfoEditView!)
        activity.startAnimating()
        FirebaseClient.sharedInstance.uploadAvatarImage(image: info.avatar, quality: 0.1) { (downloadUrl) in
            if let userId = FirebaseClient.sharedInstance.currentUser?.uid, let email = FirebaseClient.sharedInstance.currentUser?.email {
                FirebaseClient.sharedInstance.creatUserOnDatabaseWithUserId(userId: userId, email: email, displayName: info.displayName, about: info.about, avatarUrl: downloadUrl, completion: { (user) in
                    guard user != nil else { return }
                    self.currentUser = user
                    DispatchQueue.main.async {
                        if let view = self.userInfoEditView {
                            UIView.animate(withDuration: 0.3, animations: {
                                view.alpha = 0
                            }, completion: { (_) in
                                activity.stopAnimating()
                                activity.removeFromSuperview()
                                view.removeFromSuperview()
                            })
                        }
                    }
                })
            }
        }
    }
}
