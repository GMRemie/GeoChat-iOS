//
//  IAPService.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import StoreKit
class IAPService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{


    private override init(){}
    static let shared = IAPService()
    var BizCreator: CreateBizPostViewController!
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    func getProducts(){
        let products:Set = [IAPProduct.weekly.rawValue,IAPProduct.monthly.rawValue,IAPProduct.yearly.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product:IAPProduct){
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else{
            return
        }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
        
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        self.products = response.products
        print(response.products)
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue,
                             updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        SKPaymentQueue.default().finishTransaction(transaction)
        // Business marker call back
        BizCreator.businessMarkerCallBack()
        
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    

}
    

