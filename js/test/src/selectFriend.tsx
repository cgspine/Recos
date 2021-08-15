import {Crossfade, StaggeredVerticalGrid, Text, useEffect, useState, View, useCallback, Image, RecyclerView, WHSelectFriend} from 'Recos';

const SearchBarHeight = 56;
const SearchBarTop = 3;

let SelectFriendStyleSheet = {

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
    sectionList: {
        flex: 1,
        backgroundColor: "#666666"
    },
    sectionHeader: {
        height: 52,
        paddingHorizontal: 10
    },
    sectionHeaderLine: {
        height: 1,
        marginTop: 12,
        backgroundColor: "#666666"
    },
    sectionHeaderText: {
        fontSize: 14,
        color: "#666666",
        fontWeight: "FontWeightBold",
        marginTop: 12,
    },
}

export function SelectFriendLoadView() {

    // const data = []
    // const [sectionDataList, setSectionDataList] = useState([])
    // const [friendList, setFriendList] = useState([])

    // useEffect(() => {
    //     let ret = RecosMethodCall
    //     setRecentContectUsers(ret)
    // }, [])

    const [recentContectUsers, setRecentContectUsers] = useState([])

    useEffect(() => {
        const callBack = useCallback((result) => {
            setRecentContectUsers(result)
        })
        // 告诉原生执行方法
        // 开始执行原生方法，
        // 执行完成后，执行callBack
        const array = ['ExecNativeMethod', callBack, 'WHSelectFriend', 'getRecentContectUsers'];
    })
    // useEffect(() => {
    //     const results = [];
    //     if (recentContectUsers && recentContectUsers.length > 0) {
    //         console.log('recentContectUsers', recentContectUsers);
    //         results.push({
    //             title: `最近联系`,
    //             data: recentContectUsers.map((user) => {
    //                 return { user };
    //             }),
    //         });
    //     }
    //     setSectionDataList(results)
    // }, [])

    // if (friendList && friendList.length > 0) {
    //     results.push({
    //         title: `朋友 · ${0}`,
    //         data: friendList,
    //     });
    // }

    let render = function (i) {
        let item = recentContectUsers[i]
        return Cell(item)
    }

    return <RecyclerView count={recentContectUsers.length} render={render}></RecyclerView>
    // return <RecyclerView count={data.length} render={render} sectionRender={sectionRender}></RecyclerView>
}

function SectionHeader(data) {
    const { section } = data;
    if (!section.title || section.title.length <= 0) {
        return null;
    }
    return (
        <View style={SelectFriendStyleSheet.sectionHeader}>
            <View style={SelectFriendStyleSheet.sectionHeaderLine} />
            <Text style={SelectFriendStyleSheet.sectionHeaderText}>{section.title}</Text>
        </View>
    );
}

function Cell(data) {
    return <View
        style={WaterFallStyleSheet.cell}>
        <Image src={data.url} style={WaterFallStyleSheet.img}/>
        <Text style={WaterFallStyleSheet.title}>{data.title}</Text>
    </View>
}

function loadMoreFooter(data) {
    return <View>
        <Image src={data.url} style={WaterFallStyleSheet.img}/>
    </View>
}