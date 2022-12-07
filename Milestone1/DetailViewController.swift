//
//  DetailViewController.swift
//  Milestone: Projects 10-12
//
//  Created by Vladimir Sukhikh on 2022-12-06.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var image: Photo?
    var images: [Photo]?
    var indexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = image?.name
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        
        if let imageToLoad = image {
            let path: URL
            
            if #available(iOS 16.0, *) {
                path = getDocumentsDirectory().appending(path: imageToLoad.image)
            } else {
                path = getDocumentsDirectory().appendingPathComponent(imageToLoad.image)
            }
           
            imageView.image = UIImage(contentsOfFile: path.path)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func editTapped() {
        let ac = UIAlertController(title: "Rename your photo", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        })

        present(ac, animated: true)
    }

    func submit(_ answer: String) {
        image?.name = answer
        title = answer
        images![indexPath!.row].name = answer
        save()
    }


    // MARK: - User Defaults Save
    ///Method to save [Photo]  to UserDefaults
    func save() {
        let jsonEncoder = JSONEncoder()

        if let savedData = try? jsonEncoder.encode(images) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photos")
        } else {
            print("Failed to save photos.")
        }
    }

}
