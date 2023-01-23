//
//  WeatherService.swift
//  Weathery
//
//  Created by Kaan Yalçınkaya on 20.01.2023.
//

import Foundation
import CoreLocation

enum ServiceError: Error {
    // Ağ hatası durumunda kullanılacak hata türü.
    case network(statusCode: Int)
    // Diğer hata durumları için kullanılacak genel hata türü. Sebep ile birlikte gelecektir.
    case parsing
    case general(reason: String)
}

protocol WeatherServiceDelegate: AnyObject {
    // Hava durumu bilgileri elde edildiğinde çağrılacak fonksiyon.
    func didFetchWeather(_ weatherService: WeatherService, _ weather: WeatherModel)
    // Hata oluştuğunda çağrılacak fonksiyon. Hata türü ile birlikte gelecektir.
    func didFailWithError(_ weatherService: WeatherService, _ error: ServiceError)
}

struct WeatherService {
    // Hava durumu bilgileri elde edildiğinde veya hata oluştuğunda çağrılacak delegate nesnesi.
    weak var delegate: WeatherServiceDelegate?
    
    // API
    let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?appid=ce5edb27133f4b3a9eab5abfe8072942&units=metric")!
    
    // Verilen şehir adına göre hava durumu bilgilerini elde etmek için API isteği yapar.
    func fetchWeather(cityName: String) {
        
        // Şehir adını URL uyumlu hale getirir.
        guard let urlEncodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            // Şehir adı URL uyumlu hale getirilemediyse hata verir.
            assertionFailure("Could not encode city named: \(cityName)")
            return
        }
        
        let urlString = "\(weatherURL)&q=\(urlEncodedCityName)"
        // API isteği yapar.
        performRequest(with: urlString)
    }
    
    // Verilen koordinatlarla hava durumu bilgilerini elde etmek için API isteği yapar.
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // API isteği yapar ve sonucu işler.
    func performRequest(with urlString: String) {
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // İstek sonucunun işlenmesi
            guard let unwrapedData = data,
                  let httpResponse = response as? HTTPURLResponse
            else { return }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    // Ağ hatası oluştu.
                    let generalError = ServiceError.general(reason: "Check network availability.")
                    self.delegate?.didFailWithError(self, generalError)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    // HTTP durum kodu 200-299 arasında değilse, ağ hatası oluşmuş demektir.
                    self.delegate?.didFailWithError(self, ServiceError.network(statusCode: httpResponse.statusCode))
                }
                return
            }
            
            // JSON verisini işler
            guard let weather = self.parseJSON(unwrapedData) else { return }
            
            DispatchQueue.main.async {
                // Hava durumu bilgileri başarıyla elde edildi.
                self.delegate?.didFetchWeather(self, weather)
            }
        }
        task.resume()
    }
    
    // JSON verisini WeatherModel yapısına dönüştürür.
    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        
        // JSON verisi WeatherData yapısına dönüştürülür.
        guard let decodedData = try? JSONDecoder().decode(WeatherData.self, from: weatherData) else {
            DispatchQueue.main.async {
                // JSON verisi işlenirken hata oluştu.
                self.delegate?.didFailWithError(self, ServiceError.parsing)
            }
            return nil
        }
        
        // WeatherModel yapısı oluşturulur.
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        
        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        
        return weather
    }
}
