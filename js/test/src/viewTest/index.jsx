let style = {
    nameStyle: {
        color: '#ff0000',
        fontSize: 16,
        marginLeft: 12,
        marginTop: 12,
        marginBottom: 12
    },
    textStyle: {
        color: '#ff0000',
        fontSize: 16,
        marginLeft: 12,
        marginTop: 12,
        marginBottom: 12
    },
    countStyle: {
        color: '#000000',
        fontSize: 20,
        marginLeft: 12,
        marginTop: 12,
        marginBottom: 12
    }
}

function Test() {

    console.log('开始执行')

    const [data, setData] = useState({
        name: '文本文本文本文本',
        avatar: 'https://w1.eckwai.com/udata/pkg/ks-merchant/kwaishop-mall-search-bar/shopping_cart_24.png',
        count: 10,
    })
    const onClick = useCallback(() => {
        console.log('执行点击事件')
        if (data.count < 20) {
            setData({
                name: data.name,
                avatar: data.avatar,
                count: data.count + 1,
            })
        } else {
            console.log('命中过滤逻辑')
        }
    }, []);

    return <View>
        <Image style = { {width : 60, height : 60, marginLeft: 12, marginTop: 12, marginBottom: 12} } source = {data.avatar}/>
        <Text style = { style.nameStyle } onClick={onClick}>{data.name}</Text>
        <Text style = { style.textStyle }>点击改变数字</Text>
        <Text style = { style.countStyle }>{data.count}</Text>
    </View>
}
