sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    pts = []
    for each raw in lines
        s$ = "" + raw
        if s$ = "" then continue for

        parts = s$.Split(",")
        if parts.count() <> 3 then continue for

        x = val(parts[0])
        y = val(parts[1])
        z = val(parts[2])

        pts.push({ x: x, y: y, z: z })
    end for

    n = pts.count()
    if n = 0 then
        print "Day 8, Part 2 answer: 0"
        return
    end if

    inTree = []
    bestDist = []
    parent = []

    INF = 9.0e20

    for i = 0 to n - 1
        inTree.push(false)
        bestDist.push(INF)
        parent.push(-1)
    end for

    start = 0
    inTree[start] = true

    for v = 0 to n - 1
        if v = start then
            bestDist[v] = 0
            parent[v] = -1
        else
            d = dist2(pts[start], pts[v])
            bestDist[v] = d
            parent[v] = start
        end if
    end for

    treeSize = 1
    lastU = start
    lastP = -1

    while treeSize < n
        u = -1
        best = INF

        for i = 0 to n - 1
            if not inTree[i] and bestDist[i] < best then
                best = bestDist[i]
                u = i
            end if
        end for

        if u = -1 then
            exit while
        end if

        inTree[u] = true
        treeSize = treeSize + 1

        lastU = u
        lastP = parent[u]

        for v = 0 to n - 1
            if not inTree[v] then
                d = dist2(pts[u], pts[v])
                if d < bestDist[v] then
                    bestDist[v] = d
                    parent[v] = u
                end if
            end if
        end for
    end while

    if lastP < 0 then
        print "Day 8, Part 2 answer: 0"
        return
    end if

    pi = pts[lastU]
    pj = pts[lastP]

    xi$ = Str(pi.x + 0.0).Trim()
    xj$ = Str(pj.x + 0.0).Trim()
    ans$ = BigMul(xi$, xj$)

    print "Day 8, Part 2 answer: "; ans$
end sub

function dist2(p1 as object, p2 as object) as double
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    dz = p1.z - p2.z
    return dx * dx + dy * dy + dz * dz
end function

