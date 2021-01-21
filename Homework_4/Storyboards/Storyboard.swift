//
//  Storyboard.swift
//  Homework_4
//
//  Created by Sasha on 19/01/2021.
//

import UIKit





enum Storyboard: String {
    case main
    
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue.capitalized, bundle: nil)
    }
    
    func viewController<T: UIViewController>(viewControllerTypes: T.Type) -> T {
        let storyboardID = String(describing: viewControllerTypes)
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
    
}

