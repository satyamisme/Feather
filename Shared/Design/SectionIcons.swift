//
//  SectionIcons.swift
//  feather
//
//  Created by samara on 5/18/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import Nuke

class SectionIcons {
	@available(iOS 13.0, *)
	static public func sectionIcon(to cell: UITableViewCell, with symbolName: String, gradientColors: [UIColor]) {
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
		guard let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal) else {
			return
		}
		let imageSize = CGSize(width: 42, height: 42)
		
		let insetAmount: CGFloat = 5
		let scaledSymbolSize = symbolImage.size.aspectFit(in: imageSize, insetBy: insetAmount)

		let coloredBackgroundImage = UIGraphicsImageRenderer(size: imageSize).image { context in
			let gradientLayer = CAGradientLayer()
			gradientLayer.frame = CGRect(origin: .zero, size: imageSize)
			gradientLayer.colors = gradientColors.map { $0.cgColor }
			gradientLayer.startPoint = CGPoint(x: 0, y: 0)
			gradientLayer.endPoint = CGPoint(x: 1, y: 1)

			gradientLayer.render(in: context.cgContext)
			
			// Optionally add rounded corners to the gradient background
			let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: imageSize), cornerRadius: 10)
			context.cgContext.addPath(path.cgPath)
			context.cgContext.clip()
		}

		let mergedImage = UIGraphicsImageRenderer(size: imageSize).image { context in
			coloredBackgroundImage.draw(in: CGRect(origin: .zero, size: imageSize))
			symbolImage.draw(in: CGRect(
				x: (imageSize.width - scaledSymbolSize.width) / 2,
				y: (imageSize.height - scaledSymbolSize.height) / 2,
				width: scaledSymbolSize.width,
				height: scaledSymbolSize.height
			))
		}

		cell.imageView?.image = mergedImage
		cell.imageView?.layer.cornerRadius = 10
		cell.imageView?.layer.cornerCurve = .continuous
		cell.imageView?.clipsToBounds = true
		cell.imageView?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
	}

	
	static public func sectionImage(to cell: UITableViewCell, with originalImage: UIImage, size: CGSize = CGSize(width: 52, height: 52), radius: Int = 12) {
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		originalImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		cell.imageView?.image = resizedImage
		
		cell.imageView?.layer.cornerCurve = .continuous
		cell.imageView?.layer.cornerRadius = CGFloat(radius)
		cell.imageView?.layer.borderWidth = 1
		cell.imageView?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		cell.imageView?.clipsToBounds = true
	}

	
	static public func loadSectionImageFromURL(from url: URL, for cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
		let request = ImageRequest(url: url)
		SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)

		if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
			SectionIcons.sectionImage(to: cell, with: cachedImage)
		} else {
			ImagePipeline.shared.loadImage(
				with: request,
				queue: .global(), 
				progress: nil,
				completion: { result in
					switch result {
					case .success(let imageResponse):
						DispatchQueue.main.async {
							SectionIcons.sectionImage(to: cell, with: imageResponse.image)
						}
					case .failure(_): break
//						print(error)
					}
				}
			)
		}
	}
	
	static public func loadImageFromURL(from url: URL, completion: @escaping (UIImage?) -> Void) {
		let request = ImageRequest(url: url)

		if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
			completion(cachedImage)
			return
		} else {
			ImagePipeline.shared.loadImage(
				with: request,
				queue: .global(),
				progress: nil,
				completion: { result in
					switch result {
					case .success(let imageResponse):
						DispatchQueue.main.async {
							completion(imageResponse.image)
						}
					case .failure(_):
						DispatchQueue.main.async {
							completion(nil)
						}
					}
				}
			)
		}
	}
}
