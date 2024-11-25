//
//  Pagination.swift
//  SwordCat
//
//  Created by Rui Barbosa on 25/11/2024.
//

struct Pagination {
    var hasMoreItems: Bool = true
    var limit: Int = 10
    var nextPage: Int = 0
    var thresholdItemId: String?
}
