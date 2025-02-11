//
//  RealmCategory.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.01.2025.
//

import RealmSwift

class CategoryEntity: Object {
    @Persisted var categoryType: String
    @Persisted var iconName: String
    @Persisted var isConstant: Bool
    @Persisted var name: String
}
