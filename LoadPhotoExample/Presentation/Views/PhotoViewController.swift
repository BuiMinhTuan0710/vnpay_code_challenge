//
//  PhotoViewController.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import UIKit

class PhotoViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    private let viewModel: PhotoViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearching = false
    private let activityIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .large)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    private let refreshControl = UIRefreshControl()
    
    //MARK: - init
    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PhotoViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupActivityIndicator()
        setupRefreshControl()
        setupSearchController()
        setupSwipeTyping()
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        viewModel.clearCache()
    }
    
    deinit {
        viewModel.clearCache()
    }
}

//MARK: - Private function
extension PhotoViewController {
    private func setupTableView() {
        viewModel.loadPhotos()
        tableView.registerCell(PhotoCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm kiếm ảnh..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    private func setupSwipeTyping() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .right
        tableView.addGestureRecognizer(swipeGesture)
    }
    
    @objc
    private func handleSwipe() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    @objc
    private func handleTap() {
        searchController.searchBar.resignFirstResponder()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func refreshPhotos() {
        viewModel.resetData()
        tableView.reloadData()
        viewModel.loadPhotos()
    }
    
    private func setupBindings() {
        viewModel.photosLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.errorOccurred = { [weak self] in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: self?.viewModel.errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.loadingStateChanged = { [weak self] in
            DispatchQueue.main.async {
                if self?.viewModel.isLoading == true && self?.refreshControl.isRefreshing == false {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func filterPhotos(searchText: String) {
        activityIndicator.startAnimating()
        if searchText.isEmpty {
            refreshPhotos()
        } else {
            viewModel.filterPhotos(searchText: searchText)
        }
    }
}

//MARK: - UITableViewDataSource
extension PhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(PhotoCell.self, for: indexPath)
        let photo = viewModel.dataSource[indexPath.row]
        cell.configCell(photo: photo, indexPath: indexPath)
        viewModel.loadImage(photo: photo, indexPath: indexPath) { image  in
            if let image = image {
                cell.setImage(image: image, indexPath: indexPath)
            }
            
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension PhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.dataSource.count - 1 && viewModel.hasMoreData {
            viewModel.loadPhotos()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = viewModel.dataSource[indexPath.row]
        let muti = CGFloat(photo.width) / CGFloat(photo.height)
        let width = UIScreen.main.bounds.width
        let height = width / muti
        return height + PhotoCell.infoHeight
    }
}

//MARK: - UISearchResultsUpdating
extension PhotoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if isSearching, let searchText = searchController.searchBar.text {
            let pattern = "^[a-zA-Z0-9!@#$%^&*():.,<>/\\[\\]? ]*$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(location: 0, length: searchText.utf16.count)
            
            if regex?.firstMatch(in: searchText, range: nsRange) == nil {
                let cleanedText = searchText.folding(options: .diacriticInsensitive, locale: .current)
                searchController.searchBar.text = cleanedText
                return
            }
            filterPhotos(searchText: searchText)
        }
    }
}

//MARK: - UISearchBarDelegate
extension PhotoViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isSearching = false
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isFilter = false
        isSearching = false
        viewModel.loadPhotos()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = true
    }
}
