//
//  ViewSession.swift
//  iOS Beauty App
//
//  Created by Nuno Paiva | 2021

import UIKit
import RealmSwift
import OpalImagePicker
import Photos

class ViewSession: UIViewController, OpalImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imacell", for: indexPath) as! WowCollectionViewCell

        //cell.backgroundColor = .systemRed
        
        if (!imgArr.isEmpty){
            //imageNotes.image = imgArr[indexPath.row]
            cell.imgNotes.image = imgArr[indexPath.row]
        }
        
        return cell
    }
    
    public var item: SessionItem?
    
    private var dataTable = [SessionItem]()

    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var clientLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var buttonDone: UIButton!
    @IBOutlet var notesInput: UITextView!
    @IBOutlet var durationInput: UITextField!
    
    @IBOutlet var btnImage: UIButton!
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var imageNotes: UIImageView!
    
    var imagePath = URL(string: "")
    var imgData = Data()
    
    var imgDataGuarda = [Data()]
    //var imgArray = [String]()
    
    var imgArr = [UIImage()]
    
    let imagePicker = OpalImagePickerController()
    
    private let realm = try! Realm()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = .current
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("O QUE QUEREMOS: \(item!.pictures)")
        
        clientLabel.text = item?.sessionName
        titleLabel.text = item?.sessionTitle
        durationInput.text = item?.sessionDuration
        dateLabel.text = Self.dateFormatter.string(from: item!.sessionDate)
        notesInput.text = item?.sessionNotes
        if(item?.sessionDuration != ""){
            durationInput.text = item?.sessionDuration
        }
        
        //collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imacell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
//        let str = String(decoding: item!.picture!, as:UTF8.self)

//        imgArray.append(str)
                
        imgArr.removeAll()
        imgDataGuarda.removeAll()
        
        guard let myItem = self.item else {
            return
        }
                
        if (myItem.sessionState == "done"){
        
            buttonDone.isEnabled = false
            buttonDone.setTitle("Completed", for: .normal)
                    
            if(item?.pictures == nil){
                //imageNotes.image = UIImage(data: imgData as Data)
            }
            else{
                //imageNotes.image = UIImage(data: item!.picture! as Data)
                        
                print("Nome da sessão: \(item!.sessionName) e ISTO SAO AS PICS: \(item!.pictures)")
                
                for picture in item!.pictures {
                    imgArr.append(UIImage(data: picture.pictureNew! as Data)!)
                    print("ISTO É O QUE RECEBE: \(picture.pictureNew!)")
                }
//                    for pic in imgArr {
//                        //imageNotes.image = pic
//                    }
                
                
//                for picture in item!.pictures {
//
//                    imgArr.append(UIImage(data: picture as Data)!)
//
//                    for pic in imgArr {
//                        imageNotes.image = pic
//                    }
//
//                }
            }
            
            durationInput.isUserInteractionEnabled = false
            notesInput.isUserInteractionEnabled = false
            btnImage.isUserInteractionEnabled = false
            
        } else if (myItem.sessionState == "upcoming"){
            
            buttonDone.isEnabled = true
            buttonDone.setTitle("Mark as Complete", for: .normal)
            
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
        
    }

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imgArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
//
//        cell.imgView.image = UIImage(data: item!.picture! as Data)
//
//        return cell
//    }
    
    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }

        let alert = UIAlertController(title: "Are you sure you want to delete this appointment?", message: "This cannot be reverted.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {  action in
            
            self.realm.beginWrite()
            self.realm.delete(myItem)
            try! self.realm.commitWrite()

            self.deletionHandler?()
            self.navigationController?.popToRootViewController(animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func didTapButtonImage(){
//        let vc = UIImagePickerController()
//        vc.sourceType = .photoLibrary
//        vc.delegate = self
//        vc.allowsEditing = true
//        present(vc, animated: true)
        
        presentOpalImagePickerController(imagePicker, animated: true,
                                         select: {(assets) in
                                          //  print(assets)
                                      
                                            for i in assets {
                                                
                                                let image = self.convertImageFromAsset(asset: i)

                                                let data = image.pngData()
                    
                                                self.imgData = data!
                                            
                                               // self.imageNotes.image = UIImage(data: self.imgData as Data)
                                                
                                                self.imgArr.append(UIImage(data: self.imgData as Data)!)
                                                self.imgDataGuarda.append(self.imgData as Data)
                                            }
                                            
                                            self.collectionView?.reloadData()
                                            
                                            self.imagePicker.dismiss(animated: true, completion: nil)
                                            
                                            print("AQUI ESTA O QUE APARECE: \(self.imgData)")
                                            print("AQUI ESTA O ARRAY: \(self.imgArr)")
                                            print("A DATA E: \(self.imgDataGuarda)")
                                            
                                         }, cancel: {
                                            print("Cancelou")
                                         })
        
    }
        
    @IBAction func didtapDone1(_ sender: UIButton){
        guard let myItem = self.item else {
            return
        }
        
        if let duration = durationInput.text, !duration.isEmpty {
            try! realm.write{
                myItem.sessionState = "done"
                myItem.sessionDuration = duration
                myItem.sessionNotes = notesInput.text
                //myItem.picture = imgData
                
                for img in imgDataGuarda {
                    let newPicture = PictureItem()
                    newPicture.pictureNew = img
                    myItem.pictures.append(newPicture)
                    print("GUARDEI: \(newPicture)")
                }
                
                print("OLHA AMIGO, GUARDEI \(imgDataGuarda.count) FOTOS COM A DATA \(imgDataGuarda)")
            }
            
            buttonDone.isEnabled = true
            buttonDone.setTitle("Mark as Complete", for: .normal)
            
            durationInput.isUserInteractionEnabled = false
            notesInput.isUserInteractionEnabled = false
            
            deletionHandler?()
            navigationController?.popToRootViewController(animated: true)
            
            print("PRESSED BUTTON")
        }
        
    }
    
}

extension ViewSession: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                            
//            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? NSURL
//            let imageName = imageURL!.lastPathComponent
//            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//            let photoURL = NSURL(fileURLWithPath: documentDirectory)
//            let localPath = photoURL.appendingPathComponent(imageName!)

//            let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
//
//            imageNotes.image = image
//
//            let data = image!.pngData()
//
//            imgData = data!
//
//            imageNotes.image = UIImage(data: imgData as Data)
//
//            print("AQUI ESTA O QUE APARECE: \(imgData)")
//
//            picker.dismiss(animated: true, completion: nil)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
 
    func convertImageFromAsset(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return image
    }
    
}

