//
//  IAPViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 5.03.2021.
//

import UIKit
import StoreKit

protocol MyDataSendingDelegateProtocol {
    func isPurchased(myData: String)
}

class IAPViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: MyDataSendingDelegateProtocol? = nil
    let productTitle = ["1 Saat","2 Saat","3 Saat"]
    let productDescription = ["Her Adım x2 Adım","Her Adım x2 Adım","Her Adım x2 Adım"]
    let productPrice = ["5 TL","10 TL","15 TL"]
     
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var popUpView: UIView!
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 20
        popUpView.layer.masksToBounds = true
        let productTableViewCell = UINib(nibName: "ProductTableViewCell", bundle: nil)
        self.productTableView.register(productTableViewCell, forCellReuseIdentifier: "product")
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.backgroundColor = .white
        productTableView.separatorStyle = .none
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productTitle.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return productTableView.frame.height / CGFloat(productTitle.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductTableViewCell
        cell.productTitle.text = productTitle[indexPath.row]
        cell.productDescription.text = productDescription[indexPath.row]
        cell.productPrice.text = productPrice[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.isPurchased(myData: "purchased")
        dismiss(animated: true, completion: nil)
    }
}

////
////  IAPViewController.swift
////  StepCounterApp
////
////  Created by Muhammet Taha Genç on 5.03.2021.
////
//
//import UIKit
//import StoreKit
//
//protocol MyDataSendingDelegateProtocol {
//    func isPurchased(myData: String)
//}
//
//class IAPViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver  {
//
//    private var models = [SKProduct]()
//    var delegate: MyDataSendingDelegateProtocol? = nil
//
//    @IBOutlet weak var productTableView: UITableView!
//    @IBOutlet weak var popUpView: UIView!
//    @IBAction func backBtn(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        SKPaymentQueue.default().add(self)
//        popUpView.layer.cornerRadius = 20
//        popUpView.layer.masksToBounds = true
//        let productTableViewCell = UINib(nibName: "ProductTableViewCell", bundle: nil)
//        self.productTableView.register(productTableViewCell, forCellReuseIdentifier: "product")
//        productTableView.delegate = self
//        productTableView.dataSource = self
//        productTableView.backgroundColor = .white
//        productTableView.separatorStyle = .none
//        fetchProducts()
//    }
//
//    //MARK: - TableView Methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return models.count
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return productTableView.frame.height / 3
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductTableViewCell
//        let product = models[indexPath.row]
//        print(product.localizedDescription)
//        print(product.localizedTitle)
//        print(product.price)
//        cell.productTitle.text = product.localizedTitle
//        cell.productDescription.text = product.localizedDescription
//        cell.productPrice.text = "\(product.priceLocale.currencySymbol ?? "$")\(product.price)"
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        //Shows purchases
//        let payment = SKPayment(product: models[indexPath.row])
//        SKPaymentQueue.default().add(payment)
//    }
//
//    //MARK: - Products Methods
//
//    enum Product: String, CaseIterable{
//        case removeAdds = "com.myapp.11"
//        case unlockEverything = "com.myapp.12"
//        case getGems = "com.myapp.13"
//        case deneme = "com.temporary.id"
//    }
//
//    private func fetchProducts() {
//        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
//        request.delegate = self
//        request.start()
//    }
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        DispatchQueue.main.async {
//            print("Count: \(response.products.count)")
//            self.models = response.products
//            self.productTableView.reloadData()
//        }
//    }
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        //no implement
//        transactions.forEach({
//            switch $0.transactionState {
//            case .purchasing:
//                print("purchasing")
//            case .purchased:
//                if self.delegate != nil {
//                    self.delegate?.isPurchased(myData: "purchased")
//                    dismiss(animated: true, completion: nil)
//                }
//                SKPaymentQueue.default().finishTransaction($0)
//            case .failed:
//                print("did not purchase")
//                SKPaymentQueue.default().finishTransaction($0)
//            case .restored:
//                break
//            case .deferred:
//                break
//            @unknown default:
//                break
//            }
//        })
//
//    }
//}
