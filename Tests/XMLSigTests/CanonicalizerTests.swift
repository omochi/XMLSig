import XCTest
import XMLSig

/*
 テストデータは以下を参考に作成。
 https://www.w3.org/TR/2001/REC-xml-c14n-20010315
 https://github.com/ucarion/c14n/tree/master/tests
 */

final class CanonicalizerTests: XCTestCase {
    func testMin() throws {
        try assertCanonicalize(
            source: """
<doc></doc>
""",
            expected: """
<doc></doc>
"""
        )
    }

    func testWhitespace() throws {
        try assertCanonicalize(
            source: """
<doc>
   <clean>   </clean>
   <dirty>   A   B   </dirty>
   <mixed>
      A
      <clean>   </clean>
      B
      <dirty>   A   B   </dirty>
      C
   </mixed>
</doc>
""",
            expected: """
<doc>
   <clean>   </clean>
   <dirty>   A   B   </dirty>
   <mixed>
      A
      <clean>   </clean>
      B
      <dirty>   A   B   </dirty>
      C
   </mixed>
</doc>
"""
        )
    }

    func testStartAndEndTags() throws {
        try assertCanonicalize(
            source: """
<doc>
   <e1   />
   <e2   ></e2>
   <e3   name = "elem3"   id="elem3"   />
   <e4   name="elem4"   id="elem4"   ></e4>
   <e5 a:attr="out" b:attr="sorted" attr2="all" attr="I'm"
      xmlns:b="http://www.ietf.org"
      xmlns:a="http://www.w3.org"
      xmlns="http://example.org"/>
   <e6 xmlns="" xmlns:a="http://www.w3.org">
      <e7 xmlns="http://www.ietf.org">
         <e8 xmlns="" xmlns:a="http://www.w3.org">
            <e9 xmlns="" xmlns:a="http://www.ietf.org"/>
         </e8>
      </e7>
   </e6>
</doc>
""",
            expected: """
<doc>
   <e1></e1>
   <e2></e2>
   <e3 id="elem3" name="elem3"></e3>
   <e4 id="elem4" name="elem4"></e4>
   <e5 xmlns="http://example.org" xmlns:a="http://www.w3.org" xmlns:b="http://www.ietf.org" attr="I'm" attr2="all" b:attr="sorted" a:attr="out"></e5>
   <e6>
      <e7 xmlns="http://www.ietf.org">
         <e8 xmlns="">
            <e9></e9>
         </e8>
      </e7>
   </e6>
</doc>
"""
        )
    }

    func testCharacterModificationsAndReferences() throws {
        try assertCanonicalize(
            source: """
<doc>
   <text>First line&#x0d;&#10;Second line</text>
   <value>&#x32;</value>
   <compute><![CDATA[value>"0" && value<"10" ?"valid":"error"]]></compute>
   <compute expr='value>"0" &amp;&amp; value&lt;"10" ?"valid":"error"'>valid</compute>
   <norm attr=' &apos;   &#x20;&#13;&#xa;&#9;   &apos; '/>
   <normNames attr='   A   &#x20;&#13;&#xa;&#9;   B   '/>
   <normId id=' &apos;   &#x20;&#13;&#xa;&#9;   &apos; '/>
</doc>
""",
            expected: """
<doc>
   <text>First line&#xD;
Second line</text>
   <value>2</value>
   <compute>value&gt;"0" &amp;&amp; value&lt;"10" ?"valid":"error"</compute>
   <compute expr="value>&quot;0&quot; &amp;&amp; value&lt;&quot;10&quot; ?&quot;valid&quot;:&quot;error&quot;">valid</compute>
   <norm attr=" '    &#xD;&#xA;&#x9;   ' "></norm>
   <normNames attr="   A    &#xD;&#xA;&#x9;   B   "></normNames>
   <normId id=" '    &#xD;&#xA;&#x9;   ' "></normId>
</doc>
"""
        )
    }

    func testUTF8Encoding() throws {
        try assertCanonicalize(
            source: """
<?xml version="1.0" encoding="ISO-8859-1"?>
<doc>&#169;</doc>
""",
            expected: """
<doc>©</doc>
"""
        )
    }

    func testNestedRedeclaration() throws {
        try assertCanonicalize(
            source: """
<root>
  <foo xmlns:a="http://example.com">
    <bar xmlns:a="http://example.com" a:y="z" />
  </foo>
</root>
""",
            expected: """
<root>
  <foo>
    <bar xmlns:a="http://example.com" a:y="z"></bar>
  </foo>
</root>
"""
        )
    }

    func testShadowing() throws {
        try assertCanonicalize(
            source: """
<outer xmlns:a="http://example.com">
  <a:inner xmlns:a="http://example.com">
    <a:foo />
  </a:inner>
</outer>
""",
            expected: """
<outer>
  <a:inner xmlns:a="http://example.com">
    <a:foo></a:foo>
  </a:inner>
</outer>
"""
        )
    }

    func testSAML() throws {
        try assertCanonicalize(
            source: """
<samlp:Response xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" ID="root" Version="2.0" IssueInstant="2020-05-26T00:24:42Z" Destination="http://sp.example.com">
  <saml:Issuer>http://idp.example.com</saml:Issuer>
  <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
    <ds:SignedInfo>
      <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
      <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
      <ds:Reference URI="#root">
        <ds:Transforms>
          <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
          <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
        </ds:Transforms>
        <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
        <ds:DigestValue>xxx</ds:DigestValue>
      </ds:Reference>
    </ds:SignedInfo>
    <ds:SignatureValue>yyy</ds:SignatureValue>
    <ds:KeyInfo>
      <ds:X509Data>
        <ds:X509Certificate>zzz</ds:X509Certificate>
      </ds:X509Data>
    </ds:KeyInfo>
  </ds:Signature>
  <samlp:Status>
    <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />
  </samlp:Status>
  <saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Version="2.0" ID="Ad16bfaaa9436509463d25f8590385aed135abef5" IssueInstant="2020-05-26T00:24:42Z">
    <saml:Issuer>http://idp.example.com</saml:Issuer>
    <saml:Subject>
      <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">jdoe@example.com</saml:NameID>
      <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
        <saml:SubjectConfirmationData NotOnOrAfter="2020-05-26T00:27:42Z" Recipient="http://sp.example.com" />
      </saml:SubjectConfirmation>
    </saml:Subject>
    <saml:Conditions NotBefore="2020-05-26T00:21:42Z" NotOnOrAfter="2020-05-26T00:27:42Z">
      <saml:AudienceRestriction>
        <saml:Audience />
      </saml:AudienceRestriction>
    </saml:Conditions>
    <saml:AuthnStatement AuthnInstant="2020-05-26T00:24:41Z" SessionNotOnOrAfter="2020-05-27T00:24:42Z" SessionIndex="aaa">
      <saml:AuthnContext>
        <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
      </saml:AuthnContext>
    </saml:AuthnStatement>
    <saml:AttributeStatement>
      <saml:Attribute NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" Name="firstName">
        <saml:AttributeValue xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">John</saml:AttributeValue>
      </saml:Attribute>
    </saml:AttributeStatement>
  </saml:Assertion>
</samlp:Response>
""",
            expected: """
<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Destination="http://sp.example.com" ID="root" IssueInstant="2020-05-26T00:24:42Z" Version="2.0">
  <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">http://idp.example.com</saml:Issuer>
  <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
    <ds:SignedInfo>
      <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod>
      <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>
      <ds:Reference URI="#root">
        <ds:Transforms>
          <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>
          <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:Transform>
        </ds:Transforms>
        <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>
        <ds:DigestValue>xxx</ds:DigestValue>
      </ds:Reference>
    </ds:SignedInfo>
    <ds:SignatureValue>yyy</ds:SignatureValue>
    <ds:KeyInfo>
      <ds:X509Data>
        <ds:X509Certificate>zzz</ds:X509Certificate>
      </ds:X509Data>
    </ds:KeyInfo>
  </ds:Signature>
  <samlp:Status>
    <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"></samlp:StatusCode>
  </samlp:Status>
  <saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="Ad16bfaaa9436509463d25f8590385aed135abef5" IssueInstant="2020-05-26T00:24:42Z" Version="2.0">
    <saml:Issuer>http://idp.example.com</saml:Issuer>
    <saml:Subject>
      <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">jdoe@example.com</saml:NameID>
      <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
        <saml:SubjectConfirmationData NotOnOrAfter="2020-05-26T00:27:42Z" Recipient="http://sp.example.com"></saml:SubjectConfirmationData>
      </saml:SubjectConfirmation>
    </saml:Subject>
    <saml:Conditions NotBefore="2020-05-26T00:21:42Z" NotOnOrAfter="2020-05-26T00:27:42Z">
      <saml:AudienceRestriction>
        <saml:Audience></saml:Audience>
      </saml:AudienceRestriction>
    </saml:Conditions>
    <saml:AuthnStatement AuthnInstant="2020-05-26T00:24:41Z" SessionIndex="aaa" SessionNotOnOrAfter="2020-05-27T00:24:42Z">
      <saml:AuthnContext>
        <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
      </saml:AuthnContext>
    </saml:AuthnStatement>
    <saml:AttributeStatement>
      <saml:Attribute Name="firstName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
        <saml:AttributeValue xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">John</saml:AttributeValue>
      </saml:Attribute>
    </saml:AttributeStatement>
  </saml:Assertion>
</samlp:Response>
"""
        )
    }

    private func assertCanonicalize(source: String, expected: String, file: StaticString = #file, line: UInt = #line) throws {
        let canonicalizer = XMLExclusiveCanonicalizer()
        let out = try canonicalizer.canonicalize(xml: source.data(using: .utf8)!)
        XCTAssertEqual(out, expected, file: file, line: line)
    }
}
