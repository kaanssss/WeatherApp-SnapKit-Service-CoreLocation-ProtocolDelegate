//
//  ViewController.swift
//  Weathery
//
//  Created by Kaan Yalçınkaya on 17.01.2023.
//

import UIKit
import SnapKit
import CoreLocation

private struct LocalSpacing {
    static let buttonSizeSmall = CGFloat(44)
    static let buttonSizelarge = CGFloat(120)
}


class WeatherViewController: UIViewController {
    
    var weatherService = WeatherService()
    let locationManager = CLLocationManager()
    
    let backgroundView = UIImageView()
    
    let rootStackView = UIStackView()
    let searchStackView = UIStackView()
    let locationButton = UIButton()
    let searchButton = UIButton()
    let searchTextField = UITextField()
    
    let conditionImageView = UIImageView()
    let temperatureLabel = UILabel()
    let cityLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        setup()
    }
}

extension WeatherViewController {
    
    func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherService.delegate = self
        searchTextField.delegate = self
    }
    
    func style() {
        
        //LocationButton
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        locationButton.addTarget(self, action: #selector(locationPressed(_:)), for: .primaryActionTriggered)
        locationButton.tintColor = .label
        
        //BackgroundView
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = UIImage(named: "day-background")
        backgroundView.contentMode = .scaleAspectFill
        
        //RootStackView
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        rootStackView.alignment = .trailing
        rootStackView.spacing = 10
        
        //SearchStackView
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.spacing = 8
        
        //SearchButton
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .black
        
        //SearchTextField
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.font = UIFont.preferredFont(forTextStyle: .title1)
        searchTextField.placeholder = "Search"
        searchTextField.textAlignment = .right
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .systemFill
        
        //ConditionImageView
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.image = UIImage(systemName: "sun.max")
        conditionImageView.tintColor = .black
        
        //TemperatureLabel
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 80)
        temperatureLabel.attributedText = makeTemperatureText(with: "18")
        temperatureLabel.textColor = .black
        
        //CityLabel
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.text = "İstanbul"
        cityLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        cityLabel.textColor = .black
        
    }
    
    func makeTemperatureText(with temperature: String) -> NSAttributedString {
        
        // Kalın yazı özellikleri
        var boldTextAttributes = [NSAttributedString.Key: AnyObject]()
        boldTextAttributes[.foregroundColor] = UIColor.black
        boldTextAttributes[.font] = UIFont.boldSystemFont(ofSize: 100)
        
        // Normal yazı özellikleri
        var plainTextAttributes = [NSAttributedString.Key: AnyObject]()
        plainTextAttributes[.font] = UIFont.systemFont(ofSize: 80)
        
        // Metin oluşturulur ve kalın yazı özellikleri verilir.
        let text = NSMutableAttributedString(string: temperature, attributes: boldTextAttributes)
        // Metine °C eklenir ve normal yazı özellikleri verilir.
        text.append(NSAttributedString(string: "°C", attributes: plainTextAttributes))
        
        return text
    }
    
    func layout() {
        
        view.addSubview(backgroundView)
        view.addSubview(rootStackView)
        view.addSubview(searchStackView)
        
        rootStackView.addArrangedSubview(searchStackView)
        rootStackView.addArrangedSubview(conditionImageView)
        rootStackView.addArrangedSubview(temperatureLabel)
        rootStackView.addArrangedSubview(cityLabel)
        
        searchStackView.addArrangedSubview(locationButton)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(searchButton)
        
        
        //Layout
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rootStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        searchStackView.snp.makeConstraints { make in
            make.width.equalTo(rootStackView)
        }
        
        locationButton.snp.makeConstraints { make in
            make.width.height.equalTo(LocalSpacing.buttonSizeSmall)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(LocalSpacing.buttonSizeSmall)
        }
        
        conditionImageView.snp.makeConstraints { make in
            make.width.height.equalTo(LocalSpacing.buttonSizelarge)
        }
        
    }
}



