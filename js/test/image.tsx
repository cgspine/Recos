function Item1(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Image source = {item.avatar} onClick={onClick}/>
}

function Item2(item, onItemClick) {
    const onClick = useCallback(() => {
        onItemClick(item)
    })

    return <Image source = {item.avatar} onClick={onClick}/>
}

function HelloWorld(current) {

    const [data, setData] = useState([])

    useEffect(() => {
        let ret = []
        for (let i = 0; i < 100; i++) {
            ret.push({
                name: 'item' + i,
                index: i,
                count: 0,
                avatar: 'https://upload-images.jianshu.io/upload_images/5632003-001a13276ad85eba.jpg'
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
