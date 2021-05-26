function HelloWorld(){
    let data = []
    for(let i = 0; i < 1000; i++){
        data.push({
            name: 'item' + i,
            index: i
        })
    }

    const [count, setCount] = useState(0)

    let render = function (i) {
        let item = data[i]
        let onClick = function (){
            setCount(count+1)
        }
        if(item.index % 2 == 0){
            return <Text style={{ color:'#fff' }} onClick={ onClick }>偶数：{item.name}, {count}</Text>
        }else{
            return <Text style={{ color:'#fff' }} onClick={ onClick }>奇数: {item.name}, {count}</Text>
        }
    }

    return <RecyclerView count = { data.length } render = { render }>Hello World!</RecyclerView>
}