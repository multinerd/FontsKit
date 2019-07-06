
import Foundation

internal typealias FontListOutput = (downloadable: [IOSFont], installed: [IOSFont])
internal typealias GeneratedCodeOutput = (full: String, individual: [String: String])

protocol CodeGen {
    func listOfFontsByFamily() -> [String : [String]]
    
    func generateCodeToDebugger(named: String?)
    func generateCode(named: String?, directoryPath: String)
    func generateCode(named: String?, filePath: String)
    
    func _generateCodeOutput(_ named: String?) -> GeneratedCodeOutput
}

class CodeGenerator: CodeGen {
    
    // MARK: - Caching
    
    internal var _cached: Cached<GeneratedCodeOutput>? = nil
    
    internal var _cachedList: Cached<[String:[String]]>? = nil

    
    // MARK: - Override by subclass
    
    func listOfFontsByFamily() -> [String : [String]] {
        fatalError("You must override this method!")
    }
    
    func _generateCodeOutput(_ named: String?) -> GeneratedCodeOutput {
        fatalError("You must override this method!")
    }

    
    // MARK: - Fonts Names
    
    /// Get a list of installed font family names
    func listOfFamilyNames() -> [String] {
        return listOfFontsByFamily().compactMap {$0.key}
    }
    
    /// Get a list of installed font  names
    func listOfFontNames() -> [String] {
        return listOfFontsByFamily().flatMap {$0.value}
    }
    
    // MARK: - Default Implementations
    
    /// Outputs code to debugger output.
    func generateCodeToDebugger(named: String? = nil) {
        
        self._generateCodeOutput(named).individual.sorted { $0.key < $1.key }.forEach {
            print($0.value + "\n")
        }
    }
    
    /// Output individual files to a specidied directory path.
    /// - Parameter named: An optional font name to generate. Can be ommited to generate all fonts.
    /// - Parameter directoryPath: The output directory path.
    func generateCode(named: String? = nil, directoryPath: String) {
        
        _generateCodeOutput(named).individual.forEach {
            do {
                let folderPath = "\(directoryPath)\($0.key)"
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: [:])
                
                let filePath = "\(folderPath)/\($0.key).swift"
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: [:])
                
                try $0.value.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
        print("Code output to \(directoryPath)")
    }
    
    /// Output a single file containing all the fonts.
    /// - Parameter named: An optional font name to generate. Can be ommited to generate all fonts.
    /// - Parameter filePath: The output file path.
    func generateCode(named: String? = nil, filePath: String) {
        
        do {
            try _generateCodeOutput(named).full.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error.userInfo)
        }
        print("Code output to \(filePath)")
    }
    
    
    // MARK: - Helpers
    
    open func _normalize(fontName: String) -> String {
        
        return (handleProblem(fontName: fontName) ?? fontName)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
        // .lowercaseFirst
    }
    
    open func _normalize(faceName: String) -> String {
        
        let components = faceName.components(separatedBy: "-")

        if components.count > 1 {
            let newFaceName = handleProblem(faceName: faceName) ?? components[1]
            return newFaceName.isEmpty ? "regular" : _normalize(fontName: newFaceName).lowercaseFirst
        } else {
            
            // Handle problem fonts
            let newFaceName = handleProblem(faceName: faceName) ?? faceName
            
            // Let's see if we can determine the type based on capitalization
            let fontNameLowercaseStart = newFaceName.lowercaseFirst
            
            var displayString = ""
            var isCollecting = false
            
            for char in fontNameLowercaseStart {
                guard !isCollecting else {
                    displayString += String(char)
                    continue
                }
                
                if ("A"..."z").contains(char) {
                    displayString += String(char)
                    isCollecting = true
                }
            }
            
            return displayString.isEmpty || faceName.lowercased() == displayString.lowercased() ? "regular" : displayString.lowercaseFirst
        }
    }
    
    /// Some fonts give off unexpected behaviours, we must handle accordingly
    private func handleProblem(faceName: String) -> String? {
        
        let problems = [
            ""
        ]
        
        for p in problems {
            if faceName.starts(with: p) {
                return faceName.replacingOccurrences(of: p, with: "")
            }
        }
        return nil
    }
    
    private func handleProblem(fontName: String) -> String? {

        return nil
    }
    
    private func handleProblemFontsWithHyphens(faceName: String) -> String? {
        

        
//        if faceName.contains("FZLT") {
//            return faceName.replacingOccurrences(of: "FZLT", with: "")
//        }
//        

        
        return nil
    }

}
