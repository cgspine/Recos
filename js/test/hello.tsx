
function Item(item, onItemClick){
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Text onClick={ onClick }>{item.name}, {item.count}</Text>
}

function HelloWorld(current){
    const [data, setData] = useState([])
    useEffect(() => {
        let ret = []
        for(let i = 0; i < 1000; i++){
            ret.push({name: 'item' + i, count: 0})
        }
        setData(ret)
    }, [current])
    let render = function (i) {
        let item = data[i]
        return Item(item, (it) => {
            it.count = it.count + 1
            setData(data)
        })
    }
    return <RecyclerView count = { data.length } render = { render }/>
}