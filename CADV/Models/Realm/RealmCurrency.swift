//
//  RealmCurrency.swift
//  CADV
//
//  Created by Misha Vakhrushin on 22.01.2025.
//

import RealmSwift

class CurrencyEntity: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = "currency"
    @Persisted var currency: String = "RUB"
}
