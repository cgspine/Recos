
function Item1(item, onItemClick){
    // const [count, setCount] = useState(0)
    const onClick = useCallback(() => {
        onItemClick(item)
        // setCount(count+1)
    })

    return <Text style={{ color:'#fff' }} onClick={ onClick }>偶数：{item.name}, {item.count}</Text>

}

function Item2(item, onItemClick){
    // const [count, setCount] = useState(0)
    const onClick = useCallback(() => {
        onItemClick(item)
        // setCount(count+1)
    })

    return <Text style={{ color:'#fff' }} onClick={ onClick }>奇数：{item.name}, {item.count}</Text>
}

function HelloWorld(current){

    const [data, setData] = useState([])

    useEffect(() => {
        let ret = []
        for(let i = 0; i < 1000; i++){
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
        if(item.index % 2 == 0){
            return Item1(item, (it) => {
                it.count = it.count + 1
                setData(data)
            })
        }else{
            return Item2(item, (it) => {
                it.count = it.count + 2
                setData(data)
            })
        }
    }

    return <RecyclerView count = { data.length } render = { render }>Hello World!</RecyclerView>
}