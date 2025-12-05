' Reads a whole text file and returns an array of trimmed lines.
' Returns invalid if the file can't be read.
function readLines() as object
    path = "pkg:/source/input"

    content = ReadAsciiFile(path)
    if content = invalid then
        return invalid
    end if

    ' Normalize CRLF -> LF
    content = content.Replace(chr(13), "")

    ' Split on LF into an array
    lines = content.Split(chr(10))

    ' Trim whitespace per line (optional but nice)
    for i = 0 to lines.count() - 1
        lines[i] = lines[i].Trim()
    end for

    return lines
end function


function BigNormalize(n as string) as string
    n = n.trim()
    if n = "" then return "0"

    i = 1
    while i <= len(n) and mid(n, i, 1) = "0"
        i = i + 1
    end while

    if i > len(n) then return "0"
    return mid(n, i)
end function

function BigCmp(a as string, b as string) as integer
    a = BigNormalize(a)
    b = BigNormalize(b)

    la = len(a)
    lb = len(b)

    if la < lb then return -1
    if la > lb then return 1

    if a < b then return -1
    if a > b then return 1

    return 0
end function

function BigAdd(a as string, b as string) as string
    a = BigNormalize(a)
    b = BigNormalize(b)

    i = len(a)
    j = len(b)
    carry = 0
    out = ""

    while i > 0 or j > 0 or carry > 0
        da = 0 : db = 0
        if i > 0 then da = val(mid(a, i, 1))
        if j > 0 then db = val(mid(b, j, 1))

        s = da + db + carry
        digit = s mod 10
        carry = s \ 10

        out = chr(48 + digit) + out

        i = i - 1
        j = j - 1
    end while

    return BigNormalize(out)
end function

function BigIsLE(a as string, b as string) as boolean
    return BigCmp(a, b) <= 0
end function

function BigIsGE(a as string, b as string) as boolean
    return BigCmp(a, b) >= 0
end function

function BigSub(a as string, b as string) as string
    a = BigNormalize(a)
    b = BigNormalize(b)

    if BigCmp(a, b) < 0 then return "0"

    i = len(a)
    j = len(b)
    borrow = 0
    out = ""

    while i > 0 or j > 0
        da = 0 : db = 0
        if i > 0 then da = val(mid(a, i, 1))
        if j > 0 then db = val(mid(b, j, 1))

        s = da - db - borrow
        if s < 0 then
            s = s + 10
            borrow = 1
        else
            borrow = 0
        end if

        out = chr(48 + s) + out
        i = i - 1
        j = j - 1
    end while

    return BigNormalize(out)
end function

