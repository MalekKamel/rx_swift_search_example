//
//  ViewController.swift
//  RxSwiftExample
//
//  Created by Sha on 6/30/18.
//
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cities = [ // mocked data source
        City(name: "Cairo"),
        City(name: "Oslo"),
        City(name: "London"),
        City(name: "Praga"),
        City(name: "Berlin"),
        City(name: "Warsaw")
    ]
    
    let disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let searchResults: Observable<[City]> = searchBar
            .rx // RxCocoa extension
            .text // Observable property, thanks to RxCocoa
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            .flatMapLatest{ query -> Observable<[City]> in//
                return .just(self.cities.filter { $0.name.contains(query)})// Try to find query in cities
            }
            .observeOn(MainScheduler.instance)
        
        searchResults
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) {
                (row, model, cell: UITableViewCell) in
                cell.textLabel?.text = model.name
            }
            .disposed(by: disposeBag)
    }
    
}

