component output="false" {

    public function init(){
        return this;
    }

    public boolean function verifyGoogleToken (required string base32Secret, required string userValue, numeric grace = 1)
    {
        for (var i = 0; i < grace; i++)
        {
            var expectedToken = getGoogleToken(base32Secret, -grace);
            if (expectedToken == userValue) {
                return true;
            }
        }
        return false;
    }

    public string function getGoogleToken (required string base32Secret, numeric offset = 0)
    {
        var intervals = JavaCast("long", Int((createObject("java", "java.lang.System").currentTimeMillis() / 1000) / 30) + offset);
        return getOneTimeToken(base32Secret, intervals);
    }

    public string function generateKey(required string password, array salt = [])
    {
        return generateKey(password, salt);
    }

    public string function getOTPURL(required string email, required string key)
    {
        return 'otpauth://totp/#arguments.email#?secret=#arguments.key#';
    }

    public string function getOneTimeToken (required string base32Secret, required numeric intervals)
    {
        var key = base32decode(secret);
        var secretKeySpec = createObject("java", "javax.crypto.spec.SecretKeySpec" ).init(key, "HmacSHA1");
        var mac = createObject("java", "javax.crypto.Mac").getInstance(secretKeySpec.getAlgorithm());
        mac.init(secretKeySpec);
        var buffer = createObject("java", "java.nio.ByteBuffer").allocate(8);
        buffer.putLong(intervals);
        var h = mac.doFinal(buffer.array());
        var t = h[20];
        if (t < 0) t += 256;
        var o = bitAnd(t, 15) + 1;

        t = h[o + 3];

        if (t < 0) t += 256;
        var num = t;
        t = h[o + 2];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 8));

        t = h[o + 1];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 16));

        t = h[o];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 24));

        num = bitAnd(num, 2147483647) % 1000000;

        return numberFormat(num, "000000");
    }
        public string function generateKey (required string password, array salt = [])
    {
        if (arrayLen(salt) NEQ 16)
        {
            var secureRandom = createObject("java", "java.security.SecureRandom").init();
            var buffer = createObject("java", "java.nio.ByteBuffer").allocate(16);
            arguments.salt = buffer.array();
            secureRandom.nextBytes(arguments.salt);
        }

        var keyFactory = createObject("java", "javax.crypto.SecretKeyFactory").getInstance("PBKDF2WithHmacSHA1");
        var keySpec = createObject("java", "javax.crypto.spec.PBEKeySpec").init(arguments.password.toCharArray(), salt, 128, 80);
        var secretKey = keyFactory.generateSecret(keySpec);
        return Base32encode(secretKey.getEncoded());
    }

    /**
    * A native Base32 encoder (see RFC4648 http://tools.ietf.org/html/rfc4648)
    *
    * Might not be the most efficient implementation. There is a version available
    * via the Apache Commons Codec, however this was only added in v1.5 and CF10 includes v1.3.
    *
    * I didn't want to create a dependency on JavaLoader or similar just for one simple(ish) encoder.
    */
    public string function Base32encode (required any inputBytes)
    {
        var values = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
        if (arrayLen(inputBytes) == 0)
        {
            return "";
        }
        var bytes = 0;
        if (ArrayLen(inputBytes) % 5 != 0)
        {
            var paddedLength = ArrayLen(inputBytes) + (5 - (ArrayLen(inputBytes) % 5));
            var buffer = createObject("java", "java.nio.ByteBuffer").allocate(paddedLength);
            buffer.put(inputBytes, 0, ArrayLen(inputBytes));
            bytes = buffer.array();
        }
        else
        {
            bytes = inputBytes;
        }

        var encoded = "";
        for (var i = 1; i <= arrayLen(bytes); i += 5)
        {
            byte = bytes[i];
            if (byte < 0) byte += 256;
            byte = bitSHRN(byte, 3);
            byte = bitAnd(byte, 31);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 7);
            byte = bitSHLN(byte, 2);
            byte2 = bytes[i+1];
            if (byte2 < 0) byte2 += 256;
            byte2 = bitSHRN(byte2, 6);
            byte2 = bitAnd(byte2, 3);
            byte = bitOr(byte, byte2);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+1];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 62);
            byte = bitSHRN(byte, 1);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+1];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 1);
            byte = bitSHLN(byte, 4);
            byte2 = bytes[i+2];
            if (byte2 < 0) byte2 += 256;
            byte2 = bitSHRN(byte2, 4);
            byte = bitOr(byte, byte2);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+2];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 15);
            byte = bitSHLN(byte, 1);
            byte2 = bytes[i+3];
            if (byte2 < 0) byte2 += 256;
            byte2 = bitSHRN(byte2, 7);
            byte = bitOr(byte, byte2);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+3];
            if (byte < 0) byte += 256;
            byte = bitSHRN(byte, 2);
            byte = bitAnd(byte, 31);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+3];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 3);
            byte = bitSHLN(byte, 3);
            byte2 = bytes[i+4];
            if (byte2 < 0) byte2 += 256;
            byte2 = bitSHRN(byte2, 5);
            byte = bitOr(byte, byte2);
            encoded &= Mid(values, byte + 1, 1);

            byte = bytes[i+4];
            if (byte < 0) byte += 256;
            byte = bitAnd(byte, 31);
            encoded &= Mid(values, byte + 1, 1);
        }

        encoded = Left(encoded, (arrayLen(inputBytes) / 5) * 8 + 1);
        if (len(encoded) % 8 != 0) {
            encoded &= repeatString("=", 8 - (len(encoded) % 8) );
        }
        return encoded;
    }

    /**
    * Convenience function for creating a Base32 encoding of a string
    */
    public string function Base32encodeString (required any string)
    {
        return base32encode(string.getBytes());
    }

    /* borrowed from org.apache.commons.codec.binary.Base32 */
    this.DECODE_TABLE = [
       //  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
          -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 00-0f
          -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 10-1f
          -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 63, // 20-2f
          -1, -1, 26, 27, 28, 29, 30, 31, -1, -1, -1, -1, -1, -1, -1, -1, // 30-3f 2-7
          -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, // 40-4f A-N
          15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25                     // 50-5a O-Z
    ];

    public any function base32decode (required string encoded)
    {
        var decoded = "";
        var byte = 0;
        var byte2 = 0;
        var byte3 = 0;
        var encodedBytes = javaCast("string", encoded).getBytes();
        var unpaddedLength = Len(replace(encoded, "=", "", "all"));
        var decodedBytes = createObject("java", "java.io.ByteArrayOutputStream").init();
        for (var i = 1; i <= arrayLen(encodedBytes); i += 8)
        {
            if (encodedBytes[i + 1] == 61) break;
            byte = bitSHLN(this.DECODE_TABLE[encodedBytes[i]], 3);
            byte2 = bitSHRN(this.DECODE_TABLE[encodedBytes[i + 1]], 2);
            decodedBytes.write(bitOr(byte, byte2));

            if (encodedBytes[i + 3] == 61) break;
            byte = bitSHLN(bitAnd(this.DECODE_TABLE[encodedBytes[i + 1]], 3), 6);
            byte2 = bitSHLN(this.DECODE_TABLE[encodedBytes[i + 2]], 1);
            byte3 = bitSHRN(this.DECODE_TABLE[encodedBytes[i + 3]], 4);
            decodedBytes.write(bitOr(bitOr(byte, byte2), byte3));

            if (encodedBytes[i + 4] == 61) break;
            byte = bitSHLN(bitAnd(this.DECODE_TABLE[encodedBytes[i + 3]], 15), 4);
            byte2 = bitSHRN(this.DECODE_TABLE[encodedBytes[i + 4]], 1);
            decodedBytes.write(bitOr(byte, byte2));

            if (encodedBytes[i + 5] == 61) break;
            byte = bitSHLN(bitAnd(this.DECODE_TABLE[encodedBytes[i + 4]], 1), 7);
            byte2 = bitSHLN(this.DECODE_TABLE[encodedBytes[i + 5]], 2);
            byte3 = bitSHRN(this.DECODE_TABLE[encodedBytes[i + 6]], 3);
            decodedBytes.write(bitOr(bitOr(byte, byte2), byte3));

            if (encodedBytes[i + 7] == 61) break;
            byte = bitSHLN(bitAnd(this.DECODE_TABLE[encodedBytes[i + 6]], 7), 5);
            byte2 = this.DECODE_TABLE[encodedBytes[i + 7]];
            decodedBytes.write(bitOr(byte, byte2));

        }

        return decodedBytes.toByteArray();
    }

    /**
    * Convenience function for decoding a Base32 string
    */
    public string function Base32decodeString (required any string, string encoding = "utf-8")
    {
        return charsetEncode(base32decode(string), encoding);//createObject("java", "java.lang.String").init(base32decode(string));
    }
}