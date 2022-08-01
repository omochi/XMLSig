import XCTest
import XMLSig

final class SignatureVerifierTests: XCTestCase {
    func testVerify() throws {
        try assertVerify(
            xml: """
<?xml version="1.0" encoding="UTF-8"?><saml2p:Response Destination="https://www.chatwork.com/packages/saml/acs.php" ID="id367967156786461262028932726" InResponseTo="ONELOGIN_0c194a465c26bed325a5795aa62d1267098add80" IssueInstant="2022-07-27T07:40:55.474Z" Version="2.0" xmlns:saml2p="urn:oasis:names:tc:SAML:2.0:protocol"><saml2:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion">http://www.okta.com/exk1txpqzxFANLz0m697</saml2:Issuer><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/><ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/><ds:Reference URI="#id367967156786461262028932726"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/><ds:DigestValue>Oc1/+XH1Wwi1hD4vc/MkZsyLrP6RPZGWVYydr10GNCQ=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>mE5BhwwF+os5fQUjsJeD/NRhpyaiGWkN5QxSHgTHSAc+KaYOoPSyC6FrnGFg18/zfOaS+d4UlIQH1QmT1O6DyxYXgkf6u1GofTKoBem/nH/WkHCgvk+QDypsq2BygCDu8AhTk/HuibwaIa3GgNmrBFUL9Oq1+vDSXwVwOORKVaLfe+BS4Y77rPNkIoNluUh/Qs/WltAcwU6l2BU0xtUog9hSGgpKQAHhREj3eC2giD5gIKT0vaJEtNUU+yWXyVZ2xZgPlCEVbPkFHNXSRTD+sKdZJpMoPnuht6ZtopqQBtRiuVxB1LuUHojaFH4BdN0+5u9Slv2eHAsx4CZbQjNMDg==</ds:SignatureValue><ds:KeyInfo><ds:X509Data><ds:X509Certificate>MIIDqjCCApKgAwIBAgIGAYI+klRtMA0GCSqGSIb3DQEBCwUAMIGVMQswCQYDVQQGEwJVUzETMBEG
A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU
MBIGA1UECwwLU1NPUHJvdmlkZXIxFjAUBgNVBAMMDXRyaWFsLTE2NDY4NDExHDAaBgkqhkiG9w0B
CQEWDWluZm9Ab2t0YS5jb20wHhcNMjIwNzI3MDczMTMzWhcNMzIwNzI3MDczMjMzWjCBlTELMAkG
A1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTAL
BgNVBAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRYwFAYDVQQDDA10cmlhbC0xNjQ2ODQx
MRwwGgYJKoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzrvONta4XtO3whgUSld4s3ex48CGh829lno83MauMKfXdEe7Usv1Q6nhUkxGdEczFI4Y
mPGZ0xR5QKXXa2hNyzmPrlgYLTXJaJuxmAED7AEwJpxLqDFjDVmdFvvd0+dAHGezUD+VSIGJbiUb
/sacC2gPcJHeRnd8zOpkdz3jNGZSPHG/SpRIAM+ML5ODTzo/CC+hAhUmB/CjpJh7NMZAY5nzmzkQ
tnHDYvd6d1DAvlG4VBLykz0CPAW9osA2pjQ2RuPQrvjn7KoQ0Z3I4h+uhSRC/g1ygbRGFj4Id+Kc
3D5jZp0kjydAnmAZzaSx8710tVNUf7o85ih/G1eyRpe2lwIDAQABMA0GCSqGSIb3DQEBCwUAA4IB
AQBy16bRZNC+6EAwKfNtU7dU3rXy4yNGugyK2FOFeHDRXKp9Y1I3sYeSR+hOxRxE1Ivr5RJjb7BY
JXylE6p6zzB+6RladNMxyiRGO52GqH0UcljsFEe5EbEJBptsmvfUS3DavSlshHERP0Uaq7QSaR8H
/sPLBQXaH0CkAb5+8Sb3F4D8kXidp0Gr6m5YG2t7ysk+EkYN9xa4J3D41KjRdy+sMQbSaDknFL1/
eG8KQirwxXpNxu0vCDGI8BoJyPDaXH3TytrXiAE1kSaimIsa3f08emO2vJuyqV2oI7T920oOvjGG
w1Tt1EcFQpK7KKgmRSR6n4RKuecudzqq3m25BD02</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature><saml2p:Status xmlns:saml2p="urn:oasis:names:tc:SAML:2.0:protocol"><saml2p:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></saml2p:Status><saml2:Assertion ID="id367967156787845201919283426" IssueInstant="2022-07-27T07:40:55.474Z" Version="2.0" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"><saml2:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion">http://www.okta.com/exk1txpqzxFANLz0m697</saml2:Issuer><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:SignedInfo><ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/><ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/><ds:Reference URI="#id367967156787845201919283426"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/><ds:DigestValue>/wUFuoWVU4u9JtscSQsvHGNjkS2+LnYXTHCi4XeYsVU=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>ieoJxVjsJ+ve0vQ5nZBpQqvtDCHa7EPNrmheLWT9UoGJGnAZP66/DBR61erRTVaBoUFtkfhdt3c2Z/iK9Cx7QPNyfGeQukWmyvatKBkrtHVS+zEjHvVg7pxxaokw2bzz4MbI+LMXbY7Ad/zop19L49apVPbFsVbIa+WFXg575DLy+3wDJ3ghJAi9P68HM6U1tFADJCpMbL1A0UiuGVnEdJfd8m9isgyopmvxDBeqdkRtBRDKICGaou9xUQ0ws+HNQZakh0aP0d14ZUcwIBs2ABubG27RF0EcISMCRM8HoUTBqJGeGfPq7iOzOC5eIMZjASxBG7kMXbYUTGHLJI1dUQ==</ds:SignatureValue><ds:KeyInfo><ds:X509Data><ds:X509Certificate>MIIDqjCCApKgAwIBAgIGAYI+klRtMA0GCSqGSIb3DQEBCwUAMIGVMQswCQYDVQQGEwJVUzETMBEG
A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU
MBIGA1UECwwLU1NPUHJvdmlkZXIxFjAUBgNVBAMMDXRyaWFsLTE2NDY4NDExHDAaBgkqhkiG9w0B
CQEWDWluZm9Ab2t0YS5jb20wHhcNMjIwNzI3MDczMTMzWhcNMzIwNzI3MDczMjMzWjCBlTELMAkG
A1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTAL
BgNVBAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRYwFAYDVQQDDA10cmlhbC0xNjQ2ODQx
MRwwGgYJKoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzrvONta4XtO3whgUSld4s3ex48CGh829lno83MauMKfXdEe7Usv1Q6nhUkxGdEczFI4Y
mPGZ0xR5QKXXa2hNyzmPrlgYLTXJaJuxmAED7AEwJpxLqDFjDVmdFvvd0+dAHGezUD+VSIGJbiUb
/sacC2gPcJHeRnd8zOpkdz3jNGZSPHG/SpRIAM+ML5ODTzo/CC+hAhUmB/CjpJh7NMZAY5nzmzkQ
tnHDYvd6d1DAvlG4VBLykz0CPAW9osA2pjQ2RuPQrvjn7KoQ0Z3I4h+uhSRC/g1ygbRGFj4Id+Kc
3D5jZp0kjydAnmAZzaSx8710tVNUf7o85ih/G1eyRpe2lwIDAQABMA0GCSqGSIb3DQEBCwUAA4IB
AQBy16bRZNC+6EAwKfNtU7dU3rXy4yNGugyK2FOFeHDRXKp9Y1I3sYeSR+hOxRxE1Ivr5RJjb7BY
JXylE6p6zzB+6RladNMxyiRGO52GqH0UcljsFEe5EbEJBptsmvfUS3DavSlshHERP0Uaq7QSaR8H
/sPLBQXaH0CkAb5+8Sb3F4D8kXidp0Gr6m5YG2t7ysk+EkYN9xa4J3D41KjRdy+sMQbSaDknFL1/
eG8KQirwxXpNxu0vCDGI8BoJyPDaXH3TytrXiAE1kSaimIsa3f08emO2vJuyqV2oI7T920oOvjGG
w1Tt1EcFQpK7KKgmRSR6n4RKuecudzqq3m25BD02</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature><saml2:Subject xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"><saml2:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">matsui@qoncept.co.jp</saml2:NameID><saml2:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml2:SubjectConfirmationData InResponseTo="ONELOGIN_0c194a465c26bed325a5795aa62d1267098add80" NotOnOrAfter="2022-07-27T07:45:55.474Z" Recipient="https://www.chatwork.com/packages/saml/acs.php"/></saml2:SubjectConfirmation></saml2:Subject><saml2:Conditions NotBefore="2022-07-27T07:35:55.474Z" NotOnOrAfter="2022-07-27T07:45:55.474Z" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"><saml2:AudienceRestriction><saml2:Audience>https://www.chatwork.com/packages/saml/metadata.php</saml2:Audience></saml2:AudienceRestriction></saml2:Conditions><saml2:AuthnStatement AuthnInstant="2022-07-27T07:38:24.285Z" SessionIndex="ONELOGIN_0c194a465c26bed325a5795aa62d1267098add80" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"><saml2:AuthnContext><saml2:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml2:AuthnContextClassRef></saml2:AuthnContext></saml2:AuthnStatement></saml2:Assertion></saml2p:Response>
"""
        )
    }

    private func assertVerify(xml: String, file: StaticString = #file, line: UInt = #line) throws {
        let verifier = XMLSignatureVerifier()
        XCTAssertNoThrow(
            try verifier.verify(xml: xml.data(using: .utf8)!),
            file: file, line: line
        )
    }
}
