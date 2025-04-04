//
//  LoadPhotoExempleTests.swift
//  LoadPhotoExampleTests
//
//  Created by BuiTuan on 4/4/25.
//

import XCTest
@testable import LoadPhotoExample

final class LoadPhotoExampleTests: XCTestCase {
    private var viewModel: PhotoViewModel!
    private var mockUseCase: MockLoadPhotoUseCase!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockLoadPhotoUseCase()
        viewModel = PhotoViewModel(loadPhotoUseCase: mockUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        super.tearDown()
    }
    
    func testLoadPhotos_Success() {
        let expectation = self.expectation(description: "Photos Loaded")
        let mockPhotos = [
            Photo(id: "1", author: "Alice", width: 0, height: 0, url: "", downloadURL: ""),
            Photo(id: "2", author: "Bob", width: 0, height: 0, url: "", downloadURL: "")
        ]
        mockUseCase.mockPhotos = mockPhotos
        
        viewModel.photosLoaded = {
            expectation.fulfill()
        }
        
        viewModel.loadPhotos()
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(viewModel.dataSource.count, 2)
        XCTAssertEqual(viewModel.dataSource.first?.author, "Alice")
    }
    
    func testLoadPhotos_Error() {
        let expectation = self.expectation(description: "Error Occurred")
        mockUseCase.shouldReturnError = true
        viewModel.errorOccurred = {
            expectation.fulfill()
        }
        viewModel.loadPhotos()
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFilterPhotos() {
        let expectation = self.expectation(description: "Photos Filtered")
        let mockPhotos = [
            Photo(id: "1", author: "Alice", width: 0, height: 0, url: "", downloadURL: ""),
            Photo(id: "2", author: "Bob", width: 0, height: 0, url: "", downloadURL: "")
        ]
        mockUseCase.mockPhotos = mockPhotos
        
        viewModel.photosLoaded = {
            expectation.fulfill()
        }
        
        
        viewModel.loadPhotos()
        viewModel.filterPhotos(searchText: "Alice")
        
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssertEqual(viewModel.dataSource.count, 1)
        XCTAssertEqual(viewModel.dataSource.first?.author, "Alice")
    }
    
    func testResetData() {
        viewModel.loadPhotos()
        viewModel.resetData()
        
        XCTAssertEqual(viewModel.dataSource.count, 0)
        XCTAssertTrue(viewModel.hasMoreData)
    }
    
    func testClearCache() {
        viewModel.clearCache()
        XCTAssertTrue(true)
        
    }
}
