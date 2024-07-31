CryptBinaryToString(pData, size, formatName := 'CRYPT_STRING_BASE64', NOCRLF := true) {
    static formats := { CRYPT_STRING_BASE64: 0x1,
        CRYPT_STRING_HEX: 0x4,
        CRYPT_STRING_HEXRAW: 0xC }
    , CRYPT_STRING_NOCRLF := 0x40000000

    fmt := formats.%formatName% | (NOCRLF ? CRYPT_STRING_NOCRLF : 0)
    if !DllCall('Crypt32\CryptBinaryToString', 'Ptr', pData, 'UInt', size, 'UInt', fmt, 'Ptr', 0, 'UIntP', &chars := 0)
        throw 'CryptBinaryToString failed. LastError: ' . A_LastError
    VarSetStrCapacity(&outString, chars)
    DllCall('Crypt32\CryptBinaryToString', 'Ptr', pData, 'UInt', size, 'UInt', fmt, 'Str', outString, 'UIntP', &chars)
    Return outString
}


CryptStringToBinary(string, formatName := 'CRYPT_STRING_BASE64') {
    static formats := { CRYPT_STRING_BASE64: 0x1,
        CRYPT_STRING_HEX: 0x4,
        CRYPT_STRING_HEXRAW: 0xC }
    fmt := formats.%formatName%
    chars := StrLen(string)
    if !DllCall('Crypt32\CryptStringToBinary', 'Str', string, 'UInt', chars, 'UInt', fmt
        , 'Ptr', 0, 'UIntP', &bytes := 0, 'UIntP', 0, 'UIntP', 0)
        throw 'CryptStringToBinary failed. LastError: ' . A_LastError
    outBuf := Buffer(bytes, 0)
    DllCall('Crypt32\CryptStringToBinary', 'Str', string, 'UInt', chars, 'UInt', fmt
        , 'Ptr', outBuf, 'UIntP', &bytes, 'UIntP', 0, 'UIntP', 0)
    Return outBuf
}


StringToBase64(str, encoding := 'UTF-8') {
    buf := Buffer(StrPut(str, encoding) - 1)
    StrPut(str, buf, encoding)
    return CryptBinaryToString(buf, buf.Size)
}

Base64ToString(base64, encoding := 'UTF-8') {
    buf := CryptStringToBinary(base64)
    return StrGet(buf, encoding)
}

HasVal(haystack, needle) {
    if !(IsObject(haystack)) || (haystack.Length = 0)
        return 0
    for index, value in haystack
        if (value = needle)
            return index
    return 0
}

RegexFindAll(Haystack, Needle) {
    Result := Array()
    spo := 1

    while fpo := RegExMatch(Haystack, Needle, &Match, spo) {
        Result.Push(Match)
        spo := fpo + StrLen(Match[0])
    }

    Return Result
}

LC_UriEncode(Uri, RE := "[0-9A-Za-z]") {
    if not Uri
        return ""

    Var := Buffer(StrPut(Uri, "UTF-8"), 0)
    StrPut(Uri, Var, "UTF-8")
    While Code := NumGet(Var, A_Index - 1, "UChar") {
        Char := Chr(Code)
        if RegExMatch(Char, RE)
            Res .= Char
        else
            Res .= Format("%{:02X}", Code)
    }
    return Res
}