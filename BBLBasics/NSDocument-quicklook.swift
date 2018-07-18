public protocol DocumentThumbnailProvider {
  var thumbnailImage: NSImage? { get }
}

extension DocumentThumbnailProvider {
  
  public var quickLookBundleElementFileWrapper: FileWrapper {
    return FileWrapper(directoryWithFileWrappers: [
      "Preview.tiff": FileWrapper(regularFileWithContents: self.thumbnailData),
      "Thumbnail.tiff": FileWrapper(regularFileWithContents: self.thumbnailData)
      ])
  }
  
  private var thumbnailData: Data {
    return self.thumbnailImage?.tiffRepresentation ?? NSImage(named: NSImage.Name.caution)!.tiffRepresentation!
  }
}
