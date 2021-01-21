//
//  DetailViewController.swift
//  Homework_4
//
//  Created by Sasha on 19/01/2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var subTempLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    private var currentWeather: CurrentWeather?
    private let networkService = NetworkService()
    private let storage = CityStorage()
    private var items: [Daily] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupCollectionView()
        setupForecast()
    }
    
    func setup(with currentWeather: CurrentWeather) {
        self.currentWeather = currentWeather
    }
    
}

// MARK: - Setup Methods

private extension DetailViewController {
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(type: CollectionViewCell.self)
    }
    
    func setupForecast() {
        guard let currentWeather = currentWeather else { return }
        guard let city = storage.getCity(by: currentWeather.id)  else { return }
        
        networkService.getForecast(by: city) { [weak self] result in
            switch result {
            case .success(let weatherForecast):
                guard weatherForecast.daily.count > 4 else { return }
                self?.items = Array(weatherForecast.daily[1...4])
                self?.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func setupViews() {
        guard let currentWeather = currentWeather  else { return }
        cityNameLabel.text = currentWeather.cityName
        if let weater = currentWeather.weather.first {
            descriptionLabel.text = weater.weatherDescription
        }
        mainTempLabel.text = currentWeather.temp
        subTempLabel.text = currentWeather.minMaxTemp
    }
    
}

// MARK: - UICollectionViewDataSource

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(with: CollectionViewCell.self, for: indexPath)
        
        cell.titleLabel.text = item.dt.getTime().dayOfWeek()
        cell.dayTempLabel.text = "\(Int(item.temp.day))"
        cell.nightTempLabel.text = "\(Int(item.temp.night))"
        return cell
    }
    
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left + sectionInsets.right
        let width = view.frame.width - paddingSpace
        
        return CGSize(width: width, height: 20)
      }
      
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
      
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
