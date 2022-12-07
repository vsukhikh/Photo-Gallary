//
//  ViewController.swift
//  Milestone: Projects 10-12
//
//  Created by Vladimir Sukhikh on 2022-12-06.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var images = [Photo]()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "photos") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                images = try jsonDecoder.decode([Photo].self, from: savedData)
            } catch {
                print("Failed to load photos.")
            }
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearTapped))

        }

    // Clear Method
    @objc func clearTapped() {
        let ac = UIAlertController(title: "Delete all photos?", message: "This action is irreversible.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.clear()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func clear() {
        // Deleting Files from App Directory
        let fileManager = FileManager.default
        for image in images {
            let filePath = getDocumentsDirectory().appendingPathComponent(image.image)
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete the file from the documents directory
                do {
                    try fileManager.removeItem(at: filePath)
                        print("File deleted successfully!")
                } catch {
                    print("Error deleting file: \(error.localizedDescription)")
                }
            }
        }
        
        // Remove from array
        images.removeAll()
        
        tableView.reloadData()
    }
    
    // MARK: - Picking Photos
    @objc func addTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let photo = Photo(image: imageName, name: "Unknown")
        images.append(photo)
        save()
        tableView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath)
        cell.textLabel?.text = images[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.image = images[indexPath.row]
            vc.images = images
            vc.indexPath = indexPath
            navigationController?.pushViewController(vc, animated: true)
        }
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
