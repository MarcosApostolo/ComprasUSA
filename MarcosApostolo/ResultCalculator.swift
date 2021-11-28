//
//  ResultCalculator.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 16/11/21.
//

import Foundation

class ResultCalculator {
    private var purchases: [Purchase] = []
    
    private var iof: Double = DEFAULT_IOF_VALUE
    private var dolar: Double = DEFAULT_DOLAR_VALUE
    
    init(iof: Double, dolar: Double) {
        if (iof != 0 && dolar != 0) {
            self.iof = iof
            self.dolar = dolar
        }
    }
    
    public func setIOF(with iof: Double) {
        self.iof = iof
    }
    
    public func setDolar(with dolar: Double) {
        self.dolar = dolar
    }
    
    public func setPurchases(with purchases: [Purchase]) {
        self.purchases = purchases
    }
    
    public func getValueInDolars() -> Double {
        return getTotalSumInDolars()
    }
    
    private func getTotalSumInDolars() -> Double {
        return purchases.reduce(0.0) { partialResult, purchase in
            return partialResult + purchase.value
        }
    }
    
    public func getValueInBRL() -> Double {
        let valuesInDolarWithTaxes = getValuesInDolarWithTaxes()
        

        let BRLValues = getBRLValues(using: valuesInDolarWithTaxes)

        let valueInBRLWithTax = getBRLValueWithIOF(using: BRLValues.tax)

        return BRLValues.cash + valueInBRLWithTax
    }
    
    private func getValuesInDolarWithTaxes() -> (tax: Double, cash: Double) {
        let purchasesWithCC = purchases.filter { purchase in
            return purchase.isCardPurchase
        }
        
        let purchasesInCash = purchases.filter { purchase in
            return !purchase.isCardPurchase
        }
        
        let CCPurchasesWithTaxes = purchasesWithCC.reduce(0.0) { partialResult, purchase in
            if let state = purchase.state {
                let percentageValue = (purchase.value * state.taxValue) / 100
                
                return partialResult + percentageValue + purchase.value
            }
            
            return partialResult + purchase.value
        }
        
        let cashPurchases = purchasesInCash.reduce(0.0) { partialResult, purchase in
            if let state = purchase.state {
                let percentageValue = (purchase.value * state.taxValue) / 100
                
                return partialResult + percentageValue + purchase.value
            }
            
            return partialResult + purchase.value
        }
        
        return (CCPurchasesWithTaxes, cashPurchases)
    }
    
    private func getBRLValues(using values: (tax: Double, cash: Double)) -> (tax: Double, cash: Double) {
        
        return (values.tax * dolar, values.cash * dolar)
    }
    
    private func getBRLValueWithIOF(using BRLValue: Double) -> Double {
        
        let percentageValue = (BRLValue * iof) / 100

        return BRLValue + percentageValue
    }
}
