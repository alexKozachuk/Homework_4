//
//  ViewController.swift
//  Homework_4
//
//  Created by Sasha on 18/01/2021.
//

import UIKit


class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var dataSource = makeDataSource()
    private var networkService = NetworkService()
    private var storage = CityStorage()
    
    private var weathers: [CurrentWeather] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNavBar()
        reloadWeaters()
        
        checkFirstLoad() { [weak self] error in
            if let error = error {
                self?.presentInformAlertController(title: "Error", message: error.localizedDescription)
            } else {
                self?.reloadWeaters()
            }
            
        }
        
    }

}


private extension MainViewController {
    
    func setupNavBar() {
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let reloadButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadWeaters))
        
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.leftBarButtonItem = reloadButtonItem
    }
    
    func setupCollectionView() {
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                [weak self] action, view, completion in
                guard let self = self else {
                    completion(false)
                    return
                }
                let cities = self.storage.getCities()
                let city = cities[indexPath.row]
                self.storage.delete(city: city)
                self.reloadWeaters()
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout

    }
}

// MARK: - Update CollectionView Methods

private extension MainViewController {
    func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CurrentWeather>()
        snapshot.appendSections([.main])
        snapshot.appendItems(weathers)
        dataSource.apply(snapshot)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let weather = weathers[indexPath.row]
        let vc: DetailViewController = .instantiate(from: .main)
        vc.setup(with: weather)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Create Cell Registration

private extension MainViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, CollectionPresentable> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            var config = cell.defaultContentConfiguration()
            config.text = item.cityName
            config.secondaryText = item.temp
            cell.contentConfiguration = config
        }
    }
}

// MARK: - Create UICollectionViewDiffableDataSource

private extension MainViewController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, CurrentWeather> {
        let cellRegistration = makeCellRegistration()
        
        let collectionViewDataSource = UICollectionViewDiffableDataSource<Section, CurrentWeather>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, item in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
        
        return collectionViewDataSource
    }
}

// MARK: Section

extension MainViewController {
    enum Section {
        case main
    }
}

// MARK: Bar Button Actions Methods

private extension MainViewController {
    
    @objc func reloadWeaters() {
        let cities = storage.getCities()
        
        networkService.getCurrentWeather(in: cities) { [weak self] result in
            switch result {
            case .success(let currentWeaters):
                self?.weathers = currentWeaters
                self?.updateList()
            case .failure(let error):
                self?.presentInformAlertController(title: "Error", message: error.localizedDescription)
            }
            
        }
    }
    
    @objc func addButtonTapped() {
        
        let ac = UIAlertController(title: "Enter City Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            let answer = ac.textFields![0]
            guard let text = answer.text else { return }
            self?.networkService.getCity(by: text) { [weak self] result in
                
                switch result {
                case .success(let city):
                    self?.storage.append(city)
                    self?.reloadWeaters()
                case .failure(let error):
                    switch error {
                    case .errorWithResponse(let response):
                        self?.presentInformAlertController(title: response.cod, message: response.message)
                    case .simpleError(let error):
                        self?.presentInformAlertController(title: "Error", message: error.localizedDescription)
                    }
                }
                
            }
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        ac.addAction(submitAction)
        ac.addAction(cancelAction)

        present(ac, animated: true)
    }
    
}

// MARK: Helper Methods

private extension MainViewController {
    
    func presentInformAlertController(title: String, message: String, animated: Bool = true) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(okAction)
        present(ac, animated: animated)
    }
    
    func checkFirstLoad(completion: @escaping (Error?) -> Void) {
        let userDefaults = UserDefaults.standard
        let firstRun = userDefaults.bool(forKey: "First Run")
        guard firstRun == false else { return }
        
        let cityStringArr = ["Киев", "Днепр", "Запорожье"]
        
        networkService.getCities(by: cityStringArr) { [weak self] result in
            
            switch result {
            case .success(let cities):
                self?.storage.save(cities)
                userDefaults.setValue(true, forKey: "First Run")
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        
        }
    }
    
}
