//
//  Extensions.swift
//  Weathery
//
//  Created by Kaan Yalçınkaya on 20.01.2023.
//

import Foundation
import UIKit
import CoreLocation

// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    // Arama düğmesine basıldığında metin alanının düzenlemesini sonlandır.
    @objc func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    // Enter tuşuna basıldığında metin alanının düzenlemesini sonlandır.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // Metin alanının düzenlemesi sonlandırılmadan önce metin alanı boş ise uyarı ver.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // Metin alanının düzenlemesi sonlandığında hava durumu servisi araması yap.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            weatherService.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    @objc func locationPressed(_ sender: UIButton) {
        // Konum isteği.
        locationManager.requestLocation()
    }
    
    // Konum güncellendiğinde çalışır.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // En son konumun alınması
        if let location = locations.last {
            // Konum güncellemelerinin durdurulması
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            // Hava durumunun alınması
            weatherService.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    // Konum alınırken hata oluştuğunda çalışır.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherServiceDelegate {
    
    // Hava durumu alındığında çalışır.
    func didFetchWeather(_ weatherService: WeatherService, _ weather: WeatherModel) {
        // Sıcaklık label'ını günceller.
        self.temperatureLabel.attributedText = self.makeTemperatureText(with: weather.temperatureString)
        // Durum resmini günceller.
        self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        // Şehir label'ını günceller.
        self.cityLabel.text = weather.cityName
    }
    
    // Hata oluştuğunda.
    func didFailWithError(_ weatherService: WeatherService, _ error: ServiceError) {
        
        // Hata mesajı.
        let message: String
        
        // Hata türüne göre mesajı ayarlar.
        switch error {
        case .network(statusCode: let statusCode):
            message = "Ağ hatası. Durum kodu. Status code: \(statusCode)."
        case .parsing:
            message = "JSON hava durumu verisi işlenemiyor."
        case .general(reason: let reason):
            message = reason
        }
        // Hata uyarısını gösterir.
        showErrorAlert(with: message)
    }
    
    // Hata Pop-up.
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error fetching weather",
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
