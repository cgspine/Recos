function HelloWorld(){
    
    let data = []
    
    for(let i = 0; i < 1000; i++){
        data.push({
            name: 'item' + i,
            index: i
        })
    }

    let render = function (i) {
        let item = data[i]  
        if(item.index % 2 == 0){
            return <Text style={{ color:'#fff' }}>偶数：{item.name}</Text>
        }else{
            return <Text style={{ color:'#fff' }}>奇数: {item.name}</Text>
        }
    }

    return <RecyclerView count = { data.length } render = { render }>Hello World!</RecyclerView>
}
