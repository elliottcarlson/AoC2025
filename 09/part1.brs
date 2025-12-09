sub Main()
    lines = readLines()
    pts = []

    for each raw in lines
        s$ = "" + raw
        if s$ = "" then continue for

        parts = s$.Split(",")
        if parts.count() <> 2 then continue for

        x = val(parts[0])
        y = val(parts[1])

        pts.push({ x: x, y: y })
    end for

    n = pts.count()
    maxArea$ = "0"

    for i = 0 to n - 1
        p1 = pts[i]
        for j = i + 1 to n - 1
            p2 = pts[j]

            dx = p1.x - p2.x
            if dx < 0 then dx = -dx

            dy = p1.y - p2.y
            if dy < 0 then dy = -dy

            width$  = Str(dx + 1.0).Trim()
            height$ = Str(dy + 1.0).Trim()

            area$ = BigMul(width$, height$)

            if BigCmp(area$, maxArea$) > 0 then
                maxArea$ = area$
            end if
        end for
    end for

    print "Day 9, Part 1 answer: "; maxArea$
end sub

