let WaterFallStyleSheet = {

    loadingCnt: {
        backgroundColor: "#cccccc",
        alignItems: "center",
        justifyContent: "center",
        width: '100%',
        height: '100%'
    },

    loading: {
        fontSize: 16,
        color: "#000000",
    },

    layout: {
        backgroundColor: "#cccccc"
    },
    cell: {
        margin: 12,
        flexDirection: "column",
        alignItems: "center",
        paddingHorizontal: 16,
        paddingVertical: 20,
        backgroundColor: "#ffffff"
    },

    img: {
        width: 100,
        height: 100,
    },

    title: {
        fontSize: 16,
        color: "#000000",
        marginTop: 12,
    },

    detail: {
        fontSize: 14,
        marginTop: 12,
        color: "#777777"
    },

    tagContainer: {
        marginTop: 12,
        flexDirection: "row",
    },

    tagItem: {
        backgroundColor: "#cccccc",
        color: "#666666",
        borderRadius: 8,
        marginHorizontal: 6,
        paddingHorizontal: 12,
        paddingVertical: 4,
        fontSize: 11,
    }
}

function Cell(data) {
    let tags = [];
    if (data.tags != null) {
        for (let i = 0; i < data.tags.length; i++) {
            tags.push(<Text style={WaterFallStyleSheet.tagItem}>{data.tags[i]}</Text>)
        }
    }
    return <View
        style={WaterFallStyleSheet.cell}>
        <Image src={data.url} style={WaterFallStyleSheet.img} />
        <Text style={WaterFallStyleSheet.title}>{data.title}</Text>
        <Text style={WaterFallStyleSheet.detail}>{data.detail}</Text>
        <View style={WaterFallStyleSheet.tagContainer}>
            {tags}
        </View>
    </View>
}

function Waterfall() {
    const [data, setData] = useState([])

    useEffect(() => {
        let ret = []
        for (let i = 0; i < 200; i++) {
            let detail = ""
            let remain = i % 3
            if(remain == 0){
                detail = "This is a long long long long long long long long long long long long long long long long sentence"
            }else if(remain == 1){
                detail = "this is a normal normal normal normal normal normal sentence"
            }else{
                detail = "this is a short sentence"
            }
            ret.push({
                url: "https://wehear-1258476243.file.myqcloud.com/hemera/cover/59d/7f2/t9_5b8a0600339149c4ea55001b0f.png",
                title: "This is title",
                detail: detail,
                tags: ["Tag1", "Tag2"]
            })
        }
        setData(ret)
    }, [])

    let render = function (i) {
        let item = data[i]
        return Cell(item)
    }

    if(data.length == 0){
        return <View style={WaterFallStyleSheet.loadingCnt}>
            <Text> loading... </Text>
        </View>
    }

    return <StaggeredVerticalGrid style={WaterFallStyleSheet.layout} spanCount={2} count={data.length} render={render}/>
}