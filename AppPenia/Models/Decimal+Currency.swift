//
//  Decimal+Currency.swift
//  AppPenia
//

import Foundation

extension Decimal {
    var arsFormatted: String {
        self.formatted(.currency(code: "ARS").locale(Locale(identifier: "es_AR")))
    }

    var arsFormattedNoDecimals: String {
        self.formatted(
            .currency(code: "ARS")
            .precision(.fractionLength(0))
            .locale(Locale(identifier: "es_AR"))
        )
    }
}
