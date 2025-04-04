//
//  ImageLoadOperationTests.swift
//  LoadPhotoExampleTests
//
//  Created by Bui Tuan on 4/4/25.
//

import XCTest
@testable import LoadPhotoExample

final class ImageLoadOperationTests: XCTestCase {

    private var testImage: UIImage!
    private var testImageData: Data!
    private var testURL: URL!
    private var mockCache: ImageCache!
    private var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        testImage = UIImage(systemName: "photo")!
        testImageData = testImage.pngData()
        testURL = URL(string: "https://picsum.photos/id/30/1280/901")!

        mockCache = ImageCache()

        MockURLProtocol.testData = testImageData
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
    }
    
    override func tearDown() {
        mockCache.clearCache()
        super.tearDown()
    }
    
    func testLoadImageOperation_Success() {
        let expectation = self.expectation(description: "Image Load Expectation")
        
        let photoRecord = PhotoRecord(url: testURL)
        let indexPath = IndexPath(row: 0, section: 0)
        
        let operation = ImageLoadOperation(photoRecord: photoRecord, indexPath: indexPath, targetSize: CGSize(width: 100, height: 100)) { updatedRecord, returnedIndexPath in
            XCTAssertNotNil(updatedRecord.image, "Image should be downloaded")
            XCTAssertEqual(updatedRecord.state, .downloaded, "State should be 'downloaded'")
            expectation.fulfill()
        }
        
        operation.start()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLoadImageOperation_FromCache() {
        let expectation = self.expectation(description: "Cache Load Expectation")

        let photoRecord = PhotoRecord(url: testURL)
        let indexPath = IndexPath(row: 1, section: 0)

        let operation = ImageLoadOperation(photoRecord: photoRecord, indexPath: indexPath, targetSize: CGSize(width: 100, height: 100)) { updatedRecord, returnedIndexPath in
            XCTAssertNotNil(updatedRecord.image, "Image should be loaded from cache")
            XCTAssertEqual(updatedRecord.state, .downloaded, "State should be 'downloaded'")
            expectation.fulfill()
        }

        operation.start()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLoadImageOperation_Failure() {
        let expectation = self.expectation(description: "Failure Load Expectation")

        testURL = URL(string: "test Failure")
        let photoRecord = PhotoRecord(url: testURL)
        let indexPath = IndexPath(row: 2, section: 0)

        MockURLProtocol.testError = NSError(domain: "TestError", code: 404, userInfo: nil)

        let operation = ImageLoadOperation(photoRecord: photoRecord, indexPath: indexPath, targetSize: CGSize(width: 100, height: 100)) { updatedRecord, returnedIndexPath in
            XCTAssertNil(updatedRecord.image, "Image should be nil on failure")
            XCTAssertEqual(updatedRecord.state, .failed, "State should be 'failed'")
            expectation.fulfill()
        }

        operation.start()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLoadImageOperation_Cancel() {
        let expectation = self.expectation(description: "Cancel Operation Expectation")

        let photoRecord = PhotoRecord(url: testURL)
        let indexPath = IndexPath(row: 3, section: 0)

        let operation = ImageLoadOperation(photoRecord: photoRecord, indexPath: indexPath, targetSize: CGSize(width: 100, height: 100)) { updatedRecord, returnedIndexPath in
            XCTFail("Completion should not be called if operation is cancelled")
        }

        operation.cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(operation.isCancelled, "Operation should be cancelled")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

}
