const style = {
    view: {
        width: 300,
        height: 100,
        backgroundColor: '#000000'
    },
    text: {
        fontSize: 16,
        fontWeight: 500,
        color: '#7B68EE',
    },
    name: {
        fontSize: 14,
        fontWeight: 500,
        color: '#00FF00',
        backgroundColor: '#FFD700',
    }  
}

interface Model {
    name: string;
    invalidTimeStamp: number;
    pageName: string;
    localProps: LocalProps;
}

interface LocalProps {
    commonData: string;
}

function Test(model: Model) {

    console.log('逻辑开始执行')
    const timeString = parseTimeStamp(model.invalidTimeStamp);
    const mallType = getMallTypeByPageName(model.pageName);
    const mallName = getNameByPageName(model.pageName);
    if (model) {
        report(mallType, mallName)
    }
    console.log('逻辑结束执行')

    return (
        <View style={style.view}>
            <Text style={style.name}>{mallName}</Text>
            <Text style={style.text}>{timeString}</Text>
        </View>
    );
}

function report(mallType: number, mallName: string) {
    console.log('打点上报', mallType, mallName)
}

function getNameByPageName(pageName: string) {
    if (pageName === 'home_page') {
        return '买首'
    }
    return '商城'
}

function getMallTypeByPageName(pageName: string) {
    if (pageName === 'home_page') {
        return 0
    }
    return 1
}

function parseTimeStamp(invalidTimeStamp: number) {
    
    if (invalidTimeStamp <= 0) {
        return 0
    }

    let hours = Math.floor(invalidTimeStamp / 3600000);
    let hoursPart = hours * 3600000

    let mins = Math.floor(((invalidTimeStamp - hoursPart) / 60000));
    let minsPart = mins * 60000

    let secs = Math.floor((invalidTimeStamp - hoursPart - minsPart) / 1000);

    let hoursText = hours.toString()
    if (hours < 10) {
        hoursText = '0' + hoursText
    }

    let minsText = mins.toString()
    if (mins < 10) {
        minsText = '0' + minsText
    }

    let secsText = secs.toString();
    if (secs < 10) {
        secsText = '0' + secsText;
    }

    if (hoursText.length > 0) {
        return hoursText + '时' + minsText + '分' + secsText + '秒';
    }

    if (minsText.length > 0) {
        return minsText + '分' + secsText + '秒';
    }

    return secsText + '秒';
}
