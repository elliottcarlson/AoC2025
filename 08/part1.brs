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
        print "Day 8, Part 1 answer: 0"
        return
    end if

    KCONST = 1000

    edges = []   ' max-heap of edges, root = largest d
    heapSize = 0

    for i = 0 to n - 1
        p1 = pts[i]
        x1 = p1.x : y1 = p1.y : z1 = p1.z

        for j = i + 1 to n - 1
            p2 = pts[j]
            dx = x1 - p2.x
            dy = y1 - p2.y
            dz = z1 - p2.z
            d = dx * dx + dy * dy + dz * dz

            e = { d: d, i: i, j: j }

            if heapSize < KCONST then
                heapPush(edges, heapSize, e)
                heapSize = heapSize + 1
            else
                heapReplaceRootIfSmaller(edges, heapSize, e)
            end if
        end for
    end for

    if heapSize = 0 then
        print "Day 8, Part 1 answer: 0"
        return
    end if

    ' selection-sort the K edges by ascending distance
    for i = 0 to heapSize - 2
        minIndex = i
        minD = edges[i].d

        for j = i + 1 to heapSize - 1
            if edges[j].d < minD then
                minD = edges[j].d
                minIndex = j
            end if
        end for

        if minIndex <> i then
            tmp = edges[i]
            edges[i] = edges[minIndex]
            edges[minIndex] = tmp
        end if
    end for

    parent = []
    sizeArr = []
    for i = 0 to n - 1
        parent.push(i)
        sizeArr.push(1)
    end for

    for k = 0 to heapSize - 1
        e = edges[k]
        ufUnion(parent, sizeArr, e.i, e.j)
    end for

    comp = {}
    for i = 0 to n - 1
        r = ufFind(parent, i)
        key$ = Str(r + 0.0).Trim()
        if comp.doesExist(key$) then
            comp[key$] = comp[key$] + 1
        else
            comp[key$] = 1
        end if
    end for

    sizes = []
    for each key in comp
        sizes.push(comp[key])
    end for

    if sizes.count() = 0 then
        print "Day 8, Part 1 answer: 0"
        return
    end if

    a = 0 : b = 0 : c = 0
    for each sz in sizes
        if sz > a then
            c = b : b = a : a = sz
        else if sz > b then
            c = b : b = sz
        else if sz > c then
            c = sz
        end if
    end for

    if sizes.count() = 1 then
        b = 1 : c = 1
    else if sizes.count() = 2 then
        c = 1
    end if

    ans = a * b * c
    print "Day 8, Part 1 answer: "; ans
end sub

' ---------- heap helpers (max-heap on .d) ----------

sub heapPush(edges as object, heapSize as integer, e as object)
    edges.push(e)
    i = heapSize
    while i > 0
        p = (i - 1) \ 2
        if edges[p].d >= edges[i].d then exit while
        tmp = edges[p]
        edges[p] = edges[i]
        edges[i] = tmp
        i = p
    end while
end sub

sub heapReplaceRootIfSmaller(edges as object, heapSize as integer, e as object)
    if heapSize = 0 then
        edges.push(e)
        return
    end if

    if e.d >= edges[0].d then return

    edges[0] = e
    i = 0

    while true
        l = 2 * i + 1
        r = l + 1
        largest = i

        if l < heapSize and edges[l].d > edges[largest].d then
            largest = l
        end if
        if r < heapSize and edges[r].d > edges[largest].d then
            largest = r
        end if

        if largest = i then exit while

        tmp = edges[i]
        edges[i] = edges[largest]
        edges[largest] = tmp

        i = largest
    end while
end sub

' ---------- union–find helpers ----------

function ufFind(parent as object, x as integer) as integer
    i = x
    while i <> parent[i]
        i = parent[i]
    end while
    return i
end function

sub ufUnion(parent as object, sizeArr as object, a as integer, b as integer)
    ra = ufFind(parent, a)
    rb = ufFind(parent, b)
    if ra = rb then return

    if sizeArr[ra] < sizeArr[rb] then
        parent[ra] = rb
        sizeArr[rb] = sizeArr[rb] + sizeArr[ra]
    else
        parent[rb] = ra
        sizeArr[ra] = sizeArr[ra] + sizeArr[rb]
    end if
end sub

