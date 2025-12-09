sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    g = lines
    h = g.count()
    if h = 0 then
        print "Day 7, Part 1 answer: 0"
        return
    end if

    firstRow$ = "" + g[0]
    w = Len(firstRow$)

    sx = 0 : sy = 0

    ' Find S
    for y = 0 to h - 1
        row$ = "" + g[y]
        for x = 0 to w - 1
            c$ = Mid(row$, x + 1, 1)
            if c$ = "S" then
                sx = x
                sy = y
            end if
        end for
    end for

    splits = 0
    stack = []
    stack.push({ x: sx, y: sy + 1 })

    seen = {}

    while stack.count() > 0
        node = stack[stack.count() - 1]
        stack.pop()

        x = node.x
        y = node.y

        ' CONVERT COORDINATES USING BIGINT HELPERS
        x$ = BigAdd("0", Str(x + 0.0).Trim())
        y$ = BigAdd("0", Str(y + 0.0).Trim())
        key$ = x$ + "," + y$

        if seen.doesExist(key$) then continue while
        seen[key$] = true

        if x < 0 or x >= w or y < 0 or y >= h then continue while

        row$ = "" + g[y]
        c$ = Mid(row$, x + 1, 1)

        if c$ = "^" then
            splits = splits + 1

            stack.push({ x: x - 1, y: y + 1 })
            stack.push({ x: x + 1, y: y + 1 })

        else if c$ = "." then
            stack.push({ x: x, y: y + 1 })
        end if
    end while

    print "Day 7, Part 1 answer: "; splits
end sub

