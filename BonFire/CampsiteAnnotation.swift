//
//  CampsiteAnnotation.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/3.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation

class CampsiteAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var campsite:Campsite
    
    init(coordinate: CLLocationCoordinate2D, campsite:Campsite, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.campsite = campsite
        self.title = title
        self.subtitle = subtitle
    }
}
