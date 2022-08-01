public enum XMLSignature {
    public static let version_1_0_URI = "http://www.w3.org/2000/09/xmldsig#"
    public static let version_1_1_URI = "http://www.w3.org/2009/xmldsig11#"

    public enum Transforms {
        public static let envelopedSignatureURI = "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
    }

    public enum DigestMethods {
        public static let sha1URI = "http://www.w3.org/2000/09/xmldsig#sha1"
        public static let sha256URI = "http://www.w3.org/2001/04/xmlenc#sha256"
    }
}
