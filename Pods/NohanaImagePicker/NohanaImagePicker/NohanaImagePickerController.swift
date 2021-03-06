/*
 * Copyright (C) 2016 nohana, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import Photos

public enum MediaType: Int {
    case any = 0, photo, video
}

@objc public protocol NohanaImagePickerControllerDelegate {
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController)
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts :[PHAsset])
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, willPickPhotoKitAsset asset: PHAsset, pickedAssetsCount: Int) -> Bool
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, didPickPhotoKitAsset asset: PHAsset, pickedAssetsCount: Int)
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, willDropPhotoKitAsset asset: PHAsset, pickedAssetsCount: Int) -> Bool
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, didDropPhotoKitAsset asset: PHAsset, pickedAssetsCount: Int)
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, didSelectPhotoKitAsset asset: PHAsset)
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, didSelectPhotoKitAssetList assetList: PHAssetCollection)
    @objc optional func nohanaImagePickerDidSelectMoment(_ picker: NohanaImagePickerController) -> Void
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, assetListViewController: UICollectionViewController, cell: UICollectionViewCell, indexPath: IndexPath, photoKitAsset: PHAsset) -> UICollectionViewCell
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, assetDetailListViewController: UICollectionViewController, cell: UICollectionViewCell, indexPath: IndexPath, photoKitAsset: PHAsset) -> UICollectionViewCell
    @objc optional func nohanaImagePicker(_ picker: NohanaImagePickerController, assetDetailListViewController: UICollectionViewController, didChangeAssetDetailPage indexPath: IndexPath, photoKitAsset: PHAsset)
    
}

open class NohanaImagePickerController: UIViewController {
    
    open var maximumNumberOfSelection: Int = 21 // set 0 to set no limit
    open var numberOfColumnsInPortrait: Int = 4
    open var numberOfColumnsInLandscape: Int = 7
    open weak var delegate: NohanaImagePickerControllerDelegate?
    open var shouldShowMoment: Bool = true
    open var shouldShowEmptyAlbum: Bool = false
    open var toolbarHidden: Bool = false
    open var canPickAsset = { (asset:Asset) -> Bool in
        return true
    }
    lazy var assetBundle:Bundle = {
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "NohanaImagePicker", ofType: "bundle") {
            return Bundle(path: path)!
        }
        return bundle
    }()
    let pickedAssetList: PickedAssetList
    let mediaType: MediaType
    let enableExpandingPhotoAnimation: Bool
    fileprivate let assetCollectionSubtypes: [PHAssetCollectionSubtype]
    
    public init() {
        if #available(iOS 9.0, *) {
            assetCollectionSubtypes = [
                .albumRegular,
                .albumSyncedEvent,
                .albumSyncedFaces,
                .albumSyncedAlbum,
                .albumImported,
                .albumMyPhotoStream,
                .albumCloudShared,
                .smartAlbumGeneric,
                .smartAlbumFavorites,
                .smartAlbumRecentlyAdded,
                .smartAlbumUserLibrary,
                .smartAlbumSelfPortraits,
                .smartAlbumScreenshots,
            ]
        } else {
            assetCollectionSubtypes = [
                .albumRegular,
                .albumSyncedEvent,
                .albumSyncedFaces,
                .albumSyncedAlbum,
                .albumImported,
                .albumMyPhotoStream,
                .albumCloudShared,
                .smartAlbumGeneric,
                .smartAlbumFavorites,
                .smartAlbumRecentlyAdded,
                .smartAlbumUserLibrary
            ]
        }
        mediaType = .photo
        pickedAssetList = PickedAssetList()
        enableExpandingPhotoAnimation = true
        super.init(nibName: nil, bundle: nil)
        self.pickedAssetList.nohanaImagePickerController = self
    }
    
    public init(assetCollectionSubtypes: [PHAssetCollectionSubtype], mediaType: MediaType, enableExpandingPhotoAnimation: Bool) {
        self.assetCollectionSubtypes = assetCollectionSubtypes
        self.mediaType = mediaType
        self.enableExpandingPhotoAnimation = enableExpandingPhotoAnimation
        pickedAssetList = PickedAssetList()
        super.init(nibName: nil, bundle: nil)
        self.pickedAssetList.nohanaImagePickerController = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // show albumListViewController
        let storyboard = UIStoryboard(name: "NohanaImagePicker", bundle: assetBundle)
        let viewControllerId = enableExpandingPhotoAnimation ? "EnableAnimationNavigationController" : "DisableAnimationNavigationController"
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: viewControllerId) as? UINavigationController else {
            fatalError("navigationController init failed.")
        }
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
        
        // setup albumListViewController
        guard let albumListViewController = navigationController.topViewController as? AlbumListViewController else {
            fatalError("albumListViewController is not topViewController.")
        }
        albumListViewController.photoKitAlbumList =
            PhotoKitAlbumList(
                assetCollectionTypes: [.smartAlbum, .album],
                assetCollectionSubtypes: assetCollectionSubtypes,
                mediaType: mediaType,
                shouldShowEmptyAlbum: shouldShowEmptyAlbum,
                handler: { [weak albumListViewController] in
                DispatchQueue.main.async(execute: { () -> Void in
                    albumListViewController?.isLoading = false
                    albumListViewController?.tableView.reloadData()
                })
            })
        albumListViewController.nohanaImagePickerController = self
    }
    
    open func pickAsset(_ asset: Asset) {
        _ = pickedAssetList.pick(asset: asset)
    }
    
    open func dropAsset(_ asset: Asset) {
        _ = pickedAssetList.drop(asset: asset)
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    open func dropAll(){
        pickedAssetList.removeAll()
    }
    
    open func getAssetUIImage(_ asset: PHAsset) -> UIImage {
        return getAssetUIImage(asset, nil, nil, nil, nil)
    }
    
    open func getAssetUIImage(_ asset: PHAsset, _ manager: PHImageManager?, _ option: PHImageRequestOptions?, _ targetSize: CGSize?, _ contentMode: PHImageContentMode? ) -> UIImage {
        let manager = manager ?? PHImageManager.default()
        let option = option ?? PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: targetSize ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: contentMode ?? .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return image
    }
}

