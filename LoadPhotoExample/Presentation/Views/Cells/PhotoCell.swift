//
//  PhotoCell.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    static let infoHeight: CGFloat = 80.0
    private var indexPath: IndexPath?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupActivityIndicator()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        activityIndicator.stopAnimating()
    }
    
    private func setupActivityIndicator() {
        photoImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(photo: Photo, indexPath: IndexPath) {
        authorLabel.text = photo.author
        sizeLabel.text = "Size: \(photo.width)x\(photo.height)"
        photoImageView.image = nil
        activityIndicator.startAnimating()
        self.indexPath = indexPath
    }
    
    func setImage(image: UIImage, indexPath: IndexPath) {
        if(indexPath.row == self.indexPath?.row) {
            photoImageView.image = image
            activityIndicator.stopAnimating()
        }
    }
}
