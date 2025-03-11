//
//  WikiDataModel.swift
//  WhatFlower
//
//  Created by admin on 01.10.2022.
//

import Foundation

struct WikiDataModel {
    
var query: Pages
    
    
}

struct Pages {
var id: PageId
}

struct PageId {
var pageid: Int
    var title: String
    var extract: String
    
    
    
}
