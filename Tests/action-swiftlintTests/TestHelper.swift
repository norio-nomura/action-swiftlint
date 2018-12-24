import Foundation

let projectRootURL = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
let projectRootPath = projectRootURL.appendingPathComponent("/").path

extension String {
    func withStaticString(_ closure: (StaticString) -> Void) {
        withCString {
            let rawPointer = $0._rawValue
            let byteSize = lengthOfBytes(using: .utf8)._builtinWordValue
            let isASCII = true._getBuiltinLogicValue()
            let staticString = StaticString(_builtinStringLiteral: rawPointer,
                                            utf8CodeUnitCount: byteSize,
                                            isASCII: isASCII)
            closure(staticString)
        }
    }
}
