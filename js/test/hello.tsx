
let HelloWordStyleSheet = {
    textStyle: {
        color: '#ff0000',
        fontSize: 16,
        paddingLeft: 12,
        paddingTop: 12,
        paddingBottom: 12
    }

}

function Item1(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Text style={HelloWordStyleSheet.textStyle} onClick={onClick}>Even: {item.name}, {item.count}</Text>

}


function Item2(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Text style={HelloWordStyleSheet.textStyle} onClick={onClick}>Odd: {item.name}, {item.count}</Text>
}


function HelloWorld(current) {

    const [data, setData] = useState([])

    console.log("HelloWorld", "test")

    useEffect(() => {
        let ret = []
        for (let i = 0; i < 1000; i++) {
            ret.push({
                name: 'item' + i,
                index: i,
                count: 0
            })
        }
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
