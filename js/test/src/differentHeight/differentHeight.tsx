function Item1(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Text style={ {color : item.color}, { height : item.height}, { fontSize : item.fontSize} } onClick={onClick}>Even: {item.name}, {item.count}</Text>

}

function Item2(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Text style={ {color : item.color}, {height : item.height}, { fontSize : item.fontSize} } onClick={onClick}>Odd: {item.name}, {item.count}</Text>
}

function HelloWorld(current) {

    const [data, setData] = useState([])

    useEffect(() => {
        let ret = []
        ret.push({
            name: 'is red data, height = 100',
            index: 0,
            count: 0,
            height: 100,
            fontSize: 15,
            color: '#FF0000' // red
        })
        ret.push({
            name: 'is black data, height = 150',
            index: 1,
            count: 10,
            height: 150,
            fontSize: 25,
            color: '#000000' // black
        })
        ret.push({
            name: 'is blue data, height = 60',
            index: 2,
            count: 20,
            height: 60,
            fontSize: 12,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 3,
            count: 20,
            height: 150,
            fontSize: 30,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 4,
            count: 20,
            height: 200,
            fontSize: 35,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 5,
            count: 20,
            height: 165,
            fontSize: 20,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 6,
            count: 20,
            height: 200,
            fontSize: 30,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 7,
            count: 20,
            height: 180,
            fontSize: 18,
            color: '#0000FF' // blue
        })
        ret.push({
            name: 'is blue data',
            index: 8,
            count: 20,
            height: 200,
            fontSize: 26,
            color: '#0000FF' // blue
        })
        setData(ret)
    }, [current])

    let render = function (i) {
        let item = data[i]
        if (item.index % 2 == 0) {
            return Item1(item, (it) => {
                it.count = it.count + 1
                setData(data)
            })
        } else {
            return Item2(item, (it) => {
                it.count = it.count + 2
                setData(data)
            })
        }
    }

    return <RecyclerView count={data.length} render={render}>Hello World!</RecyclerView>
}
